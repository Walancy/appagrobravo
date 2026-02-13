import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';

class DocumentAlert extends StatelessWidget {
  final VoidCallback onTap;

  const DocumentAlert({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.amber.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: Colors.amber.shade900,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Documentação Pendente',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Atualize seus documentos para evitar problemas na viagem.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber.shade900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.amber.shade900,
            ),
          ],
        ),
      ),
    );
  }
}
