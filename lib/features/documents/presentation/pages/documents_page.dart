import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/documents_shimmer.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/home/domain/entities/mission_entity.dart';
import '../cubit/documents_cubit.dart';
import '../cubit/documents_state.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/document_enums.dart';

enum DocumentUserState { nuncaParticipou, semMissao, emMissao }

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<DocumentsCubit>().loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(
        mode: HeaderMode.back,
        title: 'Meus documentos',
      ),
      body: BlocBuilder<DocumentsCubit, DocumentsState>(
        builder: (context, state) {
          return state.when(
            initial: () => const DocumentsShimmer(),
            loading: () => const DocumentsShimmer(),
            error: (message) => Center(child: Text(message)),
            loaded: (documents, isAlertDismissed, profile, mission) {
              return _buildBody(context, documents, profile, mission);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<DocumentEntity> documents,
    ProfileEntity? profile,
    MissionEntity? mission,
  ) {
    // List of all types that should be visible
    final allTypes = [
      DocumentType.passaporte,
      DocumentType.visto,
      DocumentType.vacina,
      DocumentType.seguro,
      DocumentType.carteiraMotorista,
      DocumentType.autorizacaoMenores,
    ];

    return RefreshIndicator(
      onRefresh: () => context.read<DocumentsCubit>().loadDocuments(),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          ...allTypes.map((type) {
            final doc = documents.cast<DocumentEntity?>().firstWhere(
              (d) => d?.type == type,
              orElse: () => null,
            );
            return DocumentTypeButton(
              type: type,
              document: doc,
              profile: profile,
              mission: mission,
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class DocumentTypeButton extends StatelessWidget {
  final DocumentType type;
  final DocumentEntity? document;
  final ProfileEntity? profile;
  final MissionEntity? mission;

  const DocumentTypeButton({
    required this.type,
    this.document,
    this.profile,
    this.mission,
  });

  DocumentUserState _getUserState() {
    if (mission != null) return DocumentUserState.emMissao;
    if ((profile?.missionsCount ?? 0) > 0) return DocumentUserState.semMissao;
    return DocumentUserState.nuncaParticipou;
  }

  @override
  Widget build(BuildContext context) {
    final userState = _getUserState();

    // Calculate Age
    bool isUnder18 = false;
    if (profile?.birthDate != null) {
      final today = DateTime.now();
      final birthDate = profile!.birthDate!;
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      isUnder18 = age < 18;
    }

    // MANDATORY LOGIC
    bool isTypeMandatory = false;

    if (userState == DocumentUserState.emMissao) {
      switch (type) {
        case DocumentType.passaporte:
          isTypeMandatory = mission!.passaporteObrigatorio;
          break;
        case DocumentType.visto:
          isTypeMandatory = mission!.vistoObrigatorio;
          break;
        case DocumentType.vacina:
          isTypeMandatory = mission!.vacinaObrigatoria;
          break;
        case DocumentType.seguro:
          isTypeMandatory = mission!.seguroObrigatorio;
          break;
        case DocumentType.carteiraMotorista:
          isTypeMandatory = mission!.carteiraObrigatoria;
          break;
        case DocumentType.autorizacaoMenores:
          isTypeMandatory = mission!.autorizacaoObrigatoria && isUnder18;
          break;
        case DocumentType.outro:
          isTypeMandatory = false;
          break;
      }
    }

    bool isPending = false;
    bool isAlert = false;

    if (userState == DocumentUserState.emMissao) {
      if (document == null) {
        // Exception for "seguro", does not show pendency if missing
        isPending = isTypeMandatory && type != DocumentType.seguro;
      } else {
        isPending = document!.status == DocumentStatus.pendente;
        isAlert = document!.status == DocumentStatus.recusado ||
            document!.status == DocumentStatus.expirado;
      }
    }

    // Status visual
    Color statusColor = AppColors.primary;
    if (userState == DocumentUserState.emMissao) {
      if (document == null) {
        statusColor = isPending ? Colors.orange : Colors.grey;
      } else {
        switch (document!.status) {
          case DocumentStatus.aprovado:
            statusColor = AppColors.primary;
            break;
          case DocumentStatus.pendente:
            statusColor = Colors.orange;
            break;
          case DocumentStatus.recusado:
          case DocumentStatus.expirado:
            statusColor = AppColors.error;
            break;
        }
      }
    } else {
      statusColor = AppColors.textSecondary.withOpacity(0.5);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          final isHistoryType = type == DocumentType.seguro ||
              type == DocumentType.visto ||
              type == DocumentType.vacina;

          if (userState == DocumentUserState.semMissao || isHistoryType) {
            context.push(
              '/document-history',
              extra: {
                'type': type,
                'cubit': context.read<DocumentsCubit>(),
              },
            ).then((value) {
              context.read<DocumentsCubit>().loadDocuments();
            });
          } else {
            context.push(
              '/document-details',
              extra: {
                'type': type,
                'document': document,
                'cubit': context.read<DocumentsCubit>(),
              },
            ).then((value) {
              if (value == true) {
                context.read<DocumentsCubit>().loadDocuments();
              }
            });
          }
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: (isPending || isAlert)
                  ? statusColor.withOpacity(0.5)
                  : Theme.of(context).dividerColor.withOpacity(0.1),
              width: (isPending || isAlert) ? 1.5 : 1,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: userState == DocumentUserState.emMissao
                      ? statusColor.withOpacity(0.1)
                      : Theme.of(context).dividerColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(type),
                  color: userState == DocumentUserState.emMissao
                      ? statusColor
                      : AppColors.textSecondary,
                  size: 24,
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStatusText(userState),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: (isPending || isAlert)
                            ? statusColor
                            : AppColors.textSecondary,
                        fontWeight: (isPending || isAlert)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (userState == DocumentUserState.emMissao)
                if (isPending || isAlert)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      color: Colors.white,
                      size: 12,
                    ),
                  )
                else if (document?.status == DocumentStatus.aprovado)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 24,
                  )
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(DocumentUserState state) {
    if (state != DocumentUserState.emMissao) {
      if (state == DocumentUserState.semMissao) {
        return 'Ver documentos';
      } else {
        return 'Adicionar / Ver documentos';
      }
    }
    
    if (document == null) return 'Pendente de envio';
    if (document!.status == DocumentStatus.pendente)
      return 'Aguardando aprovação';
    if (document!.status == DocumentStatus.aprovado) return 'Documento em dia';
    if (document!.status == DocumentStatus.recusado)
      return 'Recusado - Clique para reenviar';
    if (document!.status == DocumentStatus.expirado)
      return 'Expirado - Clique para atualizar';
    return '';
  }

  IconData _getIcon(DocumentType type) {
    switch (type) {
      case DocumentType.passaporte:
        return Icons.auto_stories;
      case DocumentType.visto:
        return Icons.public;
      case DocumentType.vacina:
        return Icons.vaccines;
      case DocumentType.seguro:
        return Icons.health_and_safety;
      case DocumentType.carteiraMotorista:
        return Icons.directions_car;
      case DocumentType.autorizacaoMenores:
        return Icons.family_restroom;
      case DocumentType.outro:
        return Icons.description;
    }
  }
}
