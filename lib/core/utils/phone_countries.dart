class PhoneCountry {
  final String name;
  final String flag;
  final String dialCode;
  final String mask;

  const PhoneCountry({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.mask,
  });
}

const PhoneCountry kDefaultPhoneCountry = PhoneCountry(
  name: 'Brasil',
  flag: '🇧🇷',
  dialCode: '+55',
  mask: '(##) #####-####',
);

const List<PhoneCountry> kPhoneCountries = [
  PhoneCountry(name: 'Brasil', flag: '🇧🇷', dialCode: '+55', mask: '(##) #####-####'),
  PhoneCountry(name: 'Argentina', flag: '🇦🇷', dialCode: '+54', mask: '(###) ###-####'),
  PhoneCountry(name: 'Austrália', flag: '🇦🇺', dialCode: '+61', mask: '#### ### ###'),
  PhoneCountry(name: 'Alemanha', flag: '🇩🇪', dialCode: '+49', mask: '#### ########'),
  PhoneCountry(name: 'Bolívia', flag: '🇧🇴', dialCode: '+591', mask: '# ### ####'),
  PhoneCountry(name: 'Canadá', flag: '🇨🇦', dialCode: '+1', mask: '(###) ###-####'),
  PhoneCountry(name: 'Chile', flag: '🇨🇱', dialCode: '+56', mask: '# ####-####'),
  PhoneCountry(name: 'China', flag: '🇨🇳', dialCode: '+86', mask: '### #### ####'),
  PhoneCountry(name: 'Colômbia', flag: '🇨🇴', dialCode: '+57', mask: '### ### ####'),
  PhoneCountry(name: 'Coreia do Sul', flag: '🇰🇷', dialCode: '+82', mask: '##-####-####'),
  PhoneCountry(name: 'Equador', flag: '🇪🇨', dialCode: '+593', mask: '## ### ####'),
  PhoneCountry(name: 'Espanha', flag: '🇪🇸', dialCode: '+34', mask: '### ### ###'),
  PhoneCountry(name: 'Estados Unidos', flag: '🇺🇸', dialCode: '+1', mask: '(###) ###-####'),
  PhoneCountry(name: 'França', flag: '🇫🇷', dialCode: '+33', mask: '## ## ## ## ##'),
  PhoneCountry(name: 'Israel', flag: '🇮🇱', dialCode: '+972', mask: '##-###-####'),
  PhoneCountry(name: 'Itália', flag: '🇮🇹', dialCode: '+39', mask: '### #######'),
  PhoneCountry(name: 'Japão', flag: '🇯🇵', dialCode: '+81', mask: '##-####-####'),
  PhoneCountry(name: 'México', flag: '🇲🇽', dialCode: '+52', mask: '(##) ####-####'),
  PhoneCountry(name: 'Paraguai', flag: '🇵🇾', dialCode: '+595', mask: '### ### ###'),
  PhoneCountry(name: 'Peru', flag: '🇵🇪', dialCode: '+51', mask: '### ### ###'),
  PhoneCountry(name: 'Portugal', flag: '🇵🇹', dialCode: '+351', mask: '### ### ###'),
  PhoneCountry(name: 'Reino Unido', flag: '🇬🇧', dialCode: '+44', mask: '#### ### ####'),
  PhoneCountry(name: 'África do Sul', flag: '🇿🇦', dialCode: '+27', mask: '## ### ####'),
  PhoneCountry(name: 'Uruguai', flag: '🇺🇾', dialCode: '+598', mask: '## ### ####'),
  PhoneCountry(name: 'Venezuela', flag: '🇻🇪', dialCode: '+58', mask: '(###) ###-####'),
];
