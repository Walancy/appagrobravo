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
  List<String> _tags = [];
  bool _isInitialized = false;

  void _addTag(String text) {
    if (text.isEmpty) return;
    if (!_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _controller.clear();
      });
      _saveTags();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _saveTags();
  }

  void _saveTags() {
    context.read<ProfileCubit>().updateFoodPreferences(_tags);
  }

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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: const AppHeader(
          mode: HeaderMode.back,
          title: 'Preferências alimentares',
        ),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, __, ___) {
                if (!_isInitialized) {
                  setState(() {
                    _tags = List<String>.from(profile.foodPreferences ?? []);
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
                        'Conte-nos sobre seus gostos',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Adicione tags para indicar suas preferências alimentares (ex: Vegetariano, Sem Pimenta).',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: _controller,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Adicione uma preferência...',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _addTag(_controller.text.trim()),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                        onSubmitted: (value) => _addTag(value.trim()),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: AppTextStyles.bodySmall,
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _removeTag(tag),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            'Suas preferências são salvas automaticamente.',
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
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
