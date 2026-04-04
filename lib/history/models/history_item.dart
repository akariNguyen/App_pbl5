import 'dart:convert';

class HistoryItem {
  final String id;
  final String imagePath;
  final String className;
  final int classId;
  final double confidence;
  final DateTime createdAt;

  final String? vietnameseName;
  final String? scientificName;
  final String? family;
  final String? overview;
  final String? identification;
  final String? careGuide;

  const HistoryItem({
    required this.id,
    required this.imagePath,
    required this.className,
    required this.classId,
    required this.confidence,
    required this.createdAt,
    this.vietnameseName,
    this.scientificName,
    this.family,
    this.overview,
    this.identification,
    this.careGuide,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'className': className,
      'classId': classId,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
      'vietnameseName': vietnameseName,
      'scientificName': scientificName,
      'family': family,
      'overview': overview,
      'identification': identification,
      'careGuide': careGuide,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as String,
      imagePath: map['imagePath'] as String,
      className: map['className'] as String,
      classId: map['classId'] as int,
      confidence: (map['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      vietnameseName: map['vietnameseName'] as String?,
      scientificName: map['scientificName'] as String?,
      family: map['family'] as String?,
      overview: map['overview'] as String?,
      identification: map['identification'] as String?,
      careGuide: map['careGuide'] as String?,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory HistoryItem.fromJson(String source) =>
      HistoryItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
}