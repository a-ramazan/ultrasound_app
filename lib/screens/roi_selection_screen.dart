import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/roi_box.dart';
import '../services/analysis_api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/roi_selector.dart';
import 'result_screen.dart';

class RoiSelectionScreen extends StatefulWidget {
  const RoiSelectionScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<RoiSelectionScreen> createState() => _RoiSelectionScreenState();
}

class _RoiSelectionScreenState extends State<RoiSelectionScreen> {
  final AnalysisApiService _api = const AnalysisApiService();

  Rect? _displayRoi;
  Size? _imageSize;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  Future<void> _resolveImageSize() async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(widget.imageBytes, completer.complete);
    final ui.Image image = await completer.future;
    if (!mounted) {
      return;
    }
    setState(() {
      _imageSize = Size(image.width.toDouble(), image.height.toDouble());
    });
  }

  Future<void> _analyze() async {
    if (_displayRoi == null || _imageSize == null || _isAnalyzing) {
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final area = RoiBox.fromRect(_displayRoi!);
      final result = await _api.analyze(
        imageBytes: widget.imageBytes,
        roi: area,
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось выполнить анализ: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GradientScaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: PrimaryActionButton(
          label: _isAnalyzing ? 'Выполняем анализ...' : 'Запустить анализ',
          icon: Icons.analytics_outlined,
          onPressed: _displayRoi == null || _imageSize == null || _isAnalyzing
              ? null
              : _analyze,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 780;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
                    child: const Text(
                      'Область интереса',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Область интереса', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 20),
              GlassPanel(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: compact ? 320 : 420,
                  child: _imageSize == null
                      ? const Center(child: CircularProgressIndicator())
                      : RoiSelector(
                          imageBytes: widget.imageBytes,
                          imageSize: _imageSize!,
                          onChanged: (rect) {
                            setState(() {
                              _displayRoi = rect;
                            });
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
