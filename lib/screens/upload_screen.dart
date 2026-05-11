import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/primary_action_button.dart';
import 'roi_selection_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) {
      return;
    }

    setState(() => _isPicking = true);

    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 92,
        maxWidth: 2200,
      );

      if (!mounted || image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();
      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RoiSelectionScreen(imageBytes: bytes),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 760;
          final heroPadding = compact ? 22.0 : 28.0;
          final titleStyle =
              (compact
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.displaySmall)
                  ?.copyWith(color: Colors.white);

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.waves_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SonoBowel', style: theme.textTheme.titleLarge),
                          Text(
                            'Bowel ultrasound',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 20 : 28),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(heroPadding),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x260E8F93),
                          blurRadius: 32,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'SonoBowel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        Text('Загрузите УЗИ-изображение', style: titleStyle),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 22),
                PrimaryActionButton(
                  label: _isPicking
                      ? 'Открываем галерею...'
                      : 'Выбрать из галереи',
                  icon: Icons.photo_library_outlined,
                  onPressed: _isPicking
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 12),
                PrimaryActionButton(
                  label: _isPicking ? 'Подготовка камеры...' : 'Сделать фото',
                  icon: Icons.photo_camera_outlined,
                  isSecondary: true,
                  onPressed: _isPicking
                      ? null
                      : () => _pickImage(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
