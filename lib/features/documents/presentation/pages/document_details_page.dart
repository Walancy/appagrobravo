import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/image_source_bottom_sheet.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/documents_cubit.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';

class DocumentDetailsPage extends StatefulWidget {
  final DocumentType type;
  final DocumentEntity? currentDocument;
  final DocumentsCubit? cubit;

  const DocumentDetailsPage({
    super.key,
    required this.type,
    this.currentDocument,
    this.cubit,
  });

  @override
  State<DocumentDetailsPage> createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  File? _selectedFile;
  bool _isUploading = false;
  bool _isProcessingOcr = false;
  String? _ocrError;

  @override
  void initState() {
    super.initState();
    if (widget.currentDocument != null) {
      _numberController.text = widget.currentDocument!.documentNumber ?? '';
      _nameController.text = widget.currentDocument!.title ?? '';
      _selectedDate = widget.currentDocument!.expiryDate;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _openImagePreview() {
    final selectedPath = _selectedFile?.path.toLowerCase();
    final hasLocalImage =
        _selectedFile != null && selectedPath?.endsWith('.pdf') == false;
    final hasLocalPdf =
        _selectedFile != null && selectedPath?.endsWith('.pdf') == true;
    final remoteUrl = widget.currentDocument?.imageUrl;
    final hasRemotePdf = remoteUrl != null &&
        (remoteUrl.toLowerCase().contains('.pdf') ||
            remoteUrl.toLowerCase().contains('/pdf'));
    final hasRemoteImage = widget.currentDocument?.imageUrl != null &&
        !widget.currentDocument!.imageUrl!.toLowerCase().contains('.pdf') &&
        !widget.currentDocument!.imageUrl!.toLowerCase().contains('/pdf');

    if (hasLocalPdf) {
      launchUrl(
        Uri.file(_selectedFile!.path),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    if (hasRemotePdf) {
      final uri = Uri.tryParse(remoteUrl);
      if (uri != null) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if (!hasLocalImage && !hasRemoteImage) return;

    final ImageProvider imageProvider;
    if (hasLocalImage) {
      imageProvider = FileImage(_selectedFile!);
    } else {
      imageProvider = NetworkImage(widget.currentDocument!.imageUrl!);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImagePage(
          imageProvider: imageProvider,
          title: widget.type.label,
        ),
      ),
    );
  }

  void _showDatePickerBottomSheet() {
    DateTime tempDate = _selectedDate ?? DateTime.now().add(const Duration(days: 365));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        'Data de Validade',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = tempDate;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Confirmar',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime.now().subtract(const Duration(days: 3650)),
                    maximumDate: DateTime.now().add(const Duration(days: 3650)),
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime? _parseDateFromOcr(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _processDocumentOcr(File file) async {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    final isImage = ['.jpg', '.jpeg', '.png', '.webp'].any(file.path.toLowerCase().endsWith);
    final supportsOcr = widget.type == DocumentType.passaporte || widget.type == DocumentType.visto;

    if ((!isImage && !isPdf) || !supportsOcr) {
      setState(() {
        _ocrError = null;
      });
      return;
    }

    setState(() {
      _isProcessingOcr = true;
      _ocrError = null;
    });

    File fileToProcess = file;

    if (isPdf) {
      try {
        final document = await PdfDocument.openFile(file.path);
        if (document.pagesCount > 0) {
          final page = await document.getPage(1);
          final pageImage = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.jpeg,
          );
          
          if (pageImage != null) {
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await tempFile.writeAsBytes(pageImage.bytes);
            fileToProcess = tempFile;
          }
          
          await page.close();
        }
        await document.close();
      } catch (e) {
        if (mounted) {
          setState(() {
            _ocrError = 'Erro ao converter PDF para IA: $e';
            _isProcessingOcr = false;
          });
        }
        return;
      }
    }

    final cubit = widget.cubit ?? getIt<DocumentsCubit>();
    final result = await cubit.parseDocument(type: widget.type, file: fileToProcess);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _ocrError = error.toString();
          _isProcessingOcr = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao extrair dados por IA: $error')),
        );
      },
      (data) {
        setState(() {
          _isProcessingOcr = false;
        });

        final expectedKind = widget.type == DocumentType.passaporte ? 'passport' : 'visa';
        final detectedKind = data['document_kind'];

        if (detectedKind != null && detectedKind != expectedKind) {
          final detectedLabel = detectedKind == 'passport' ? 'Passaporte' : 'Visto';
          final selectedLabel = widget.type.label;
          setState(() {
            _ocrError = 'O documento anexado é um $detectedLabel, mas você selecionou "$selectedLabel". Envie o documento correto.';
            _selectedFile = null; // Reseta o arquivo inválido
          });
          return;
        }

        // Se o tipo coincidir, preenche os dados
        if (widget.type == DocumentType.passaporte) {
          final passportNumber = data['passport_number'];
          if (passportNumber != null) {
            _numberController.text = passportNumber.toString();
          }
        } else if (widget.type == DocumentType.visto) {
          final visaNumber = data['visa_number'];
          if (visaNumber != null) {
            _numberController.text = visaNumber.toString();
          }
        }

        final givenName = data['given_name'];
        final surname = data['surname'];
        String? fullName;
        if (givenName != null || surname != null) {
          final parts = <String>[];
          if (givenName != null && givenName.toString().trim().isNotEmpty) {
            parts.add(givenName.toString().trim());
          }
          if (surname != null && surname.toString().trim().isNotEmpty) {
            parts.add(surname.toString().trim());
          }
          fullName = parts.join(' ');
        }
        if (fullName != null && fullName.isNotEmpty) {
          _nameController.text = fullName.toUpperCase();
        }

        final expirationDateStr = data['expiration_date'];
        if (expirationDateStr != null && expirationDateStr is String) {
          final expDate = _parseDateFromOcr(expirationDateStr);
          if (expDate != null) {
            setState(() {
              _selectedDate = expDate;
            });
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados extraídos por Inteligência Artificial!'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final resultSource = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        title: _selectedFile != null || widget.currentDocument?.imageUrl != null
            ? 'Alterar arquivo do documento'
            : 'Enviar ${widget.type.label}',
        supportFiles: true,
      ),
    );

    if (resultSource == null) return;

    File? file;

    if (resultSource == 'file') {
      final pickedResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );
      if (pickedResult != null && pickedResult.files.single.path != null) {
        file = File(pickedResult.files.single.path!);
      }
    } else if (resultSource is ImageSource) {
      final image = await picker.pickImage(source: resultSource);
      if (image != null) {
        file = File(image.path);
      }
    }

    if (file != null) {
      setState(() {
        _selectedFile = file;
        _ocrError = null;
      });
      await _processDocumentOcr(file);
    }
  }

  Future<void> _onSave(BuildContext context) async {
    if (_selectedFile == null && widget.currentDocument?.imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um PDF ou imagem do documento.'),
        ),
      );
      return;
    }

    if (_selectedFile == null && widget.currentDocument != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha um novo arquivo para atualizar o documento.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Using the cubit from context. In the router we'll need to make sure
    // it's either provided or we use a static method.
    // Actually, it's better to use getIt or provide it.
    final cubit = widget.cubit ?? getIt<DocumentsCubit>();

    try {
      if (_selectedFile != null) {
        await cubit.uploadDocument(
          id: widget.currentDocument?.id,
          type: widget.type,
          file: _selectedFile!,
          documentNumber: _numberController.text,
          expiryDate: _selectedDate,
          documentName: _nameController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Signal success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedFileName = _selectedFile?.path.split('/').last;
    final hasCurrentDocument = widget.currentDocument?.imageUrl != null;
    final canSubmit = _selectedFile != null && !_isUploading;

    return Scaffold(
      appBar: AppHeader(mode: HeaderMode.back, title: widget.type.label),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.lg),

            if (_ocrError != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red[800]),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _ocrError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.red.shade200
                              : Colors.red.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            Text(
              'Arquivo do documento',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _openImagePreview,
              child: _buildImagePreview(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  hasCurrentDocument || _selectedFile != null
                      ? Icons.swap_horiz_rounded
                      : Icons.upload_file_rounded,
                  size: 20,
                ),
                label: Text(
                  hasCurrentDocument || _selectedFile != null
                      ? 'Substituir arquivo'
                      : 'Selecionar PDF ou imagem',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Novo arquivo: $selectedFileName',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.56),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            _buildFieldLabel('Nome no documento'),
            _DocumentTextField(
              controller: _nameController,
              hintText: 'Ex: NELSON VIEIRA',
            ),

            const SizedBox(height: AppSpacing.lg),
            _buildFieldLabel('Número do documento'),
            _DocumentTextField(
              controller: _numberController,
              hintText: 'Ex: CD123456',
            ),

            const SizedBox(height: AppSpacing.lg),
            _buildFieldLabel('Data de validade'),
            InkWell(
              onTap: _showDatePickerBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Selecionar data'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: canSubmit ? () => _onSave(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
                  disabledForegroundColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        hasCurrentDocument
                            ? 'Enviar substituição para análise'
                            : 'Enviar para análise',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    if (widget.currentDocument == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Este documento ainda não foi enviado. Envie agora para análise.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.orange.shade200
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color statusColor = Colors.orange;
    String statusText = 'Pendente de análise';
    IconData icon = Icons.access_time;

    if (widget.currentDocument!.status == DocumentStatus.aprovado) {
      statusColor = AppColors.primary;
      statusText = 'Documento aprovado';
      icon = Icons.check_circle_outline;
    } else if (widget.currentDocument!.status == DocumentStatus.recusado) {
      statusColor = AppColors.error;
      statusText = 'Documento recusado';
      icon = Icons.error_outline;
    } else if (widget.currentDocument!.status == DocumentStatus.expirado) {
      statusColor = AppColors.error;
      statusText = 'Documento expirado';
      icon = Icons.warning_amber_outlined;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(icon, color: statusColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  statusText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.currentDocument!.rejectionReason != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Motivo: ${widget.currentDocument!.rejectionReason}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final localPath = _selectedFile?.path.toLowerCase();
    final remoteUrl = widget.currentDocument?.imageUrl;
    final remoteLower = remoteUrl?.toLowerCase() ?? '';
    final isLocalPdf = localPath?.endsWith('.pdf') ?? false;
    final isRemotePdf = remoteLower.contains('.pdf') ||
        remoteLower.contains('/pdf') ||
        remoteLower.contains('application/pdf');
    final fileName = _selectedFile?.path.split('/').last ??
        widget.currentDocument?.title ??
        '${widget.type.label}.pdf';

    return Container(
      width: double.infinity,
      height: 230,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: _selectedFile != null
                  ? (isLocalPdf
                      ? _buildPdfPreview(fileName)
                      : Image.file(_selectedFile!, fit: BoxFit.cover))
                  : (remoteUrl != null
                      ? (isRemotePdf
                          ? _buildPdfPreview(fileName)
                          : Image.network(
                          widget.currentDocument!.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPdfPreview(fileName),
                        ))
                      : _buildEmptyPreview()),
            ),
            if (_isProcessingOcr)
              const Positioned.fill(
                child: OcrScanningOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfPreview(String fileName) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 30,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                fileName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'PDF anexado • toque para abrir',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.025),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nenhum arquivo anexado',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Envie um PDF ou uma imagem legível do documento.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.54),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _DocumentTextField({
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.bodyMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.36),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.035),
      ),
    );
  }
}

class OcrScanningOverlay extends StatefulWidget {
  const OcrScanningOverlay({super.key});

  @override
  State<OcrScanningOverlay> createState() => _OcrScanningOverlayState();
}

class _OcrScanningOverlayState extends State<OcrScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.4),
        ),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: 220 * _animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.cyanAccent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.cyanAccent,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'IA extraindo dados...',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final ImageProvider imageProvider;
  final String title;

  const FullScreenImagePage({
    super.key,
    required this.imageProvider,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
