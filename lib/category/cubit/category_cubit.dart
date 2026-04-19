import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:orchid_classifier/core/constants/app_constants.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';
import 'package:orchid_classifier/history/models/history_item.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({
    required this.historyRepository,
  }) : super(const CategoryState());

  final HistoryRepository historyRepository;

  Future<void> init() async {
    await loadCategories();
    await loadCaptureHistory();
  }

  Future<void> refreshHistory() async {
    await loadCaptureHistory();
  }

  Future<void> loadCaptureHistory() async {
    try {
      final items = await historyRepository.getHistory();
      emit(state.copyWith(captureHistory: items));
    } catch (e) {
      debugPrint('Lỗi load capture history: $e');
    }
  }

  void changeKeyword(String value) {
    emit(state.copyWith(keyword: value));
  }

  void changeTopTab(int index) {
    emit(state.copyWith(selectedTab: index));
  }

  void backToCategoryList() {
    emit(
      state.copyWith(
        clearSelectedClass: true,
        isLoadingClassDetail: false,
      ),
    );
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(isLoading: true));

    try {
      final uri = Uri.parse('$kServerUrl/categories');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Load categories thất bại: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = (jsonData['categories'] as List<dynamic>? ?? []);

      final categories = rawList.map<Map<String, String>>((e) {
        final item = e as Map<String, dynamic>;

        final id = (item['id'] ?? '').toString();
        final name = (item['name'] ?? id).toString();

        return {
          'id': id,
          'name': name,
          'specie_name': (item['specie_name'] ?? '').toString(),
          'cultivar_chinese_name':
              (item['cultivar_chinese_name'] ?? '').toString(),
          'specie_chinese_name':
              (item['specie_chinese_name'] ?? '').toString(),
        };
      }).toList();

      final Map<String, String> coverImages = {};
      for (final e in rawList) {
        final item = e as Map<String, dynamic>;
        final id = (item['id'] ?? '').toString();
        final cover = item['cover_image']?.toString();

        if (id.isNotEmpty && cover != null && cover.isNotEmpty) {
          coverImages[id] = cover;
        }
      }

      emit(
        state.copyWith(
          allCategories: categories,
          coverImages: coverImages,
          isLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi load categories từ server: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> selectCategory({
    required String classId,
    required String className,
  }) async {
    emit(
      state.copyWith(
        selectedClassId: classId,
        selectedClassName: className,
        selectedClassImages: const [],
        selectedClassInfo: null,
        isLoadingClassDetail: true,
      ),
    );

    try {
      final uri = Uri.parse('$kServerUrl/categories/$classId');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
          'Load detail $classId thất bại: ${response.statusCode}',
        );
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      final images = (jsonData['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      final info = jsonData['markdown']?.toString();

      emit(
        state.copyWith(
          selectedClassImages: images,
          selectedClassInfo: info,
          isLoadingClassDetail: false,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi load detail $classId từ server: $e');
      emit(state.copyWith(isLoadingClassDetail: false));
    }
  }
}