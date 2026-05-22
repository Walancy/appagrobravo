import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:agrobravo/core/tokens/app_spacing.dart';

class AccountDataShimmer extends StatelessWidget {
  const AccountDataShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget box({double? width, required double height, double radius = 4}) =>
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );

    Widget labeledField({double? inputWidth}) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              box(width: 100, height: 11),
              const SizedBox(height: 4),
              inputWidth != null
                  ? box(width: inputWidth, height: 48, radius: 12)
                  : box(width: double.infinity, height: 48, radius: 12),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labeledField(),
          labeledField(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                box(width: 80, height: 48, radius: 12),
                const SizedBox(width: 8),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                box(width: 80, height: 48, radius: 12),
                const SizedBox(width: 8),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          labeledField(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: box(height: 48, radius: 12)),
                const SizedBox(width: 16),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                box(width: 100, height: 11),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: 20,
                            height: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                box(width: 130, height: 48, radius: 12),
                const SizedBox(width: 8),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: box(height: 48, radius: 12)),
                const SizedBox(width: 16),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          labeledField(),
          labeledField(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                box(width: 100, height: 48, radius: 12),
                const SizedBox(width: 16),
                Expanded(child: box(height: 48, radius: 12)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          box(width: double.infinity, height: 48, radius: 16),
        ],
      ),
    );
  }
}
