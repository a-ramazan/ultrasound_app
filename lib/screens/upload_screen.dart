import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/analysis_result.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/primary_action_button.dart';
import 'result_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const List<AnalysisResult> _results = [
    AnalysisResult(
      summary: 'Норма',
      wallThicknessMm: 2.4,
      confidence: 96,
      explanation:
          'Толщина стенки кишечника менее 3 мм. Показатель находится в пределах нормы.',
      isNormal: true,
    ),
    AnalysisResult(
      summary: 'Патологическое утолщение стенки',
      wallThicknessMm: 4.2,
      confidence: 91,
      explanation:
          'Толщина стенки кишечника превышает 3 мм. Рекомендуется клиническая оценка специалистом.',
      isNormal: false,
    ),
    AnalysisResult(
      summary: 'Патологическое утолщение стенки',
      wallThicknessMm: 5.1,
      confidence: 88,
      explanation:
          'Выявлено увеличение толщины стенки кишечника более 3 мм, что соответствует патологическим изменениям.',
      isNormal: false,
    ),
  ];

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
      final result = _results[DateTime.now().millisecond % _results.length];

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(imageBytes: bytes, result: result),
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
                            'Анализ стенки кишечника',
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
                            'Bowel wall thickness screening',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        Text('Загрузите УЗИ-изображение', style: titleStyle),
                        SizedBox(height: compact ? 10 : 16),
                        Text(
                          'После выбора снимка приложение покажет сегментацию стенки, измеренную толщину и уверенность результата.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: compact ? 44 : 52,
                                height: compact ? 44 : 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.straighten_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Порог нормы: толщина стенки менее 3 мм',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
