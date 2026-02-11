import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';

class FoodPreferencesPage extends StatefulWidget {
  const FoodPreferencesPage({super.key});

  @override
  State<FoodPreferencesPage> createState() => _FoodPreferencesPageState();
}

class _FoodPreferencesPageState extends State<FoodPreferencesPage> {
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
          title: 'Preferências alimentares',
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, __, ___) {
                if (_controller.text.isEmpty &&
                    profile.foodPreferences != null) {
                  _controller.text = profile.foodPreferences!.join(', ');
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
                        'Conte-nos sobre seus gostos',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Suas preferências ajudam a AgroBravo a preparar as melhores experiências gastronômicas para você.',
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
                              'Ex: Prefiro pratos vegetarianos, não gosto de pimenta, amo café...',
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
                            context.read<ProfileCubit>().updateFoodPreferences(
                              _controller.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Preferências salvas com sucesso!',
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
                            'Salvar Alterações',
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
