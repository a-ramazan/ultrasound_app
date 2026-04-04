import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass_panel.dart';

class ImagePreviewCard extends StatelessWidget {
  const ImagePreviewCard({
    super.key,
    required this.imageBytes,
    this.height = 360,
    this.badgeLabel = 'Segmented ultrasound',
    this.fit = BoxFit.contain,
  });

  final Uint8List imageBytes;
  final double height;
  final String badgeLabel;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: const Color(0xFFDDEFF3),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              imageBytes,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Не удалось отобразить изображение',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.deepNavy.withValues(alpha: 0.05),
                    AppColors.deepNavy.withValues(alpha: 0.32),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      badgeLabel,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
