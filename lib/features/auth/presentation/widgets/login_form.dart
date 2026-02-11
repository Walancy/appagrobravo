import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/components/app_text_field.dart';
import 'package:agrobravo/core/components/primary_button.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';

class LoginForm extends StatefulWidget {
  final AuthMode authMode;
  final VoidCallback onForgotPasswordNavigation;
  final VoidCallback
  onLoginNavigation; // Navegação para Login (ex: sucesso -> login)
  final VoidCallback onRegisterNavigation; // Navegação para Registro

  // Ações de Submissão com Dados
  final void Function(String email, String password)? onLoginAction;
  final void Function(
    String name,
    String email,
    String password,
    String confirmPassword,
  )?
  onRegisterAction;
  final void Function(String email)? onRecoverPasswordAction;
  final void Function(String password, String confirmPassword)?
  onResetPasswordAction;
  final String? errorMessage; // Nova prop para erros

  const LoginForm({
    super.key,
    required this.authMode,
    required this.onForgotPasswordNavigation,
    required this.onLoginNavigation,
    required this.onRegisterNavigation,
    this.onLoginAction,
    this.onRegisterAction,
    this.onRecoverPasswordAction,
    this.onResetPasswordAction,
    this.errorMessage,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.surface.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._buildContent(),
              if (widget.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    switch (widget.authMode) {
      case AuthMode.login:
        return _buildLoginContent();
      case AuthMode.register:
        return _buildRegisterContent();
      case AuthMode.forgotPassword:
        return _buildForgotPasswordContent();
      case AuthMode.resetPassword:
        return _buildResetPasswordContent();
      case AuthMode.success:
        return _buildSuccessContent();
      case AuthMode.emailVerification:
        return _buildEmailVerificationContent();
    }
  }

  // --- Conteúdos Específicos ---

  List<Widget> _buildLoginContent() {
    return [
      AppTextField(
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          _buildCheckbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Lembrar conta',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surface,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onForgotPasswordNavigation,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Esqueci minha senha',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF00E676),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Entrar',
        onPressed: () {
          widget.onLoginAction?.call(
            _emailController.text,
            _passwordController.text,
          );
        },
      ),
    ];
  }

  List<Widget> _buildRegisterContent() {
    return [
      AppTextField(
        label: 'Nome e sobrenome:',
        hint: 'Seu nome e sobrenome',
        controller: _nameController,
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Confirmar senha:',
        hint: '**********',
        obscureText: _obscureConfirmPassword,
        controller: _confirmPasswordController,
        suffixIcon: _buildVisibilityIcon(false),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        children: [
          _buildCheckbox(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _termsAccepted = !_termsAccepted),
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface,
                    fontSize: 13,
                  ),
                  children: [
                    const TextSpan(text: 'Ao criar, você concorda com '),
                    TextSpan(
                      text: 'nossos termos e condições',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Criar',
        onPressed: () {
          if (!_termsAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aceite os termos para continuar')),
            );
            return;
          }
          widget.onRegisterAction?.call(
            _nameController.text,
            _emailController.text,
            _passwordController.text,
            _confirmPasswordController.text,
          );
        },
      ),
    ];
  }

  List<Widget> _buildForgotPasswordContent() {
    return [
      Text(
        'Insira o email da sua conta para recuperar sua senha',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Enviar',
        onPressed: () {
          widget.onRecoverPasswordAction?.call(_emailController.text);
        },
      ),
    ];
  }

  List<Widget> _buildResetPasswordContent() {
    return [
      Text(
        'Insira sua nova senha',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Nova senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        label: 'Confirmar senha:',
        hint: '**********',
        obscureText: _obscureConfirmPassword,
        controller: _confirmPasswordController,
        suffixIcon: _buildVisibilityIcon(false),
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Salvar',
        onPressed: () {
          widget.onResetPasswordAction?.call(
            _passwordController.text,
            _confirmPasswordController.text,
          );
        },
      ),
    ];
  }

  List<Widget> _buildSuccessContent() {
    return [
      Text(
        'Sua senha foi alterada com sucesso, faça login novamente para continuar',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Voltar para login',
        onPressed: widget.onLoginNavigation,
      ),
    ];
  }

  List<Widget> _buildEmailVerificationContent() {
    return [
      Text(
        'Enviamos um link de confirmação para o seu email. Por favor, verifique sua caixa de entrada.',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Voltar para login',
        onPressed: widget.onLoginNavigation,
      ),
    ];
  }

  // --- Helpers ---

  Widget _buildVisibilityIcon(bool isPassword) {
    final obscure = isPassword ? _obscurePassword : _obscureConfirmPassword;
    return IconButton(
      iconSize: 20,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.surface,
      ),
      onPressed: () {
        setState(() {
          if (isPassword) {
            _obscurePassword = !_obscurePassword;
          } else {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          }
        });
      },
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: AppColors.surface),
      child: SizedBox(
        height: 24,
        width: 24,
        child: Checkbox(
          value: value,
          activeColor: Colors.transparent,
          checkColor: AppColors.surface,
          side: const BorderSide(color: AppColors.surface, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
