import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import '../cubit/documents_cubit.dart';
import '../cubit/documents_state.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';

class DocumentHistoryPage extends StatelessWidget {
  final DocumentType type;
  final DocumentsCubit cubit;

  const DocumentHistoryPage({
    super.key,
    required this.type,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppHeader(
          mode: HeaderMode.back,
          title: type.label,
        ),
        body: BlocBuilder<DocumentsCubit, DocumentsState>(
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (documents, isAlertDismissed, profile, mission) {
                final typeDocuments = documents
                    .where((d) => d.type == type)
                    .toList();

                return _buildBody(context, typeDocuments);
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentEntity> documents) {
    final latestDocument = documents.isNotEmpty ? documents.first : null;

    if (documents.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.xl),
          _HistoryIntro(type: type),
          const SizedBox(height: AppSpacing.lg),
          _EmptyHistoryCard(
            onTap: () => _openDetails(context, null),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: 80,
      ),
      children: [
        _HistoryIntro(type: type),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton.icon(
            onPressed: () => _openDetails(context, latestDocument),
            icon: const Icon(Icons.upload_file_rounded, size: 20),
            label: Text(
              latestDocument == null
                  ? 'Enviar documento'
                  : 'Atualizar documento',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Histórico de envios',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...documents.map((doc) => _buildHistoryCard(context, doc)),
      ],
    );
  }

  void _openDetails(BuildContext context, DocumentEntity? document) {
    context.push(
      '/document-details',
      extra: {
        'type': type,
        'document': document,
        'cubit': cubit,
      },
    ).then((value) {
      if (value == true) {
        cubit.loadDocuments();
      }
    });
  }

  Widget _buildHistoryCard(BuildContext context, DocumentEntity document) {
    Color statusColor = AppColors.primary;
    String statusText = '';

    switch (document.status) {
      case DocumentStatus.aprovado:
        statusColor = AppColors.primary;
        statusText = 'Aprovado';
        break;
      case DocumentStatus.pendente:
        statusColor = Colors.orange;
        statusText = 'Pendente de aprovação';
        break;
      case DocumentStatus.recusado:
      case DocumentStatus.expirado:
        statusColor = AppColors.error;
        statusText = document.status == DocumentStatus.recusado
            ? 'Recusado'
            : 'Expirado';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () => _openDetails(context, document),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _isPdf(document)
                      ? AppColors.error.withValues(alpha: 0.1)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.08),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _isPdf(document)
                      ? const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.error,
                          size: 28,
                        )
                      : document.imageUrl != null
                          ? Image.network(
                              document.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.description_outlined,
                                size: 24,
                              ),
                            )
                          : const Icon(Icons.description_outlined, size: 24),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentNumber?.isNotEmpty == true
                          ? 'Nº ${document.documentNumber}'
                          : 'Sem número',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enviado em: ${document.uploadDate != null ? "${document.uploadDate!.day}/${document.uploadDate!.month}/${document.uploadDate!.year}" : "N/D"}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusText,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPdf(DocumentEntity document) {
    final url = document.imageUrl?.toLowerCase() ?? '';
    return url.contains('.pdf') || url.contains('/pdf');
  }
}

class _HistoryIntro extends StatelessWidget {
  final DocumentType type;

  const _HistoryIntro({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.folder_copy_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Acompanhe o envio atual e substitua o arquivo quando necessário.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.58),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyHistoryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.035),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Nenhum documento enviado',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Toque para anexar um PDF ou imagem e enviar para análise.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
