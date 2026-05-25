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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.push(
              '/document-details',
              extra: {
                'type': type,
                'document': null,
                'cubit': cubit,
              },
            ).then((value) {
              if (value == true) {
                cubit.loadDocuments();
              }
            });
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Adicionar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentEntity> documents) {
    if (documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nenhum documento enviado',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: 80,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildHistoryCard(context, doc);
      },
    );
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
        onTap: () {
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
        },
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: document.imageUrl != null
                      ? Image.network(
                          document.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image_outlined, size: 24),
                        )
                      : const Icon(Icons.image_not_supported, size: 24),
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
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
