/// Tipos de pergunta suportados pelo painel.
enum FormQuestionType {
  text,
  yesNo,
  checkbox,
  unknown;

  static FormQuestionType fromString(String? value) {
    switch (value) {
      case 'text':
        return FormQuestionType.text;
      case 'yes_no':
        return FormQuestionType.yesNo;
      case 'checkbox':
        return FormQuestionType.checkbox;
      default:
        return FormQuestionType.unknown;
    }
  }
}

/// Representa uma pergunta dentro do jsonb `perguntas` de grupoFormulario.
class PerguntaModel {
  final String id;
  final FormQuestionType type;
  final String title;
  final List<String> options; // usado em checkbox
  final bool required;
  /// Descrição/observação opcional exibida abaixo do título da pergunta.
  final String? descricao;

  const PerguntaModel({
    required this.id,
    required this.type,
    required this.title,
    required this.options,
    required this.required,
    this.descricao,
  });

  factory PerguntaModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final List<String> opts = rawOptions is List
        ? rawOptions
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
        : [];

    return PerguntaModel(
      id: json['id'] as String? ?? '',
      type: FormQuestionType.fromString(json['type'] as String?),
      title: json['title'] as String? ?? '',
      options: opts,
      required: json['required'] as bool? ?? false,
      descricao: json['descricao'] as String?,
    );
  }
}

/// Representa um formulário completo da tabela `grupoFormulario`.
class GrupoFormularioModel {
  final String id;
  final String grupoId;
  final String titulo;
  final String? descricao;
  final List<PerguntaModel> perguntas;
  final String status;

  const GrupoFormularioModel({
    required this.id,
    required this.grupoId,
    required this.titulo,
    this.descricao,
    required this.perguntas,
    required this.status,
  });

  factory GrupoFormularioModel.fromJson(Map<String, dynamic> json) {
    final rawPerguntas = json['perguntas'];
    final List<PerguntaModel> perguntas = rawPerguntas is List
        ? rawPerguntas
            .whereType<Map<String, dynamic>>()
            .map(PerguntaModel.fromJson)
            .where((p) => p.id.isNotEmpty && p.type != FormQuestionType.unknown)
            .toList()
        : [];

    return GrupoFormularioModel(
      id: json['id'] as String? ?? '',
      grupoId: json['grupo_id'] as String? ?? '',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String?,
      perguntas: perguntas,
      status: json['status'] as String? ?? '',
    );
  }

  bool get isVisible => status == 'Visivel';
}
