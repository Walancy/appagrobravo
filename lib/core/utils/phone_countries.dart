class PhoneCountry {
  final String name;
  final String code; // ISO 3166-1 alpha-2
  final String dialCode;
  final String mask;

  const PhoneCountry({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.mask,
  });
}

const PhoneCountry kDefaultPhoneCountry = PhoneCountry(
  name: 'Brasil',
  code: 'BR',
  dialCode: '+55',
  mask: '(##) #####-####',
);

const List<PhoneCountry> kPhoneCountries = [
  PhoneCountry(name: 'Brasil', code: 'BR', dialCode: '+55', mask: '(##) #####-####'),
  PhoneCountry(name: 'Argentina', code: 'AR', dialCode: '+54', mask: '(###) ###-####'),
  PhoneCountry(name: 'Austrália', code: 'AU', dialCode: '+61', mask: '#### ### ###'),
  PhoneCountry(name: 'Alemanha', code: 'DE', dialCode: '+49', mask: '#### ########'),
  PhoneCountry(name: 'Bolívia', code: 'BO', dialCode: '+591', mask: '# ### ####'),
  PhoneCountry(name: 'Canadá', code: 'CA', dialCode: '+1', mask: '(###) ###-####'),
  PhoneCountry(name: 'Chile', code: 'CL', dialCode: '+56', mask: '# ####-####'),
  PhoneCountry(name: 'China', code: 'CN', dialCode: '+86', mask: '### #### ####'),
  PhoneCountry(name: 'Colômbia', code: 'CO', dialCode: '+57', mask: '### ### ####'),
  PhoneCountry(name: 'Coreia do Sul', code: 'KR', dialCode: '+82', mask: '##-####-####'),
  PhoneCountry(name: 'Equador', code: 'EC', dialCode: '+593', mask: '## ### ####'),
  PhoneCountry(name: 'Espanha', code: 'ES', dialCode: '+34', mask: '### ### ###'),
  PhoneCountry(name: 'Estados Unidos', code: 'US', dialCode: '+1', mask: '(###) ###-####'),
  PhoneCountry(name: 'França', code: 'FR', dialCode: '+33', mask: '## ## ## ## ##'),
  PhoneCountry(name: 'Israel', code: 'IL', dialCode: '+972', mask: '##-###-####'),
  PhoneCountry(name: 'Itália', code: 'IT', dialCode: '+39', mask: '### #######'),
  PhoneCountry(name: 'Japão', code: 'JP', dialCode: '+81', mask: '##-####-####'),
  PhoneCountry(name: 'México', code: 'MX', dialCode: '+52', mask: '(##) ####-####'),
  PhoneCountry(name: 'Paraguai', code: 'PY', dialCode: '+595', mask: '### ### ###'),
  PhoneCountry(name: 'Peru', code: 'PE', dialCode: '+51', mask: '### ### ###'),
  PhoneCountry(name: 'Portugal', code: 'PT', dialCode: '+351', mask: '### ### ###'),
  PhoneCountry(name: 'Reino Unido', code: 'GB', dialCode: '+44', mask: '#### ### ####'),
  PhoneCountry(name: 'África do Sul', code: 'ZA', dialCode: '+27', mask: '## ### ####'),
  PhoneCountry(name: 'Uruguai', code: 'UY', dialCode: '+598', mask: '## ### ####'),
  PhoneCountry(name: 'Venezuela', code: 'VE', dialCode: '+58', mask: '(###) ###-####'),
];
