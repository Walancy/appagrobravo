enum DocumentType {
  passaporte,
  visto,
  vacina,
  seguro,
  carteiraMotorista,
  autorizacaoMenores,
  outro;

  String get label {
    switch (this) {
      case DocumentType.passaporte:
        return 'Passaporte';
      case DocumentType.visto:
        return 'Visto';
      case DocumentType.vacina:
        return 'Vacina';
      case DocumentType.seguro:
        return 'Seguro';
      case DocumentType.carteiraMotorista:
        return 'Carteira de Motorista';
      case DocumentType.autorizacaoMenores:
        return 'Autorização de Menores';
      case DocumentType.outro:
        return 'Outro';
    }
  }

  static DocumentType fromString(String? value) {
    if (value == null) return DocumentType.outro;
    switch (value.toUpperCase()) {
      case 'PASSAPORTE':
        return DocumentType.passaporte;
      case 'VISTO':
        return DocumentType.visto;
      case 'VACINA':
        return DocumentType.vacina;
      case 'SEGURO':
        return DocumentType.seguro;
      case 'CARTEIRA_MOTORISTA':
        return DocumentType.carteiraMotorista;
      case 'AUTORIZACAO_MENORES':
        return DocumentType.autorizacaoMenores;
      default:
        return DocumentType.outro;
    }
  }
}

enum DocumentStatus {
  pendente,
  aprovado,
  recusado,
  expirado;

  String get label {
    switch (this) {
      case DocumentStatus.pendente:
        return 'Pendente';
      case DocumentStatus.aprovado:
        return 'Aprovado';
      case DocumentStatus.recusado:
        return 'Recusado';
      case DocumentStatus.expirado:
        return 'Expirado';
    }
  }

  static DocumentStatus fromString(String? value) {
    if (value == null) return DocumentStatus.pendente;
    switch (value.toUpperCase()) {
      case 'PENDENTE':
        return DocumentStatus.pendente;
      case 'APROVADO':
        return DocumentStatus.aprovado;
      case 'RECUSADO':
        return DocumentStatus.recusado;
      case 'EXPIRADO':
        return DocumentStatus.expirado;
      default:
        return DocumentStatus.pendente;
    }
  }
}
