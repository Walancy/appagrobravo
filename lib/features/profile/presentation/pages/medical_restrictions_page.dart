import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/core/components/medical_shimmer.dart';

class MedicalRestrictionsPage extends StatefulWidget {
  const MedicalRestrictionsPage({super.key});

  @override
  State<MedicalRestrictionsPage> createState() =>
      _MedicalRestrictionsPageState();
}

class _MedicalRestrictionsPageState extends State<MedicalRestrictionsPage> {
  List<String> _tags = [];
  bool _isInitialized = false;

  void _addTag(BuildContext context, String text) {
    if (text.isEmpty) return;
    if (!_tags.contains(text)) {
      setState(() {
        _tags.add(text);
      });
      _saveTags(context);
    }
  }

  void _removeTag(BuildContext context, String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _saveTags(context);
  }

  void _saveTags(BuildContext context) {
    context.read<ProfileCubit>().updateMedicalRestrictions(_tags);
  }

  void _showAddInformationSheet(BuildContext providerContext) {
    String? selectedCategory;
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: providerContext,
      isScrollControlled: true,
      backgroundColor: Theme.of(providerContext).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                top: AppSpacing.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCategory == null
                          ? 'Selecione uma categoria'
                          : 'Adicione a descrição',
                      style: AppTextStyles.h3.copyWith(
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (selectedCategory == null)
                      ...[
                        'Condição médica',
                        'Uso de medicamento',
                        'Alergia',
                        'Restrição alimentar',
                        'Mobilidade',
                        'Fobia',
                        'Outro',
                      ].map(
                        (category) => ListTile(
                          title: Text(
                            category,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(sheetContext).colorScheme.onSurface,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          onTap: () {
                            setStateSheet(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ),
                    if (selectedCategory != null)
                      ...[
                        Text(
                          'Categoria: $selectedCategory',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: descriptionController,
                          autofocus: true,
                          style: TextStyle(
                            color: Theme.of(sheetContext).colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escreva a descrição...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final desc = descriptionController.text.trim();
                              if (desc.isNotEmpty) {
                                _addTag(providerContext, '$selectedCategory: $desc');
                                Navigator.pop(sheetContext);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                            ),
                            child: Text(
                              'Adicionar',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              setStateSheet(() {
                                selectedCategory = null;
                                descriptionController.clear();
                              });
                            },
                            child: Text(
                              'Voltar para categorias',
                              style: TextStyle(
                                color: Theme.of(
                                  sheetContext,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      descriptionController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: const AppHeader(
          mode: HeaderMode.back,
          title: 'Condições médicas',
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, __, ___) {
                if (!_isInitialized) {
                  setState(() {
                    _tags = List<String>.from(
                      profile.medicalRestrictions ?? [],
                    );
                    _isInitialized = true;
                  });
                }
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (profile, _, __, ___) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adicione informações importantes para sua viagem, como condições médicas, uso contínuo de medicamentos, alergias, restrições alimentares, limitações de mobilidade ou fobias.\n\nSe necessário, leve medicação extra e prescrição médica durante a viagem.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddInformationSheet(context),
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Adicionar informação',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _tags.length,
                          itemBuilder: (context, index) {
                            final tag = _tags[index];
                            final parts = tag.split(': ');
                            final category =
                                parts.length > 1 ? parts.first : 'Outro';
                            final description =
                                parts.length > 1
                                    ? parts.sublist(1).join(': ')
                                    : tag;

                            return Card(
                              elevation: 0,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.05),
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  category,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    description,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () => _removeTag(context, tag),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Center(
                          child: Text(
                            'Suas informações são salvas automaticamente.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const MedicalShimmer(),
            );
          },
        ),
      ),
    );
  }
}
