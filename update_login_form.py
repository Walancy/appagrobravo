import re

file_path = '/home/ideasprosolus/agrobravo-app-viajante/appagrobravo/lib/features/auth/presentation/widgets/login_form.dart'

with open(file_path, 'r') as f:
    content = f.read()

# 1. Add _localErrorMessage and didUpdateWidget
class_state_pattern = r'class _LoginFormState extends State<LoginForm> \{'
state_replacement = '''class _LoginFormState extends State<LoginForm> {
  String? _localErrorMessage;

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorMessage != oldWidget.errorMessage) {
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
    }
  }'''
content = content.replace('class _LoginFormState extends State<LoginForm> {', state_replacement)

# Initialize _localErrorMessage in initState
init_state_pattern = r'super\.initState\(\);'
content = content.replace('super.initState();', 'super.initState();\n    _localErrorMessage = widget.errorMessage;')

# Replace widget.errorMessage with _localErrorMessage
content = content.replace('if (widget.errorMessage != null) ...[', 'if (_localErrorMessage != null) ...[')
content = content.replace('widget.errorMessage!,', '_localErrorMessage!,')

# Add onChanged and hasError to AppTextField
content = re.sub(
    r'(AppTextField\()',
    r'\1\n        onChanged: _clearError,\n        hasError: _localErrorMessage != null,',
    content
)

# Replace "Esqueci minha senha" text and spacing
# The login row currently looks like:
# Row(
#   children: [
#     _buildCheckbox(...),
#     const SizedBox(width: AppSpacing.xs),
#     Flexible(
#       child: Text(
#         'Lembrar conta',...
#       ),
#     ),
#     const SizedBox(width: AppSpacing.xs),
#     TextButton(...
#       child: Text(
#         'Esqueci minha senha',
# ...

row_pattern = r'Row\(\s*children: \[\s*_buildCheckbox\('
row_replacement = r'''Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox('''

content = content.replace('''Row(
        children: [
          _buildCheckbox(''','''Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox(''')

textbutton_pattern = r'const SizedBox\(width: AppSpacing\.xs\),\s*TextButton\('
textbutton_replacement = r'''],
          ),
          TextButton('''

content = re.sub(r'const SizedBox\(width: AppSpacing\.xs\),\s*TextButton\(', textbutton_replacement, content)

content = content.replace("'Esqueci minha senha'", "'Esqueceu senha'")


with open(file_path, 'w') as f:
    f.write(content)

print("Modifications done.")
