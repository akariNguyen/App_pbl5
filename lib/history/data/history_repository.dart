import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_item.dart';

class HistoryRepository {
  static const _historyKey = 'orchid_history';

  Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_historyKey) ?? [];

    final items = rawList.map((e) => HistoryItem.fromJson(e)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  Future<void> saveHistoryItem({
    required File sourceImageFile,
    required String className,
    required int classId,
    required double confidence,
    String? vietnameseName,
    String? scientificName,
    String? family,
    String? overview,
    String? identification,
    String? careGuide,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();

    final savedImagePath = await _copyImageToLocal(sourceImageFile);

    final item = HistoryItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      imagePath: savedImagePath,
      className: className,
      classId: classId,
      confidence: confidence,
      createdAt: DateTime.now(),
      vietnameseName: vietnameseName,
      scientificName: scientificName,
      family: family,
      overview: overview,
      identification: identification,
      careGuide: careGuide,
    );

    final updated = [item, ...current];
    final encoded = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> deleteHistoryItem(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();

    final item = current
        .where((e) => e.id == id)
        .cast<HistoryItem?>()
        .firstOrNull;
    if (item != null) {
      final file = File(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final updated = current.where((e) => e.id != id).toList();
    final encoded = updated.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();

    for (final item in current) {
      final file = File(item.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await prefs.remove(_historyKey);
  }

  Future<String> _copyImageToLocal(File sourceFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final historyDir = Directory('${appDir.path}/history_images');

    if (!await historyDir.exists()) {
      await historyDir.create(recursive: true);
    }

    final ext = _getExtension(sourceFile.path);
    final newPath =
        '${historyDir.path}/img_${DateTime.now().microsecondsSinceEpoch}$ext';

    final copied = await sourceFile.copy(newPath);
    return copied.path;
  }

  String _getExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    return path.substring(dot);
  }
}

extension on Iterable {
  dynamic get firstOrNull => isEmpty ? null : first;
}
