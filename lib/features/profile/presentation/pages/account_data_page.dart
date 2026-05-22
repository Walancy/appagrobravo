import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/phone_field.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/utils/phone_countries.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';

class AccountDataPage extends StatefulWidget {
  const AccountDataPage({super.key});

  @override
  State<AccountDataPage> createState() => _AccountDataPageState();
}

class _AccountDataPageState extends State<AccountDataPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _ssnController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();
  final _badgeNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _countryController = TextEditingController();
  final _companyController = TextEditingController();
  DateTime? _birthDate;

  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  PhoneCountry _phoneCountry = kDefaultPhoneCountry;
  PhoneCountry _emergencyCountry = kDefaultPhoneCountry;

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _ssnController.dispose();
    _zipCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _badgeNameController.dispose();
    _emergencyContactController.dispose();
    _countryController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  /// Tries to extract a [PhoneCountry] and number portion from a stored phone
  /// string like "+55 (11) 99999-9999". Falls back to Brazil.
  (PhoneCountry, String) _parsePhone(String? raw) {
    if (raw == null || raw.isEmpty) return (kDefaultPhoneCountry, '');
    for (final c in kPhoneCountries) {
      final prefix = '${c.dialCode} ';
      if (raw.startsWith(prefix)) return (c, raw.substring(prefix.length));
    }
    return (kDefaultPhoneCountry, raw);
  }

  void _initializeControllers(ProfileEntity profile) {
    if (_initialized) return;
    _nameController.text = profile.name;
    _cpfController.text = _cpfMaskFormatter.maskText(profile.cpf ?? '');
    _ssnController.text = profile.ssn ?? '';
    _zipCodeController.text = profile.zipCode ?? '';
    _stateController.text = profile.state ?? '';
    _cityController.text = profile.city ?? '';
    _streetController.text = profile.street ?? '';
    _numberController.text = profile.number ?? '';
    _neighborhoodController.text = profile.neighborhood ?? '';
    _complementController.text = profile.complement ?? '';
    _badgeNameController.text = profile.badgeName ?? '';
    _countryController.text = profile.country ?? '';
    _companyController.text = profile.company ?? '';
    _birthDate = profile.birthDate;

    final (phoneCo, phoneNum) = _parsePhone(profile.phone);
    final (emergCo, emergNum) = _parsePhone(profile.emergencyContact);
    _phoneCountry = phoneCo;
    _phoneController.text = phoneNum;
    _emergencyCountry = emergCo;
    _emergencyContactController.text = emergNum;

    _initialized = true;
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..loadProfile(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: const AppHeader(mode: HeaderMode.back, title: 'Dados da conta'),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, _, _) {
                _initializeControllers(profile);
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loaded: (profile, _, _, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        context,
                        _nameController,
                        'Nome Completo',
                      ),
                      _buildTextField(
                        context,
                        _badgeNameController,
                        'Nome para o Crachá',
                      ),
                      PhoneField(
                        controller: _phoneController,
                        label: 'Telefone',
                        initialCountry: _phoneCountry,
                        onCountryChanged: (c) =>
                            setState(() => _phoneCountry = c),
                      ),
                      PhoneField(
                        controller: _emergencyContactController,
                        label: 'Contato de Emergência',
                        initialCountry: _emergencyCountry,
                        onCountryChanged: (c) =>
                            setState(() => _emergencyCountry = c),
                      ),
                      _buildTextField(context, _companyController, 'Empresa'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              _cpfController,
                              'CPF',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTextField(
                              context,
                              _ssnController,
                              'SSN',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),
                      _buildDatePicker(context, 'Data de Nascimento'),

                      const SizedBox(height: AppSpacing.lg),
                      _buildTextField(
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              _stateController,
                              'Estado',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildTextField(
                              context,
                              _cityController,
                              'Cidade',
                            ),
                          ),
                        ],
                      ),
                      _buildTextField(
                        context,
                        _neighborhoodController,
                        'Bairro',
                      ),
                      _buildTextField(context, _streetController, 'Rua'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              context,
                              _numberController,
                              'Número',
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              context,
                              _complementController,
                              'Complemento',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final data = {
                              'name': _nameController.text,
                              'phone':
                                  '${_phoneCountry.dialCode} ${_phoneController.text}',
                              'cpf': _cpfController.text,
                              'ssn': _ssnController.text,
                              'company': _companyController.text,
                              'zipCode': _zipCodeController.text,
                              'state': _stateController.text,
                              'city': _cityController.text,
                              'street': _streetController.text,
                              'number': _numberController.text,
                              'neighborhood': _neighborhoodController.text,
                              'complement': _complementController.text,
                              'country': _countryController.text,
                              'badgeName': _badgeNameController.text,
                              'emergencyContact':
                                  '${_emergencyCountry.dialCode} ${_emergencyContactController.text}',
                              if (_birthDate != null) 'birthDate': _birthDate,
                            };
                            context.read<ProfileCubit>().updateAccountData(
                              data,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dados atualizados com sucesso!'),
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
                      const SizedBox(height: AppSpacing.xl),
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

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface
                  : const Color(0xFFFAFAFA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            inputFormatters: inputFormatters,
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: () => _selectBirthDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _birthDate == null
                        ? 'Selecionar data'
                        : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
