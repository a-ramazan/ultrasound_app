class AnalysisResult {
  const AnalysisResult({
    required this.summary,
    required this.wallThicknessMm,
    required this.confidence,
    required this.explanation,
    required this.isNormal,
  });

  final String summary;
  final double wallThicknessMm;
  final int confidence;
  final String explanation;
  final bool isNormal;
}
