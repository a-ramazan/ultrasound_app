import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/image_preview_card.dart';
import '../widgets/primary_action_button.dart';
import 'upload_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final AnalysisResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;
    final statusColor = result.isNormal ? AppColors.success : AppColors.warning;

    return GradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: PrimaryActionButton(
          label: 'Загрузить новое изображение',
          icon: Icons.add_photo_alternate_outlined,
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const UploadScreen()),
              (route) => false,
            );
          },
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 780;
          final previewHeight = compact ? 190.0 : 240.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              result.isNormal
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.error_outline_rounded,
                              color: statusColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              result.label,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Результат анализа',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Сервер выполнил сегментацию выделенной области и предсказал класс для выбранного ROI.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<bool>(
                              value: true,
                              label: Text('Сегментация'),
                            ),
                            ButtonSegment<bool>(
                              value: false,
                              label: Text('Оригинал'),
                            ),
                          ],
                          selected: {_showOverlay},
                          onSelectionChanged: (selection) {
                            setState(() {
                              _showOverlay = selection.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ImagePreviewCard(
                    imageBytes: _showOverlay
                        ? result.overlayImageBytes
                        : result.originalImageBytes,
                    height: previewHeight,
                    badgeLabel: _showOverlay
                        ? 'Segmented ultrasound'
                        : 'Original image',
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: compact ? 16 : 20),
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            result.label,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          result.isNormal
                              ? 'ROI классифицирован как норма'
                              : 'ROI классифицирован как патология',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: 'Предсказанный класс',
                                value: result.predictedClass,
                                accentColor: statusColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _MetricCard(
                                label: 'Уверенность',
                                value: '${result.confidence}%',
                                accentColor: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.analytics_outlined,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Уверенность результата: ${result.confidence}%',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          result.explanation,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
