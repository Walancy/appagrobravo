import re

file_login_page = '/home/ideasprosolus/agrobravo-app-viajante/appagrobravo/lib/features/auth/presentation/pages/login_page.dart'
file_login_form = '/home/ideasprosolus/agrobravo-app-viajante/appagrobravo/lib/features/auth/presentation/widgets/login_form.dart'

with open(file_login_page, 'r') as f:
    content_page = f.read()

# 1. Update _getTitle
title_pattern = r"case AuthMode\.success:\n\s*return 'Sucesso!';\n    \}"
title_replacement = "case AuthMode.success:\n        return 'Sucesso!';\n      case AuthMode.registrationSuccess:\n        return 'Sua conta foi criada!';\n    }"
content_page = re.sub(title_pattern, title_replacement, content_page)

# 2. isSuccess boolean
issuccess_pattern = r'final bool isSuccess = _authMode == AuthMode\.success;'
issuccess_replacement = 'final bool isSuccess = _authMode == AuthMode.success || _authMode == AuthMode.registrationSuccess;'
content_page = re.sub(issuccess_pattern, issuccess_replacement, content_page)

# 3. registrationSuccess block in BlocListener
registration_listener_pattern = r'''registrationSuccess: \(message, needsEmailConfirmation\) \{
            if \(needsEmailConfirmation\) \{
              // Mostrar mensagem e voltar para login
              ScaffoldMessenger\.of\(context\)\.showSnackBar\(
                SnackBar\(
                  content: Text\(message\),
                  duration: const Duration\(seconds: 5\),
                  backgroundColor: AppColors\.primary,
                \),
              \);
              _switchMode\(AuthMode\.login\);
            \} else \{
              // Conta criada sem necessidade de confirmação → já pode logar
              context\.go\('/home'\);
            \}
          \},'''
registration_listener_replacement = '''registrationSuccess: (message, needsEmailConfirmation) {
            if (needsEmailConfirmation) {
              _switchMode(AuthMode.registrationSuccess);
            } else {
              context.go('/home');
            }
          },'''
content_page = re.sub(registration_listener_pattern, registration_listener_replacement, content_page)

# 4. _recoveryEmail in onRegisterAction
on_register_pattern = r'onRegisterAction:\n\s*\(\n\s*name,\n\s*email,\n\s*password,\n\s*confirm,\n\s*\) \{'
on_register_replacement = '''onRegisterAction:
                                                      (
                                                        name,
                                                        email,
                                                        password,
                                                        confirm,
                                                      ) {
                                                        _recoveryEmail = email;'''
content_page = re.sub(on_register_pattern, on_register_replacement, content_page)

# 5. Pass _recoveryEmail to LoginForm
form_call_pattern = r'errorMessage: errorMessage,'
form_call_replacement = 'errorMessage: errorMessage,\n                                                  registeredEmail: _recoveryEmail,'
content_page = content_page.replace(form_call_pattern, form_call_replacement)

# 6. footer link for registrationSuccess
footer_link_pattern = r'case AuthMode\.success:\n\s*return const SizedBox\.shrink\(\);\n    \}'
footer_link_replacement = 'case AuthMode.success:\n      case AuthMode.registrationSuccess:\n        return const SizedBox.shrink();\n    }'
content_page = re.sub(footer_link_pattern, footer_link_replacement, content_page)

# title logic for "Senha alterada com sucesso!" vs "Sua conta foi criada!"
# In login_page.dart line 258:
hardcode_title_pattern = r"'Senha alterada com sucesso!',"
hardcode_title_replacement = 'title,'
content_page = content_page.replace(hardcode_title_pattern, hardcode_title_replacement)

with open(file_login_page, 'w') as f:
    f.write(content_page)

# Now update login_form.dart
with open(file_login_form, 'r') as f:
    content_form = f.read()

# Add registeredEmail to LoginForm
form_class_pattern = 'final String? errorMessage; // Nova prop para erros'
form_class_replacement = 'final String? errorMessage; // Nova prop para erros\n  final String? registeredEmail;'
content_form = content_form.replace(form_class_pattern, form_class_replacement)

form_constructor_pattern = 'this.errorMessage,\n  });'
form_constructor_replacement = 'this.errorMessage,\n    this.registeredEmail,\n  });'
content_form = content_form.replace(form_constructor_pattern, form_constructor_replacement)

# Add AuthMode.registrationSuccess to switch
switch_pattern = r'case AuthMode\.success:\n\s*return _buildSuccessContent\(\);\n    \}'
switch_replacement = 'case AuthMode.success:\n        return _buildSuccessContent();\n      case AuthMode.registrationSuccess:\n        return _buildRegistrationSuccessContent();\n    }'
content_form = re.sub(switch_pattern, switch_replacement, content_form)

# Add _buildRegistrationSuccessContent method
build_reg_success = '''
  List<Widget> _buildRegistrationSuccessContent() {
    return [
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: 'Foi enviado um email para ',
              style: TextStyle(),
            ),
            TextSpan(
              text: widget.registeredEmail ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text: ' para você verificar na caixa de entrada ou spam e confirmar o e-mail antes de fazer o login.',
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
'''
content_form = content_form.rstrip()
if content_form.endswith('}'):
    content_form = content_form[:-1] + build_reg_success
else:
    content_form = content_form + build_reg_success

with open(file_login_form, 'w') as f:
    f.write(content_form)

print("Modifications done to page and form.")
