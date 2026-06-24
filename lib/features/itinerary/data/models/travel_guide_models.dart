/// Modelos de dados para o Guia de Viagem.

class TravelGuideCard {
  final String id;
  final String guiaId;
  final String titulo;
  final String icone;
  final String descricao;
  final String? imagem;
  final int ordem;
  bool concluido;
  DateTime? checkedAt;

  TravelGuideCard({
    required this.id,
    required this.guiaId,
    required this.titulo,
    required this.icone,
    required this.descricao,
    this.imagem,
    required this.ordem,
    this.concluido = false,
    this.checkedAt,
  });

  factory TravelGuideCard.fromJson(Map<String, dynamic> json) => TravelGuideCard(
        id: json['id'] as String,
        guiaId: json['guia_id'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        icone: json['icone'] as String? ?? 'Info',
        descricao: json['descricao'] as String? ?? '',
        imagem: json['imagem'] as String?,
        ordem: json['ordem'] as int? ?? 0,
      );
}

class TravelGuide {
  final String id;
  final String grupoId;
  final String titulo;
  final String status;
  final List<TravelGuideCard> cards;
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelGuide({
    required this.id,
    required this.grupoId,
    required this.titulo,
    required this.status,
    required this.cards,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isVisible => status == 'Visivel';

  factory TravelGuide.fromJson(Map<String, dynamic> json) => TravelGuide(
        id: json['id'] as String,
        grupoId: json['grupo_id'] as String? ?? '',
        titulo: json['titulo'] as String? ?? 'Guia de Viagem',
        status: json['status'] as String? ?? 'Oculto',
        cards: (json['guia_viagem_cards'] as List<dynamic>? ?? [])
            .map((c) => TravelGuideCard.fromJson(c as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.ordem.compareTo(b.ordem)),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

class CardCheck {
  final String cardId;
  final bool concluido;
  final DateTime? checkedAt;

  CardCheck.fromJson(Map<String, dynamic> json)
      : cardId = json['card_id'] as String? ?? '',
        concluido = json['concluido'] as bool? ?? false,
        checkedAt = json['checked_at'] != null
            ? DateTime.tryParse(json['checked_at'] as String)
            : null;
}
