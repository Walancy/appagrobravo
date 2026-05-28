class FormFieldEntity {
  final String id;
  final String materialId;
  final String tipo; // 'texto_curto' | 'texto_longo' | 'multipla_escolha' | 'checkbox' | 'nota'
  final String label;
  final bool obrigatorio;
  final List<String> opcoes;
  final int ordem;

  const FormFieldEntity({
    required this.id,
    required this.materialId,
    required this.tipo,
    required this.label,
    required this.obrigatorio,
    required this.opcoes,
    required this.ordem,
  });

  factory FormFieldEntity.fromJson(Map<String, dynamic> json) {
    final opcoesRaw = json['opcoes'];
    List<String> opcoes = [];
    if (opcoesRaw is List) {
      opcoes = opcoesRaw.map((e) => e.toString()).toList();
    }
    return FormFieldEntity(
      id: json['id']?.toString() ?? '',
      materialId: json['material_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'texto_curto',
      label: json['label']?.toString() ?? '',
      obrigatorio: json['obrigatorio'] as bool? ?? false,
      opcoes: opcoes,
      ordem: json['ordem'] as int? ?? 0,
    );
  }
}
