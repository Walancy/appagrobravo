import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';

class MedicalRestrictionsPage extends StatefulWidget {
  const MedicalRestrictionsPage({super.key});

  @override
  State<MedicalRestrictionsPage> createState() =>
      _MedicalRestrictionsPageState();
}

class _MedicalRestrictionsPageState extends State<MedicalRestrictionsPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const AppHeader(
          mode: HeaderMode.back,
          title: 'Restrições médicas',
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, __, ___) {
                if (_controller.text.isEmpty &&
                    profile.medicalRestrictions != null) {
                  _controller.text = profile.medicalRestrictions!.join(', ');
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
                      Row(
                        children: [
                          const Icon(
                            Icons.health_and_safety_outlined,
                            color: AppColors.error,
                            size: 28,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Sua saúde é prioridade',
                            style: AppTextStyles.h3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Informe alergias, condições crônicas ou medicamentos de uso contínuo para sua segurança durante a missão.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _controller,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText:
                              'Ex: Alergia a amendoim, uso contínuo de insulina, intolerância a lactose...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.backgroundLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.backgroundLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFAFAFA),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProfileCubit>()
                                .updateMedicalRestrictions(_controller.text);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Informações salvas com segurança!',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Salvar Informações',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
