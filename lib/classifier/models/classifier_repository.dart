import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'classify_response.dart';

class ClassifierRepository {
  Future<ClassifyResponse> classifyImage({
    File? imageFile,
    String? cropId,
  }) async {
    final uri = Uri.parse('$kServerUrl/classify?topk=5');
    final request = http.MultipartRequest('POST', uri);

    if (cropId != null) {
      request.fields['crop_id'] = cropId;
    }
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamed = await request.send().timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Server không phản hồi (timeout 45s)\nKiểm tra mạng.',
      ),
    );

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Lỗi server ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return ClassifyResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> detectAndCropImage(File imageFile) async {
    final uri = Uri.parse('$kServerUrl/detect?conf_thres=0.25&iou_thres=0.45');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send().timeout(
      const Duration(seconds: 45),
      onTimeout: () => throw Exception(
        'Server detect không phản hồi (timeout 45s)\nKiểm tra mạng.',
      ),
    );

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 404) {
      throw Exception('Lỗi detect ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    if (json['detected'] == false) {
      throw Exception(json['message'] ?? 'YOLO không phát hiện được hoa');
    }

    final croppedBase64 = json['cropped_image_base64'] as String?;
    final cropId = json['crop_id'] as String?;

    if (croppedBase64 == null || croppedBase64.isEmpty) {
      throw Exception('Server không trả về ảnh đã crop.');
    }

    final bytes = base64Decode(croppedBase64);
    final tempFile = File(
      '${Directory.systemTemp.path}/orchid_detect_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(bytes, flush: true);

    return {'file': tempFile, 'crop_id': cropId};
  }

  Future<Map<String, dynamic>> detectAndClassify(File imageFile) async {
    final uri = Uri.parse('$kServerUrl/detect_and_classify?topk=5');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send().timeout(
      const Duration(seconds: 90), // cần nhiều thời gian hợn vì chạy 2 model
      onTimeout: () => throw Exception(
        'Server không phản hồi (timeout 90s)\nKiểm tra mạng.',
      ),
    );

    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200 && streamed.statusCode != 404) {
      throw Exception('Lỗi server ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;

    if (json['detected'] == false) {
      throw Exception(json['message'] ?? 'YOLO không phát hiện được hoa');
    }

    final croppedBase64 = json['cropped_image_base64'] as String?;
    final cropId = json['crop_id'] as String?;
    final classificationJson = json['classification'] as Map<String, dynamic>?;

    if (croppedBase64 == null || croppedBase64.isEmpty) {
      throw Exception('Server không trả về ảnh đã crop.');
    }
    if (classificationJson == null) {
      throw Exception('Chưa có kết quả phân loại.');
    }

    final bytes = base64Decode(croppedBase64);
    final tempFile = File(
      '${Directory.systemTemp.path}/orchid_detect_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await tempFile.writeAsBytes(bytes, flush: true);

    return {
      'file': tempFile,
      'crop_id': cropId,
      'response': ClassifyResponse.fromJson(classificationJson),
    };
  }

  Future<String?> loadOrchidInfoByClassId(int classId) async {
    try {
      final classKey = 'class${classId.toString().padLeft(4, '0')}';
      final uri = Uri.parse('$kServerUrl/categories/$classKey');

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw Exception('Server không phản hồi khi tải thông tin hoa.'),
          );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(
          json['detail'] ??
              json['message'] ??
              'Không tải được thông tin hoa từ server.',
        );
      }

      return json['markdown'] as String?;
    } catch (e) {
      debugPrint('🔥 ERROR loadOrchidInfoByClassId: $e');
      return null;
    }
  }

  Future<List<String>> loadExampleImagesByClassId(
    int classId, {
    int limit = 5,
  }) async {
    try {
      final classKey = 'class${classId.toString().padLeft(4, '0')}';
      final uri = Uri.parse('$kServerUrl/categories/$classKey');

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw Exception('Server không phản hồi khi tải ảnh minh họa.'),
          );

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw Exception(
          json['detail'] ??
              json['message'] ??
              'Không tải được ảnh minh họa từ server.',
        );
      }

      final imageUrls = (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      if (imageUrls.isEmpty) {
        debugPrint('❌ KHÔNG có ảnh từ server cho $classKey');
        return [];
      }

      imageUrls.shuffle(Random());
      return imageUrls.take(limit).toList();
    } catch (e) {
      debugPrint('🔥 ERROR loadExampleImagesByClassId: $e');
      return [];
    }
  }
}
