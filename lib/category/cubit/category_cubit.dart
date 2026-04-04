import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';
import 'package:orchid_classifier/history/models/history_item.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit({required this.historyRepository}) : super(_initialState());

  final HistoryRepository historyRepository;

  static CategoryState _initialState() {
    final categories = List.generate(45, (index) {
      final id = 'class${index.toString().padLeft(4, '0')}';
      return {'id': id, 'name': id};
    });

    return CategoryState(allCategories: categories);
  }

  Future<void> init() async {
    await loadCoverImages();
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
    emit(state.copyWith(clearSelectedClass: true, isLoadingClassDetail: false));
  }

  Future<void> loadCoverImages() async {
    emit(state.copyWith(isLoading: true));

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      final Map<String, String> foundCovers = {};

      for (final item in state.allCategories) {
        final classId = item['id']!;
        final folder = 'lib/classifier/data/category/$classId/';

        final images = allAssets.where((path) {
          final lower = path.toLowerCase();
          return path.startsWith(folder) &&
              (lower.endsWith('.png') ||
                  lower.endsWith('.jpg') ||
                  lower.endsWith('.jpeg') ||
                  lower.endsWith('.webp'));
        }).toList()..sort();

        if (images.isNotEmpty) {
          foundCovers[classId] = images.first;
        }
      }

      emit(state.copyWith(coverImages: foundCovers, isLoading: false));
    } catch (e) {
      debugPrint('Lỗi load cover images: $e');
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
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      final folder = 'lib/classifier/data/category/$classId/';

      final images = allAssets.where((path) {
        final lower = path.toLowerCase();
        return path.startsWith(folder) &&
            (lower.endsWith('.png') ||
                lower.endsWith('.jpg') ||
                lower.endsWith('.jpeg') ||
                lower.endsWith('.webp'));
      }).toList()..sort();

      String? info;
      try {
        final infoPath = 'lib/classifier/data/infor/$classId.md';
        debugPrint('Đang load info ở CategoryCubit: $infoPath');
        info = await rootBundle.loadString(infoPath);
        debugPrint('Load info thành công cho $classId');
      } catch (e) {
        debugPrint('Không load được info cho $classId: $e');
        info = null;
      }

      emit(
        state.copyWith(
          selectedClassImages: images.take(50).toList(),
          selectedClassInfo: info,
          isLoadingClassDetail: false,
        ),
      );
    } catch (e) {
      debugPrint('Lỗi load detail $classId: $e');
      emit(state.copyWith(isLoadingClassDetail: false));
    }
  }
}
