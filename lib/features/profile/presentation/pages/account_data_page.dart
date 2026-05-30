import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/components/app_header.dart';
import 'package:agrobravo/core/components/phone_field.dart';
import 'package:agrobravo/core/di/injection.dart';
import 'package:agrobravo/core/utils/address_data.dart';
import 'package:agrobravo/core/utils/phone_countries.dart';
import 'package:agrobravo/features/profile/domain/entities/profile_entity.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:agrobravo/features/profile/presentation/cubit/profile_state.dart';
import 'package:agrobravo/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:country_flags/country_flags.dart';
import 'package:agrobravo/core/components/account_data_shimmer.dart';

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
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();
  final _badgeNameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationshipController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _stateTextController = TextEditingController();
  final _companyController = TextEditingController();

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cepMask = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {'#': RegExp(r'[0-9]')},
  );

  PhoneCountry _phoneCountry = kDefaultPhoneCountry;
  PhoneCountry _emergencyCountry = kDefaultPhoneCountry;
  AddressCountry _selectedCountry = kDefaultAddressCountry;
  AddressCountry? _nationalityCountry;
  String? _selectedStateUf;

  bool _loadingCep = false;
  bool _initialized = false;
  bool _isSaving = false;
  bool _attemptedSave = false;
  Map<String, dynamic> _initialData = {};

  List<TextEditingController> get _allControllers => [
        _nameController, _phoneController, _cpfController, _ssnController,
        _zipCodeController, _cityController, _streetController, _numberController,
        _neighborhoodController, _complementController, _badgeNameController,
        _emergencyNameController, _emergencyRelationshipController, _emergencyContactController, _stateTextController, _companyController,
      ];

  void _onInputChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
    for (var c in _allControllers) {
      c.addListener(_onInputChanged);
    }
    _zipCodeController.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    for (var c in _allControllers) {
      c.removeListener(_onInputChanged);
    }
    _zipCodeController.removeListener(_onCepChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _ssnController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _badgeNameController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationshipController.dispose();
    _emergencyContactController.dispose();
    _stateTextController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _onCepChanged() {
    final digits = _zipCodeController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 8 && _selectedCountry.code == 'BR') {
      _fetchCep(digits);
    }
  }

  Future<void> _fetchCep(String cep) async {
    if (_loadingCep) return;
    setState(() => _loadingCep = true);
    try {
      final res = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        if (!data.containsKey('erro')) {
          final uf = data['uf'] as String?;
          final state = uf != null
              ? kBrazilianStates.firstWhere(
                  (s) => s.uf == uf,
                  orElse: () => BrazilianState(uf: uf, name: uf),
                )
              : null;
          setState(() {
            _streetController.text = data['logradouro'] ?? '';
            _neighborhoodController.text = data['bairro'] ?? '';
            _cityController.text = data['localidade'] ?? '';
            if (state != null) _selectedStateUf = state.uf;
          });
        }
      }
    } catch (_) {
      // user can fill manually on failure
    } finally {
      if (mounted) setState(() => _loadingCep = false);
    }
  }

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
    _cpfController.text = _cpfMask.maskText(profile.cpf ?? '');
    _ssnController.text = profile.ssn ?? '';
    _cityController.text = profile.city ?? '';
    _streetController.text = profile.street ?? '';
    _numberController.text = profile.number ?? '';
    _neighborhoodController.text = profile.neighborhood ?? '';
    _complementController.text = profile.complement ?? '';
    _badgeNameController.text = profile.badgeName ?? '';
    _companyController.text = profile.company ?? '';
    _birthDate = profile.birthDate;

    // CEP — set without triggering the listener
    _zipCodeController.removeListener(_onCepChanged);
    _zipCodeController.text = _cepMask.maskText(
      (profile.zipCode ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
    );
    _zipCodeController.addListener(_onCepChanged);

    // Country
    final savedCountry = profile.country;
    if (savedCountry != null && savedCountry.isNotEmpty) {
      final match = kAddressCountries.firstWhere(
        (c) => c.name == savedCountry || c.code == savedCountry,
        orElse: () => kDefaultAddressCountry,
      );
      _selectedCountry = match;
    }

    // Nationality
    final savedNationality = profile.nationality;
    if (savedNationality != null && savedNationality.isNotEmpty) {
      final match = kAddressCountries.firstWhere(
        (c) => c.code == savedNationality,
        orElse: () => kDefaultAddressCountry,
      );
      _nationalityCountry = match;
    }

    // State
    final savedState = profile.state;
    if (savedState != null && savedState.isNotEmpty) {
      if (_selectedCountry.code == 'BR') {
        final match = kBrazilianStates.firstWhere(
          (s) => s.uf == savedState || s.name == savedState,
          orElse: () => BrazilianState(uf: savedState, name: savedState),
        );
        _selectedStateUf = match.uf;
      } else {
        _stateTextController.text = savedState;
      }
    }

    // Phones
    final (phoneCo, phoneNum) = _parsePhone(profile.phone);
    final (emergCo, emergNum) = _parsePhone(profile.emergencyContact);
    _phoneCountry = phoneCo;
    _phoneController.text = phoneNum;
    _emergencyCountry = emergCo;
    _emergencyContactController.text = emergNum;
    _emergencyNameController.text = profile.emergencyName ?? '';
    _emergencyRelationshipController.text = profile.emergencyRelationship ?? '';

    _initialized = true;
    _initialData = _getCurrentData();
  }

  DateTime? _birthDate;

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() => _birthDate = picked);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration(BuildContext context, {Widget? suffix, bool hasError = false, String? helperText}) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFAFAFA);
        
    final borderColor = hasError ? AppColors.error : Theme.of(context).dividerColor;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      suffixIcon: suffix,
      helperText: helperText,
      helperMaxLines: 3,
    );
  }

  Widget _label(BuildContext context, String text, {bool isMandatory = false}) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: RichText(
          text: TextSpan(
            text: text,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              if (isMandatory)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: AppColors.error),
                ),
            ],
          ),
        ),
      );

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    bool readOnly = false,
    bool isMandatory = false,
    String? helperText,
  }) {
    final hasError = _attemptedSave && isMandatory && controller.text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, label, isMandatory: isMandatory),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            readOnly: readOnly,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: _inputDecoration(context, suffix: suffixIcon, hasError: hasError, helperText: helperText),
          ),
        ],
      ),
    );
  }

  /// Generic bottom-sheet picker used for both country and state.
  Future<T?> _showPickerSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required Widget Function(T) flagOf,
    required bool Function(T) isSelected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet<T>(
        title: title,
        items: items,
        labelOf: labelOf,
        flagOf: flagOf,
        isSelected: isSelected,
      ),
    );
  }

  Widget _buildCountryDropdown(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFAFAFA);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, context.l10n.accountDataCountry, isMandatory: true),
          GestureDetector(
            onTap: () async {
              final result = await _showPickerSheet<AddressCountry>(
                context: context,
                title: context.l10n.accountDataCountryPickerTitle,
                items: kAddressCountries,
                labelOf: (c) => c.name,
                flagOf: (c) => CountryFlag.fromCountryCode(
                  c.code,
                  theme: const ImageTheme(width: 36, height: 24, shape: RoundedRectangle(3)),
                ),
                isSelected: (c) => c.code == _selectedCountry.code,
              );
              if (result != null && result.code != _selectedCountry.code) {
                setState(() {
                  _selectedCountry = result;
                  _selectedStateUf = null;
                  _stateTextController.clear();
                });
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _attemptedSave && _selectedCountry.code.trim().isEmpty ? AppColors.error : Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryFlag.fromCountryCode(
                        _selectedCountry.code,
                        theme: const ImageTheme(width: 24, height: 16, shape: RoundedRectangle(2)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedCountry.code,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalityDropdown(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFAFAFA);

    final hasError = _attemptedSave && _nationalityCountry == null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, context.l10n.accountDataNationality, isMandatory: true),
          GestureDetector(
            onTap: () async {
              final result = await _showPickerSheet<AddressCountry>(
                context: context,
                title: context.l10n.accountDataNationalityPickerTitle,
                items: kAddressCountries,
                labelOf: (c) => c.name,
                flagOf: (c) => CountryFlag.fromCountryCode(
                  c.code,
                  theme: const ImageTheme(width: 36, height: 24, shape: RoundedRectangle(3)),
                ),
                isSelected: (c) => c.code == (_nationalityCountry?.code ?? ''),
              );
              if (result != null) {
                setState(() {
                  _nationalityCountry = result;
                  // Clear document fields if nationality changed
                  if (result.code != 'BR') _cpfController.clear();
                  if (result.code != 'US') _ssnController.clear();
                });
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? AppColors.error
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  if (_nationalityCountry != null) ...[
                    CountryFlag.fromCountryCode(
                      _nationalityCountry!.code,
                      theme: const ImageTheme(width: 28, height: 18, shape: RoundedRectangle(3)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _nationalityCountry!.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    Expanded(
                      child: Text(
                        context.l10n.accountDataSelectPlaceholder,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateField(BuildContext context) {
    final isBrazil = _selectedCountry.code == 'BR';

    if (!isBrazil) {
      return _buildTextField(
        context,
        _stateTextController,
        context.l10n.accountDataStateNonBrazil,
        isMandatory: true,
      );
    }

    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surface
        : const Color(0xFFFAFAFA);

    final hasError = _attemptedSave && (_selectedStateUf ?? '').trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context, context.l10n.accountDataState, isMandatory: true),
          GestureDetector(
            onTap: () async {
              final result = await _showPickerSheet<BrazilianState>(
                context: context,
                title: context.l10n.accountDataStatePickerTitle,
                items: kBrazilianStates,
                labelOf: (s) => s.name,
                flagOf: (s) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      s.uf,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                isSelected: (s) => s.uf == _selectedStateUf,
              );
              if (result != null) {
                setState(() => _selectedStateUf = result.uf);
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasError ? AppColors.error : Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _selectedStateUf ?? '—',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _selectedStateUf != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                        fontWeight: _selectedStateUf != null ? FontWeight.w700 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
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
          _label(context, label, isMandatory: true),
          InkWell(
            onTap: () => _selectBirthDate(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _attemptedSave && _birthDate == null ? AppColors.error : Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _birthDate == null
                        ? context.l10n.accountDataSelectDate
                        : '${_birthDate!.day.toString().padLeft(2, '0')}/'
                            '${_birthDate!.month.toString().padLeft(2, '0')}/'
                            '${_birthDate!.year}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppHeader(mode: HeaderMode.back, title: context.l10n.accountDataTitle),
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.maybeWhen(
              loaded: (profile, _, _, _) {
                _initializeControllers(profile);
                if (_isSaving) {
                  setState(() => _isSaving = false);
                  // Reload the global ProfileCubit so the banner in HomePage
                  // (and other screens) updates immediately after returning.
                  context.read<ProfileCubit>().loadProfile();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.accountDataSuccessMessage),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              error: (message) {
                if (_isSaving) {
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => _initialized
                  ? _buildForm(context)
                  : const AccountDataShimmer(),
              error: (msg) => _initialized
                  ? _buildForm(context)
                  : Center(child: Text(msg)),
              orElse: () => _buildForm(context),
            );
          },
        ),
      );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              context.l10n.accountDataSaveReminder,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // ── Dados pessoais ──────────────────────────────────────────────
          _buildTextField(context, _nameController, context.l10n.accountDataFullName, isMandatory: true),
          _buildTextField(
            context,
            _badgeNameController,
            context.l10n.accountDataNickname,
            helperText: context.l10n.accountDataNicknameHelper,
          ),
          PhoneField(
            controller: _phoneController,
            label: context.l10n.accountDataPhone,
            initialCountry: _phoneCountry,
            onCountryChanged: (c) => setState(() => _phoneCountry = c),
            hasError: _attemptedSave && _phoneController.text.trim().isEmpty,
            isMandatory: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.health_and_safety_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    _buildSectionTitle(context, context.l10n.accountDataEmergencySection),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _buildTextField(context, _emergencyNameController, context.l10n.accountDataEmergencyName, isMandatory: true),
                _buildTextField(context, _emergencyRelationshipController, context.l10n.accountDataRelationship, isMandatory: true),
                PhoneField(
                  controller: _emergencyContactController,
                  label: context.l10n.accountDataEmergencyPhone,
                  initialCountry: _emergencyCountry,
                  onCountryChanged: (c) => setState(() => _emergencyCountry = c),
                  hasError: _attemptedSave && _emergencyContactController.text.trim().isEmpty,
                  isMandatory: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildTextField(context, _companyController, context.l10n.accountDataCompany),
          _buildNationalityDropdown(context),
          if (_nationalityCountry?.code == 'BR')
            _buildTextField(
              context,
              _cpfController,
              context.l10n.accountDataCpf,
              keyboardType: TextInputType.number,
              inputFormatters: [_cpfMask],
              isMandatory: true,
            )
          else if (_nationalityCountry?.code == 'US')
            _buildTextField(
              context,
              _ssnController,
              context.l10n.accountDataSsn,
              keyboardType: TextInputType.number,
              isMandatory: true,
            ),
          _buildDatePicker(context, context.l10n.accountDataBirthDate),

          // ── Endereço ────────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.xs),
                    _buildSectionTitle(context, context.l10n.accountDataAddressSection),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // CEP (expande) + País (compacto)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        context,
                        _zipCodeController,
                        context.l10n.accountDataZipCode,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_cepMask],
                        isMandatory: true,
                        suffixIcon: _loadingCep
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(width: 96, child: _buildCountryDropdown(context)),
                  ],
                ),

                // Estado (compacto se BR, expandido se outro país) + Cidade (expande)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCountry.code == 'BR')
                      SizedBox(width: 80, child: _buildStateField(context))
                    else
                      Expanded(child: _buildStateField(context)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _buildTextField(context, _cityController, context.l10n.accountDataCity, isMandatory: true),
                    ),
                  ],
                ),

                _buildTextField(context, _neighborhoodController, context.l10n.accountDataNeighborhood, isMandatory: true),
                _buildTextField(context, _streetController, context.l10n.accountDataStreet, isMandatory: true),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: _buildTextField(
                        context,
                        _numberController,
                        context.l10n.accountDataNumber,
                        keyboardType: TextInputType.number,
                        isMandatory: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTextField(
                        context,
                        _complementController,
                        context.l10n.accountDataComplement,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isSaving || !_hasChanges) ? null : () => _save(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.l10n.accountDataSaveButton,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => _showDeleteAccountDialog(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Text(
                context.l10n.accountDataDeleteAccount,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          context.l10n.accountDataDeleteTitle,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          context.l10n.accountDataDeleteMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              context.l10n.accountDataDeleteCancel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(
              context.l10n.accountDataDeleteConfirm,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Exibe loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final authCubit = getIt<AuthCubit>();
      final result = await authCubit.deleteAccount();

      if (context.mounted) {
        Navigator.pop(context); // Remove o loading
        result.fold(
          (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.accountDataDeleteError),
                backgroundColor: AppColors.error,
              ),
            );
          },
          (_) {
            // AuthCubit.deleteAccount() já fez logout e emitiu unauthenticated.
            // O roteador do app redireciona para a tela de login automaticamente.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.accountDataDeleteSuccess),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        );
      }
    }
  }

  Map<String, dynamic> _getCurrentData() {
    final stateValue = _selectedCountry.code == 'BR'
        ? (_selectedStateUf ?? '')
        : _stateTextController.text;

    return {
      'name': _nameController.text,
      'phone': '${_phoneCountry.dialCode} ${_phoneController.text}',
      'cpf': _cpfController.text,
      'ssn': _ssnController.text,
      'company': _companyController.text,
      'nationality': _nationalityCountry?.code ?? '',
      'zipCode': _zipCodeController.text,
      'state': stateValue,
      'city': _cityController.text,
      'street': _streetController.text,
      'number': _numberController.text,
      'neighborhood': _neighborhoodController.text,
      'complement': _complementController.text,
      'country': _selectedCountry.name,
      'badgeName': _badgeNameController.text,
      'emergencyName': _emergencyNameController.text,
      'emergencyRelationship': _emergencyRelationshipController.text,
      'emergencyContact':
          '${_emergencyCountry.dialCode} ${_emergencyContactController.text}',
      if (_birthDate != null) 'birthDate': _birthDate,
    };
  }

  bool get _hasChanges {
    if (!_initialized) return false;
    final currentData = _getCurrentData();
    for (final key in _initialData.keys) {
      if (_initialData[key] != currentData[key]) return true;
    }
    for (final key in currentData.keys) {
      if (_initialData[key] != currentData[key]) return true;
    }
    return false;
  }

  bool _validateFields() {
    final stateValue = _selectedCountry.code == 'BR'
        ? (_selectedStateUf ?? '')
        : _stateTextController.text;

    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emergencyNameController.text.trim().isEmpty ||
        _emergencyRelationshipController.text.trim().isEmpty ||
        _emergencyContactController.text.trim().isEmpty ||
        _zipCodeController.text.trim().isEmpty ||
        stateValue.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _neighborhoodController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _birthDate == null) {
      return false;
    }
    final nat = _nationalityCountry?.code;
    final cpfRequired = nat == null || nat == 'BR';
    final ssnRequired = nat == 'US';
    if (cpfRequired && _cpfController.text.trim().isEmpty) return false;
    if (ssnRequired && _ssnController.text.trim().isEmpty) return false;
    return true;
  }

  void _save(BuildContext context) {
    setState(() => _attemptedSave = true);
    if (!_validateFields()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.accountDataRequiredFieldsError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    context.read<ProfileCubit>().updateAccountData(_getCurrentData());
  }
}

// ── Generic picker bottom sheet ──────────────────────────────────────────────

class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final Widget Function(T) flagOf;
  final bool Function(T) isSelected;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.labelOf,
    required this.flagOf,
    required this.isSelected,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  final _search = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _filter(String q) {
    final lower = q.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((item) => widget.labelOf(item).toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bg = Theme.of(context).colorScheme.surface;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(
              widget.title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: _filter,
              style: TextStyle(color: onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.commonSearch,
                hintStyle:
                    TextStyle(color: onSurface.withValues(alpha: 0.45)),
                prefixIcon: Icon(
                  Icons.search,
                  color: onSurface.withValues(alpha: 0.45),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.surface
                    : const Color(0xFFF0F0F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final item = _filtered[i];
                final selected = widget.isSelected(item);
                return ListTile(
                  leading: widget.flagOf(item),
                  title: Text(
                    widget.labelOf(item),
                    style: TextStyle(
                      color: onSurface,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: selected,
                  selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                  onTap: () => Navigator.pop(context, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
