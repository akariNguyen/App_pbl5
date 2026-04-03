import 'dart:convert';
import 'dart:io';

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

  Future<String?> loadOrchidInfoByClassId(int classId) async {
    try {
      final fileName =
          'lib/classifier/data/infor/class${classId.toString().padLeft(4, '0')}.md';
      return await rootBundle.loadString(fileName);
    } catch (_) {
      return null;
    }
  }
}