class MissionMaterialEntity {
  final String id;
  final String name;
  final String? size;
  final String url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MissionMaterialEntity({
    required this.id,
    required this.name,
    this.size,
    required this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory MissionMaterialEntity.fromJson(Map<String, dynamic> json) {
    return MissionMaterialEntity(
      id: json['id']?.toString() ?? '',
      name: json['nome']?.toString() ?? 'Material',
      size: json['tamanho']?.toString(),
      url: json['url']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'tamanho': size,
      'url': url,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
