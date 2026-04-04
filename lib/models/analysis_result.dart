import 'dart:convert';
import 'dart:typed_data';

class AnalysisResult {
  const AnalysisResult({
    required this.label,
    required this.confidence,
    required this.explanation,
    required this.isNormal,
    required this.originalImageBytes,
    required this.overlayImageBytes,
    required this.segmentationMaskBytes,
    required this.predictedClass,
  });

  final String label;
  final int confidence;
  final String explanation;
  final bool isNormal;
  final Uint8List originalImageBytes;
  final Uint8List overlayImageBytes;
  final Uint8List segmentationMaskBytes;
  final String predictedClass;

  factory AnalysisResult.fromApi({
    required Uint8List originalImageBytes,
    required String predictedClass,
    required double confidence,
    required String overlayImageBase64,
    required String segmentationMaskBase64,
  }) {
    final isNormal = predictedClass.toLowerCase() == 'normal';
    final roundedConfidence = (confidence * 100).round();

    return AnalysisResult(
      label: isNormal ? 'Норма' : 'Патология',
      confidence: roundedConfidence,
      explanation: isNormal
          ? 'Модель интерпретировала выделенную область как соответствующую норме.'
          : 'Модель выявила патологический класс в выделенной области и рекомендует дополнительную клиническую оценку.',
      isNormal: isNormal,
      originalImageBytes: originalImageBytes,
      overlayImageBytes: base64Decode(overlayImageBase64),
      segmentationMaskBytes: base64Decode(segmentationMaskBase64),
      predictedClass: predictedClass,
    );
  }
}
