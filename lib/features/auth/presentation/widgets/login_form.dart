import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrobravo/core/components/app_text_field.dart';
import 'package:agrobravo/core/components/primary_button.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/auth/presentation/widgets/auth_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';

class LoginForm extends StatefulWidget {
  final AuthMode authMode;
  final VoidCallback onForgotPasswordNavigation;
  final VoidCallback
  onLoginNavigation; // Navegação para Login (ex: sucesso -> login)
  final VoidCallback onRegisterNavigation; // Navegação para Registro

  // Ações de Submissão com Dados
  final void Function(String email, String password, bool rememberMe)?
  onLoginAction;
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
  final void Function(String otp)? onVerifyOtpAction;
  final VoidCallback? onResendOtpAction;
  final void Function(String email)? onResendConfirmationAction;
  final void Function(String email)? onEmailChanged; // Notifica email digitado na tela OTP
  final String? errorMessage; // Nova prop para erros
  final String? registeredEmail;

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
    this.onVerifyOtpAction,
    this.onResendOtpAction,
    this.onResendConfirmationAction,
    this.onEmailChanged,
    this.errorMessage,
    this.registeredEmail,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? _localErrorMessage;

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.authMode != oldWidget.authMode) {
      setState(() {
        _localErrorMessage = null;
      });
    } else if (widget.errorMessage != oldWidget.errorMessage) {
      setState(() {
        _localErrorMessage = widget.errorMessage;
      });
    }
  }

  void _clearError(String _) {
    if (_localErrorMessage != null) {
      setState(() {
        _localErrorMessage = null;
      });
      context.read<AuthCubit>().clearError();
    }
  }
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // OTP Controllers (6 dígitos)
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // State
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _localErrorMessage = widget.errorMessage;
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    if (widget.authMode == AuthMode.login) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('remembered_email');
      if (email != null && mounted) {
        setState(() {
          _emailController.text = email;
          _rememberMe = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() {
    return _otpControllers.map((c) => c.text).join();
  }

  String _translateError(String? error) {
    if (error == null) return '';
    final lower = error.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (lower.contains('user already registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (lower.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (lower.contains('user not found')) {
      return 'Usuário ou e-mail não encontrado.';
    }
    if (lower.contains('email rate limit exceeded')) {
      return 'Muitas tentativas. Tente novamente mais tarde.';
    }
    return error; // fallback
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
              if (_localErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _translateError(_localErrorMessage),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_localErrorMessage == 'E-mail não confirmado. Verifique sua caixa de entrada.' && widget.authMode == AuthMode.login) ...[
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: () {
                      final email = _emailController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
                      if (email.isNotEmpty) {
                        widget.onResendConfirmationAction?.call(email);
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reenviar e-mail de confirmação',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF2ECC71),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF2ECC71),
                      ),
                    ),
                  ),
                ],
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
      case AuthMode.otpVerification:
        return _buildOtpVerificationContent();
      case AuthMode.resetPassword:
        return _buildResetPasswordContent();
      case AuthMode.success:
        return _buildSuccessContent();
      case AuthMode.registrationSuccess:
        return _buildRegistrationSuccessContent();
    }
  }

  // --- Conteúdos Específicos ---

  List<Widget> _buildLoginContent() {
    return [
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'Senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox(
            value: _rememberMe,
            onChanged: (v) => setState(() => _rememberMe = v ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              'Lembrar conta',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.surface,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ],
          ),
          TextButton(
            onPressed: widget.onForgotPasswordNavigation,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
            child: Text(
              'Esqueceu senha',
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xFF2ECC71),
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
            _emailController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''),
            _passwordController.text,
            _rememberMe,
          );
        },
      ),
    ];
  }

  List<Widget> _buildRegisterContent() {
    return [
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'Nome e sobrenome:',
        hint: 'Seu nome e sobrenome',
        controller: _nameController,
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'Senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
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
            _emailController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''),
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
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'E-mail:',
        hint: 'example@gmail.com',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        enableSuggestions: false,
        autofillHints: const [AutofillHints.email],
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Enviar',
        onPressed: () {
          widget.onRecoverPasswordAction?.call(_emailController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''));
        },
      ),
    ];
  }

  List<Widget> _buildOtpVerificationContent() {
    final bool needsEmail =
        widget.registeredEmail == null || widget.registeredEmail!.isEmpty;
    return [
      Text(
        'Enviamos um código de verificação para o seu email. Insira o código abaixo:',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.surface,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      if (needsEmail) ...[
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          onChanged: (value) {
            _clearError(value);
            widget.onEmailChanged?.call(value);
          },
          hasError: _localErrorMessage != null,
          label: 'E-mail:',
          hint: 'example@gmail.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (index) => _buildOtpDigitField(index)),
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Verificar',
        onPressed: () {
          final code = _getOtpCode();
          if (code.length == 6) {
            widget.onVerifyOtpAction?.call(code);
          }
        },
      ),
      const SizedBox(height: AppSpacing.sm),
      Center(
        child: TextButton(
          onPressed: () {
            if (needsEmail) {
              // Reenvia OTP usando o email digitado no campo
              widget.onRecoverPasswordAction?.call(_emailController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ''));
            } else {
              widget.onResendOtpAction?.call();
            }
          },
          child: Text(
            'Reenviar código',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF2ECC71),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildOtpDigitField(int index) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: AppTextStyles.h2.copyWith(
          color: AppColors.surface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: AppColors.surface.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: BorderSide(
              color: AppColors.surface.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            borderSide: const BorderSide(
              color: Color(0xFF00E676),
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
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
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
        label: 'Nova senha:',
        hint: '**********',
        obscureText: _obscurePassword,
        controller: _passwordController,
        suffixIcon: _buildVisibilityIcon(true),
      ),
      const SizedBox(height: AppSpacing.sm),
      AppTextField(
        onChanged: _clearError,
        hasError: _localErrorMessage != null,
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

  List<Widget> _buildRegistrationSuccessContent() {
    return [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Enviamos um e-mail de confirmação para ',
              style: TextStyle(),
            ),
            TextSpan(
              text: widget.registeredEmail ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: '. Verifique sua caixa de entrada e também a pasta de spam antes de fazer login.',
              style: TextStyle(),
            )
          ],
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface,
            fontSize: 14,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: 'Voltar ao login',
        onPressed: () {
          // Pre-fill the email in login
          if (widget.registeredEmail != null) {
            _emailController.text = widget.registeredEmail!;
          }
          widget.onLoginNavigation();
        },
      ),
    ];
  }
}
