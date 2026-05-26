import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/image_source_bottom_sheet.dart';
import 'package:agrobravo/core/di/injection.dart';
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
    final hasLocalImage = _selectedFile != null && !_selectedFile!.path.toLowerCase().endsWith('.pdf');
    final hasRemoteImage = widget.currentDocument?.imageUrl != null &&
        !widget.currentDocument!.imageUrl!.toLowerCase().contains('.pdf') &&
        !widget.currentDocument!.imageUrl!.toLowerCase().contains('/pdf');

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
    final isImage = ['.jpg', '.jpeg', '.png', '.webp'].any(file.path.toLowerCase().endsWith);
    final supportsOcr = widget.type == DocumentType.passaporte || widget.type == DocumentType.visto;

    if (!isImage || !supportsOcr) {
      setState(() {
        _ocrError = null;
      });
      return;
    }

    setState(() {
      _isProcessingOcr = true;
      _ocrError = null;
    });

    final cubit = widget.cubit ?? getIt<DocumentsCubit>();
    final result = await cubit.parseDocument(type: widget.type, file: file);

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
            : 'Enviar documento',
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
          content: Text('Por favor, selecione uma foto do documento'),
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
      } else if (widget.currentDocument != null) {
        // Only metadata update support? The repository current impl expects a file.
        // For now, if user doesn't pick a new file, we might just stay as is,
        // OR we need to update the repository to allow metadata-only updates.
        // Users requested "preview of sent document" and "new screen".
        // Let's assume they might want to just see it or change metadata.
        // However, the current requirement is to upload.
        // BUG-015: guard mounted before using context after async gap
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione uma nova imagem para atualizar o documento.',
            ),
          ),
        );
        setState(() => _isUploading = false);
        return;
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
    final isPdf = _selectedFile != null && _selectedFile!.path.toLowerCase().endsWith('.pdf');
    return Scaffold(
      appBar: AppHeader(mode: HeaderMode.back, title: widget.type.label),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.lg),

            if (_ocrError != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red[200]!),
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
                          color: Colors.red[900],
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
              isPdf ? 'Arquivo do Documento (PDF)' : 'Imagem do Documento',
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
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: Text(
                _selectedFile != null ||
                        widget.currentDocument?.imageUrl != null
                    ? 'Alterar Arquivo'
                    : 'Escolher Arquivo / Foto',
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Nome no Documento',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ex: NELSON VIEIRA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Número do Documento',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _numberController,
              decoration: InputDecoration(
                hintText: 'Ex: CD123456',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              'Data de Validade',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _showDatePickerBottomSheet,
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
                onPressed: _isUploading ? null : () => _onSave(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Salvar e Enviar para Análise',
                        style: TextStyle(
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
                  color: Colors.orange[800],
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
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildImagePreview() {
    final isPdf = _selectedFile != null && _selectedFile!.path.toLowerCase().endsWith('.pdf');
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: _selectedFile != null
                  ? (isPdf
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.picture_as_pdf,
                                size: 56,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  _selectedFile!.path.split('/').last,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(_selectedFile!, fit: BoxFit.cover))
                  : (widget.currentDocument?.imageUrl != null
                      ? Image.network(
                          widget.currentDocument!.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            final urlLower = widget.currentDocument!.imageUrl!.toLowerCase();
                            if (urlLower.contains('.pdf') || urlLower.contains('/pdf')) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.picture_as_pdf,
                                      size: 56,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.currentDocument!.title ?? 'Documento PDF',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const Icon(Icons.broken_image_outlined, size: 50);
                          },
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 48,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Nenhum documento enviado',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )),
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
