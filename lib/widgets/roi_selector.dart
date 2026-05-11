import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RoiSelector extends StatefulWidget {
  const RoiSelector({
    super.key,
    required this.imageBytes,
    required this.imageSize,
    required this.onChanged,
  });

  final Uint8List imageBytes;
  final Size imageSize;
  final ValueChanged<Rect?> onChanged;

  @override
  State<RoiSelector> createState() => _RoiSelectorState();
}

class _RoiSelectorState extends State<RoiSelector> {
  final CropController _controller = CropController();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Crop(
        image: widget.imageBytes,
        controller: _controller,
        onCropped: (_) {},
        onMoved: (_, imageRect) {
          widget.onChanged(imageRect);
        },
        initialRectBuilder: InitialRectBuilder.withBuilder((
          viewportRect,
          imageRect,
        ) {
          final width = imageRect.width * 0.52;
          final height = imageRect.height * 0.42;
          final left = imageRect.left + (imageRect.width - width) / 2;
          final top = imageRect.top + (imageRect.height - height) / 2;
          return Rect.fromLTWH(left, top, width, height);
        }),
        maskColor: AppColors.deepNavy.withValues(alpha: 0.22),
        baseColor: const Color(0xFFD9E8ED),
        radius: 18,
        cornerDotBuilder: (size, edgeAlignment) {
          return Container(
            width: size + 12,
            height: size + 12,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryDark, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
