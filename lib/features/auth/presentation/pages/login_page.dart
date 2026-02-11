import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:agrobravo/core/tokens/assets.gen.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_state.dart';
import 'package:agrobravo/core/components/social_button.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  final AuthMode initialAuthMode;

  const LoginPage({super.key, this.initialAuthMode = AuthMode.login});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<Alignment> _logoAlignmentAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  late AuthMode _authMode;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialAuthMode;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 1. Logo aparece
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Logo sobe
    _logoAlignmentAnimation =
        Tween<Alignment>(
          begin: Alignment.center,
          end: const Alignment(0.0, -0.65),
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.8, curve: Curves.easeInOutCubic),
          ),
        );

    // 3. Form aparece
    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _authMode = mode;
    });
  }

  String _getTitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Login';
      case AuthMode.register:
        return 'Criar conta';
      case AuthMode.forgotPassword:
        return 'Recuperação';
      case AuthMode.resetPassword:
        return 'Nova senha';
      case AuthMode.success:
        return 'Sucesso!';
      case AuthMode.emailVerification:
        return 'Verifique seu email';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();
    final bool isSuccess = _authMode == AuthMode.success;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          authenticated: (user) {
            if (_authMode == AuthMode.resetPassword) return;

            if (user.isGuide) {
              // Navegar para Home do Guia
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bem-vindo, Guia ${user.name}!')),
              );
            } else {
              // Navegar para Home do Viajante
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bem-vindo, ${user.name}!')),
              );
            }
            context.go('/home');
          },
          error: (message) {
            // Feedback agora é exibido apenas via texto vermelho noLoginForm
          },
          passwordResetEmailSent: () {
            _switchMode(AuthMode.emailVerification);
          },
          passwordUpdated: () {
            _switchMode(AuthMode.success);
          },
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            // Overlay Escuro Simples
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

            // Logo Animada
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Align(
                  alignment: _logoAlignmentAnimation.value,
                  child: Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: SvgPicture.asset(
                      Assets.images.logoBranca,
                      width: 110,
                    ),
                  ),
                );
              },
            ),

            // Conteúdo Principal
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                if (_formFadeAnimation.value == 0)
                  return const SizedBox.shrink();

                final showSocials =
                    _authMode == AuthMode.login ||
                    _authMode == AuthMode.register;

                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: 40,
                    ),
                    child: Opacity(
                      opacity: _formFadeAnimation.value,
                      child: SlideTransition(
                        position: _formSlideAnimation,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 20),

                              // Título dinâmico
                              isSuccess
                                  ? Text(
                                      'Senha alterada com sucesso!',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.surface.withOpacity(
                                          0.9,
                                        ),
                                        fontWeight: FontWeight.w200,
                                        fontSize: 22,
                                      ),
                                    )
                                  : Text(
                                      title,
                                      style: AppTextStyles.h2.copyWith(
                                        color: AppColors.surface.withOpacity(
                                          0.9,
                                        ),
                                        fontWeight: FontWeight.w200,
                                        fontSize: 24,
                                      ),
                                    ),

                              const SizedBox(height: AppSpacing.sm),

                              // Card do Formulário
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state.maybeWhen(
                                    loading: () => true,
                                    orElse: () => false,
                                  );

                                  final errorMessage = state.maybeWhen(
                                    error: (message) => message,
                                    orElse: () => null,
                                  );

                                  return Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Opacity(
                                        opacity: isLoading ? 0.5 : 1.0,
                                        child: AbsorbPointer(
                                          absorbing: isLoading,
                                          child: LoginForm(
                                            authMode: _authMode,
                                            errorMessage: errorMessage,
                                            onForgotPasswordNavigation: () =>
                                                _switchMode(
                                                  AuthMode.forgotPassword,
                                                ),
                                            onLoginNavigation: () =>
                                                _switchMode(AuthMode.login),
                                            onRegisterNavigation: () =>
                                                _switchMode(AuthMode.register),
                                            onLoginAction: (email, password) {
                                              context.read<AuthCubit>().login(
                                                email,
                                                password,
                                              );
                                            },
                                            onRegisterAction:
                                                (
                                                  name,
                                                  email,
                                                  password,
                                                  confirm,
                                                ) {
                                                  context
                                                      .read<AuthCubit>()
                                                      .register(
                                                        name,
                                                        email,
                                                        password,
                                                        confirm,
                                                      );
                                                },
                                            onRecoverPasswordAction: (email) {
                                              context
                                                  .read<AuthCubit>()
                                                  .recoverPassword(email);
                                            },
                                            onResetPasswordAction:
                                                (password, confirm) {
                                                  context
                                                      .read<AuthCubit>()
                                                      .updatePassword(
                                                        password,
                                                        confirm,
                                                      );
                                                },
                                          ),
                                        ),
                                      ),
                                      if (isLoading)
                                        const CircularProgressIndicator(
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: AppSpacing.md),

                              if (showSocials) ...[
                                Text(
                                  'Ou continue com:',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.surface.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    SocialButton(
                                      label: 'Google',
                                      icon: SvgPicture.asset(
                                        'assets/images/google_logo.svg',
                                        width: 20,
                                        height: 20,
                                      ),
                                      onPressed: () => context
                                          .read<AuthCubit>()
                                          .loginWithGoogle(),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    SocialButton(
                                      label: 'Apple ID',
                                      icon: SvgPicture.asset(
                                        'assets/images/apple_logo.svg',
                                        width: 20,
                                        height: 24,
                                      ),
                                      onPressed: () => context
                                          .read<AuthCubit>()
                                          .loginWithApple(),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: AppSpacing.lg),

                              // Footer Link Dinâmico
                              _buildFooterLink(),

                              const SizedBox(height: AppSpacing.lg),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink() {
    switch (_authMode) {
      case AuthMode.login:
        return _buildTextLink(
          'Não possui uma conta? ',
          'Crie uma',
          () => _switchMode(AuthMode.register),
        );
      case AuthMode.register:
        return _buildTextLink(
          'Já possui uma conta? ',
          'Faça login',
          () => _switchMode(AuthMode.login),
        );
      case AuthMode.forgotPassword:
        return _buildSingleLink(
          'Voltar para login',
          () => _switchMode(AuthMode.login),
        );
      case AuthMode.resetPassword:
        return _buildSingleLink('Cancelar', () => _switchMode(AuthMode.login));
      case AuthMode.success:
      case AuthMode.emailVerification:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextLink(String text, String linkText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF00E676),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: const Color(0xFF00E676),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: const Color(0xFF00E676),
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF00E676),
        ),
      ),
    );
  }
}
