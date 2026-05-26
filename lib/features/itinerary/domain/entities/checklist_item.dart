class ChecklistItemEntity {
  final String id;
  final String groupId;
  final String titulo;
  final DateTime? createdAt;
  bool isChecked;

  ChecklistItemEntity({
    required this.id,
    required this.groupId,
    required this.titulo,
    this.createdAt,
    this.isChecked = false,
  });
}
