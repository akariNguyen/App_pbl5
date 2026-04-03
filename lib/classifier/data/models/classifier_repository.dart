import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/classify_response.dart';

class ClassifierRepository {
  Future<ClassifyResponse> classifyImage(File imageFile) async {
    final uri = Uri.parse('$kServerUrl/classify?topk=5');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send().timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Server không phản hồi (timeout 45s)\nKiểm tra kết nối internet hoặc trạng thái Raspberry Pi.',
      ),
    );

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Lỗi server ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return ClassifyResponse.fromJson(json);
  }

  Future<File> detectAndCropImage(File imageFile) async {
    final uri = Uri.parse('$kServerUrl/detect?conf_thres=0.25&iou_thres=0.45');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send().timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Server detect không phản hồi (timeout 45s)\nKiểm tra kết nối internet hoặc trạng thái Raspberry Pi.',
      ),
    );

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Lỗi detect ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final croppedBase64 = json['cropped_image_base64'] as String?;

    if (croppedBase64 == null || croppedBase64.isEmpty) {
      throw Exception('Server không trả về ảnh đã crop.');
    }

    final bytes = base64Decode(croppedBase64);

    final tempFile = File(
      '${Directory.systemTemp.path}/orchid_detect_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await tempFile.writeAsBytes(bytes, flush: true);
    return tempFile;
  }

  Future<String?> loadOrchidInfoByClassId(int classId) async {
    try {
      final fileName =
          'lib/classifier/data/infor/class${classId.toString().padLeft(4, '0')}.md';
      return await rootBundle.loadString(fileName);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> loadExampleImagesByClassId(
    int classId, {
    int limit = 5,
  }) async {
    try {
      final classFolder =
          'lib/classifier/data/category/class${classId.toString().padLeft(4, '0')}/';

      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      final imagePaths = allAssets.where((path) {
        final lower = path.toLowerCase();
        return path.startsWith(classFolder) &&
            (lower.endsWith('.png') ||
                lower.endsWith('.jpg') ||
                lower.endsWith('.jpeg') ||
                lower.endsWith('.webp'));
      }).toList();

      if (imagePaths.isEmpty) {
        debugPrint('❌ KHÔNG tìm thấy ảnh cho $classFolder');
        debugPrint('CLASS FOLDER = $classFolder');
        debugPrint('TOTAL ASSETS = ${allAssets.length}');
        debugPrint(
          allAssets
              .where((e) => e.contains('lib/classifier/data/category'))
              .join('\n'),
        );
        return [];
      }

      debugPrint('✅ FOUND: $imagePaths');

      imagePaths.shuffle(Random());
      return imagePaths.take(limit).toList();
    } catch (e) {
      debugPrint('🔥 ERROR loadExampleImages: $e');
      return [];
    }
  }
}
