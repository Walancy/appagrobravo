import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
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
  DateTime? _selectedDate;
  File? _selectedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentDocument != null) {
      _numberController.text = widget.currentDocument!.documentNumber ?? '';
      _selectedDate = widget.currentDocument!.expiryDate;
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() => _selectedFile = File(image.path));
      }
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
          type: widget.type,
          file: _selectedFile!,
          documentNumber: _numberController.text,
          expiryDate: _selectedDate,
        );
      } else if (widget.currentDocument != null) {
        // Only metadata update support? The repository current impl expects a file.
        // For now, if user doesn't pick a new file, we might just stay as is,
        // OR we need to update the repository to allow metadata-only updates.
        // Users requested "preview of sent document" and "new screen".
        // Let's assume they might want to just see it or change metadata.
        // However, the current requirement is to upload.
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(mode: HeaderMode.back, title: widget.type.label),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Imagem do Documento',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildImagePreview(),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, size: 20),
              label: Text(
                _selectedFile != null ||
                        widget.currentDocument?.imageUrl != null
                    ? 'Alterar Foto'
                    : 'Tirar Foto',
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
                fillColor: const Color(0xFFFAFAFA),
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
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _selectedDate ??
                      DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFAFAFA),
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
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _selectedFile != null
            ? Image.file(_selectedFile!, fit: BoxFit.cover)
            : (widget.currentDocument?.imageUrl != null
                  ? Image.network(
                      widget.currentDocument!.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image_outlined, size: 50),
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
                            'Nenhuma imagem enviada',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )),
      ),
    );
  }
}
