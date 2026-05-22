class AddressCountry {
  final String name;
  final String flag;
  final String code; // ISO 3166-1 alpha-2

  const AddressCountry({
    required this.name,
    required this.flag,
    required this.code,
  });
}

class BrazilianState {
  final String uf;
  final String name;

  const BrazilianState({required this.uf, required this.name});
}

const AddressCountry kDefaultAddressCountry = AddressCountry(
  name: 'Brasil',
  flag: '🇧🇷',
  code: 'BR',
);

const List<AddressCountry> kAddressCountries = [
  AddressCountry(name: 'Brasil', flag: '🇧🇷', code: 'BR'),
  AddressCountry(name: 'África do Sul', flag: '🇿🇦', code: 'ZA'),
  AddressCountry(name: 'Alemanha', flag: '🇩🇪', code: 'DE'),
  AddressCountry(name: 'Angola', flag: '🇦🇴', code: 'AO'),
  AddressCountry(name: 'Argentina', flag: '🇦🇷', code: 'AR'),
  AddressCountry(name: 'Austrália', flag: '🇦🇺', code: 'AU'),
  AddressCountry(name: 'Áustria', flag: '🇦🇹', code: 'AT'),
  AddressCountry(name: 'Bélgica', flag: '🇧🇪', code: 'BE'),
  AddressCountry(name: 'Bolívia', flag: '🇧🇴', code: 'BO'),
  AddressCountry(name: 'Canadá', flag: '🇨🇦', code: 'CA'),
  AddressCountry(name: 'Chile', flag: '🇨🇱', code: 'CL'),
  AddressCountry(name: 'China', flag: '🇨🇳', code: 'CN'),
  AddressCountry(name: 'Colômbia', flag: '🇨🇴', code: 'CO'),
  AddressCountry(name: 'Coreia do Sul', flag: '🇰🇷', code: 'KR'),
  AddressCountry(name: 'Costa Rica', flag: '🇨🇷', code: 'CR'),
  AddressCountry(name: 'Cuba', flag: '🇨🇺', code: 'CU'),
  AddressCountry(name: 'Equador', flag: '🇪🇨', code: 'EC'),
  AddressCountry(name: 'Espanha', flag: '🇪🇸', code: 'ES'),
  AddressCountry(name: 'Estados Unidos', flag: '🇺🇸', code: 'US'),
  AddressCountry(name: 'França', flag: '🇫🇷', code: 'FR'),
  AddressCountry(name: 'Guatemala', flag: '🇬🇹', code: 'GT'),
  AddressCountry(name: 'Honduras', flag: '🇭🇳', code: 'HN'),
  AddressCountry(name: 'Índia', flag: '🇮🇳', code: 'IN'),
  AddressCountry(name: 'Israel', flag: '🇮🇱', code: 'IL'),
  AddressCountry(name: 'Itália', flag: '🇮🇹', code: 'IT'),
  AddressCountry(name: 'Japão', flag: '🇯🇵', code: 'JP'),
  AddressCountry(name: 'México', flag: '🇲🇽', code: 'MX'),
  AddressCountry(name: 'Moçambique', flag: '🇲🇿', code: 'MZ'),
  AddressCountry(name: 'Nigéria', flag: '🇳🇬', code: 'NG'),
  AddressCountry(name: 'Noruega', flag: '🇳🇴', code: 'NO'),
  AddressCountry(name: 'Panamá', flag: '🇵🇦', code: 'PA'),
  AddressCountry(name: 'Paraguai', flag: '🇵🇾', code: 'PY'),
  AddressCountry(name: 'Peru', flag: '🇵🇪', code: 'PE'),
  AddressCountry(name: 'Portugal', flag: '🇵🇹', code: 'PT'),
  AddressCountry(name: 'Reino Unido', flag: '🇬🇧', code: 'GB'),
  AddressCountry(name: 'República Dominicana', flag: '🇩🇴', code: 'DO'),
  AddressCountry(name: 'Suíça', flag: '🇨🇭', code: 'CH'),
  AddressCountry(name: 'Uruguai', flag: '🇺🇾', code: 'UY'),
  AddressCountry(name: 'Venezuela', flag: '🇻🇪', code: 'VE'),
];

const List<BrazilianState> kBrazilianStates = [
  BrazilianState(uf: 'AC', name: 'Acre'),
  BrazilianState(uf: 'AL', name: 'Alagoas'),
  BrazilianState(uf: 'AP', name: 'Amapá'),
  BrazilianState(uf: 'AM', name: 'Amazonas'),
  BrazilianState(uf: 'BA', name: 'Bahia'),
  BrazilianState(uf: 'CE', name: 'Ceará'),
  BrazilianState(uf: 'DF', name: 'Distrito Federal'),
  BrazilianState(uf: 'ES', name: 'Espírito Santo'),
  BrazilianState(uf: 'GO', name: 'Goiás'),
  BrazilianState(uf: 'MA', name: 'Maranhão'),
  BrazilianState(uf: 'MT', name: 'Mato Grosso'),
  BrazilianState(uf: 'MS', name: 'Mato Grosso do Sul'),
  BrazilianState(uf: 'MG', name: 'Minas Gerais'),
  BrazilianState(uf: 'PA', name: 'Pará'),
  BrazilianState(uf: 'PB', name: 'Paraíba'),
  BrazilianState(uf: 'PR', name: 'Paraná'),
  BrazilianState(uf: 'PE', name: 'Pernambuco'),
  BrazilianState(uf: 'PI', name: 'Piauí'),
  BrazilianState(uf: 'RJ', name: 'Rio de Janeiro'),
  BrazilianState(uf: 'RN', name: 'Rio Grande do Norte'),
  BrazilianState(uf: 'RS', name: 'Rio Grande do Sul'),
  BrazilianState(uf: 'RO', name: 'Rondônia'),
  BrazilianState(uf: 'RR', name: 'Roraima'),
  BrazilianState(uf: 'SC', name: 'Santa Catarina'),
  BrazilianState(uf: 'SP', name: 'São Paulo'),
  BrazilianState(uf: 'SE', name: 'Sergipe'),
  BrazilianState(uf: 'TO', name: 'Tocantins'),
];
