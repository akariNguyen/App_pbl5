class ClassResult {
  final int rank;
  final int classId;
  final String className;
  final double confidence;

  const ClassResult({
    required this.rank,
    required this.classId,
    required this.className,
    required this.confidence,
  });

  factory ClassResult.fromJson(Map<String, dynamic> json) {
    return ClassResult(
      rank: json['rank'] as int,
      classId: json['class_id'] as int,
      className: json['class_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}