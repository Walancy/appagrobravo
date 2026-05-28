class MissionMaterialEntity {
  final String id;
  final String name;
  final String? size;
  final String url;
  final String tipo; // 'arquivo' | 'form'
  final bool hasUserResponse; // true se o usuário já respondeu (apenas para tipo='form')
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MissionMaterialEntity({
    required this.id,
    required this.name,
    this.size,
    required this.url,
    this.tipo = 'arquivo',
    this.hasUserResponse = false,
    this.createdAt,
    this.updatedAt,
  });

  factory MissionMaterialEntity.fromJson(Map<String, dynamic> json) {
    return MissionMaterialEntity(
      id: json['id']?.toString() ?? '',
      name: json['nome']?.toString() ?? 'Material',
      size: json['tamanho']?.toString(),
      url: json['url']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'arquivo',
      hasUserResponse: json['hasUserResponse'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  MissionMaterialEntity copyWith({bool? hasUserResponse}) {
    return MissionMaterialEntity(
      id: id,
      name: name,
      size: size,
      url: url,
      tipo: tipo,
      hasUserResponse: hasUserResponse ?? this.hasUserResponse,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'tamanho': size,
      'url': url,
      'tipo': tipo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
