import 'class_result.dart';

class ClassifyResponse {
  final String topClass;
  final double topConfidence;
  final List<ClassResult> results;
  final double inferenceMs;

  const ClassifyResponse({
    required this.topClass,
    required this.topConfidence,
    required this.results,
    required this.inferenceMs,
  });

  factory ClassifyResponse.fromJson(Map<String, dynamic> json) {
    return ClassifyResponse(
      topClass: json['top_class'] as String,
      topConfidence: (json['top_confidence'] as num).toDouble(),
      results: (json['results'] as List)
          .map((e) => ClassResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      inferenceMs: (json['inference_ms'] as num).toDouble(),
    );
  }
}