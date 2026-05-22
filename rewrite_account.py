import re

with open('lib/features/profile/presentation/pages/account_data_page.dart', 'r') as f:
    content = f.read()

# Replace controllers declaration
content = re.sub(
    r'  final _nationalityController = TextEditingController\(\);\n  final _passportController = TextEditingController\(\);\n',
    r'  final _badgeNameController = TextEditingController();\n  final _emergencyContactController = TextEditingController();\n  final _countryController = TextEditingController();\n',
    content
)

# Replace dispose
content = re.sub(
    r'    _nationalityController\.dispose\(\);\n    _passportController\.dispose\(\);\n',
    r'    _badgeNameController.dispose();\n    _emergencyContactController.dispose();\n    _countryController.dispose();\n',
    content
)

# Replace initializeControllers
content = re.sub(
    r'    _nationalityController\.text = profile\.nationality \?\? \'\';\n    _passportController\.text = profile\.passport \?\? \'\';\n',
    r'    _badgeNameController.text = profile.badgeName ?? \'\';\n    _emergencyContactController.text = profile.emergencyContact ?? \'\';\n    _countryController.text = profile.country ?? \'\';\n',
    content
)

# Replace build widgets
# Finding the entire chunk from name controller to company
old_widgets = """                      _buildTextField(
                        context,
                        _nameController,
                        'Nome Completo',
                      ),
                      _buildTextField(
                        context,
                        _phoneController,
                        'Telefone',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(context, _companyController, 'Empresa'),"""

new_widgets = """                      _buildTextField(
                        context,
                        _nameController,
                        'Nome Completo',
                      ),
                      _buildTextField(
                        context,
                        _badgeNameController,
                        'Nome para o Crachá',
                      ),
                      _buildTextField(
                        context,
                        _phoneController,
                        'Telefone',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        context,
                        _emergencyContactController,
                        'Contato de Emergência',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(context, _companyController, 'Empresa'),"""

content = content.replace(old_widgets, new_widgets)

# Add country to address
old_address = """                      _buildTextField(
                        context,
                        _zipCodeController,
                        'CEP',
                        keyboardType: TextInputType.number,
                      ),
                      Row("""

new_address = """                      _buildTextField(
                        context,
                        _zipCodeController,
                        'CEP',
                        keyboardType: TextInputType.number,
                      ),
                      _buildTextField(
                        context,
                        _countryController,
                        'País',
                      ),
                      Row("""

content = content.replace(old_address, new_address)

# Remove nationality and passport text fields
remove_fields = """                      const SizedBox(height: AppSpacing.lg),
                      _buildTextField(
                        context,
                        _nationalityController,
                        'Nacionalidade',
                      ),
                      _buildTextField(
                        context,
                        _passportController,
                        'Passaporte',
                      ),

"""
content = content.replace(remove_fields, "")

# Update data map
old_data = """                              'complement': _complementController.text,
                              'nationality': _nationalityController.text,
                              'passport': _passportController.text,"""

new_data = """                              'complement': _complementController.text,
                              'country': _countryController.text,
                              'badgeName': _badgeNameController.text,
                              'emergencyContact': _emergencyContactController.text,"""
                              
content = content.replace(old_data, new_data)


with open('lib/features/profile/presentation/pages/account_data_page.dart', 'w') as f:
    f.write(content)

