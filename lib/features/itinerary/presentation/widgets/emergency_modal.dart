import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agrobravo/core/tokens/app_spacing.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/features/itinerary/domain/repositories/itinerary_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:agrobravo/features/itinerary/domain/entities/emergency_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyModal extends StatefulWidget {
  const EmergencyModal({super.key});

  @override
  State<EmergencyModal> createState() => _EmergencyModalState();
}

class _EmergencyModalState extends State<EmergencyModal> {
  bool _loading = true;
  String? _error;
  EmergencyContacts? _contacts;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      // 1. Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permissão de localização negada';
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permissão de localização permanentemente negada';
          _loading = false;
        });
        return;
      }

      // 2. Get position
      Position position = await Geolocator.getCurrentPosition();

      // 3. fetch from repo directly to avoid Provider scope issues
      final repo = GetIt.I<ItineraryRepository>();
      final result = await repo.getEmergencyContacts(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        result.fold(
          (failure) => setState(() {
            _error = failure.toString();
            _loading = false;
          }),
          (contacts) => setState(() {
            _contacts = contacts;
            _loading = false;
          }),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar contatos: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _makeCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.emergency_rounded,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Canais de Emergência',
                    style: AppTextStyles.h3.copyWith(fontSize: 20),
                  ),
                ),
              ],
            ),
            if (_contacts?.countryName != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Localização atual: ${_contacts!.countryName}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _loadContacts,
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )
            else if (_contacts != null)
              Column(
                children: [
                  _buildEmergencyItem(
                    icon: Icons.local_police_rounded,
                    label: 'Polícia',
                    number: _contacts!.police,
                    color: Colors.blue[800]!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildEmergencyItem(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Bombeiros',
                    number: _contacts!.firefighters,
                    color: Colors.orange[800]!,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildEmergencyItem(
                    icon: Icons.medical_services_rounded,
                    label: 'Emergência Médica',
                    number: _contacts!.medical,
                    color: Colors.red[800]!,
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyItem({
    required IconData icon,
    required String label,
    required String number,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _makeCall(number),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    number,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.phone_enabled_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
