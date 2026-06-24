import 'package:flutter/material.dart';

/// Converte o nome do ícone vindo da API (biblioteca Lucide do painel web)
/// para o [IconData] correspondente do Material Icons.
class TravelGuideIconMapper {
  TravelGuideIconMapper._();

  static IconData fromName(String name) {
    return _map[name] ?? Icons.info_outline;
  }

  static const Map<String, IconData> _map = {
    'MapPin': Icons.location_on,
    'Plane': Icons.flight,
    'Luggage': Icons.luggage,
    'Shield': Icons.shield,
    'Hotel': Icons.hotel,
    'Utensils': Icons.restaurant,
    'Calendar': Icons.calendar_today,
    'Phone': Icons.phone,
    'CreditCard': Icons.credit_card,
    'Wifi': Icons.wifi,
    'AlertTriangle': Icons.warning_amber,
    'Info': Icons.info_outline,
    'Clock': Icons.access_time,
    'Camera': Icons.camera_alt,
    'Users': Icons.group,
    'Sun': Icons.wb_sunny,
    'DollarSign': Icons.attach_money,
    'Bus': Icons.directions_bus,
    'Train': Icons.train,
    'Car': Icons.directions_car,
    'Ship': Icons.directions_boat,
    'Compass': Icons.explore,
    'Map': Icons.map,
    'Globe': Icons.language,
    'Heart': Icons.favorite_border,
    'Check': Icons.check_circle_outline,
    'Key': Icons.key,
    'Lock': Icons.lock_outline,
    'Bed': Icons.bed,
    'Coffee': Icons.coffee,
    'Music': Icons.music_note,
    'Moon': Icons.nightlight_round,
    'Flag': Icons.flag,
    'Gift': Icons.card_giftcard,
    'ShoppingBag': Icons.shopping_bag,
    'Mountain': Icons.terrain,
    'Ticket': Icons.confirmation_number,
    'Anchor': Icons.anchor,
    'Umbrella': Icons.umbrella,
    'Activity': Icons.monitor_heart,
    'HelpCircle': Icons.help_outline,
    'MessageSquare': Icons.chat_bubble_outline,
    'Milestone': Icons.flag_outlined,
    'Wine': Icons.wine_bar,
    'Palmtree': Icons.park,
  };
}
