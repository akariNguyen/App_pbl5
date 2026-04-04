part of 'category_cubit.dart';

class CategoryState extends Equatable {
  final bool isLoading;
  final bool isLoadingClassDetail;
  final String keyword;
  final int selectedTab; // 0 = Thực vật, 1 = Lịch sử chụp

  final List<Map<String, String>> allCategories;
  final Map<String, String> coverImages;
  final List<HistoryItem> captureHistory;

  final String? selectedClassId;
  final String? selectedClassName;
  final List<String> selectedClassImages;
  final String? selectedClassInfo;

  const CategoryState({
    this.isLoading = true,
    this.isLoadingClassDetail = false,
    this.keyword = '',
    this.selectedTab = 0,
    this.allCategories = const [],
    this.coverImages = const {},
    this.captureHistory = const [],
    this.selectedClassId,
    this.selectedClassName,
    this.selectedClassImages = const [],
    this.selectedClassInfo,
  });

  bool get isShowingDetail => selectedClassId != null;

  List<Map<String, String>> get filteredCategories {
    final q = keyword.toLowerCase().trim();
    return allCategories.where((item) {
      final id = item['id']!.toLowerCase();
      final name = item['name']!.toLowerCase();
      return id.contains(q) || name.contains(q);
    }).toList();
  }

  List<HistoryItem> get filteredHistory {
    final q = keyword.toLowerCase().trim();

    return captureHistory.where((item) {
      final id = item.id.toLowerCase();
      final name = (item.vietnameseName ?? item.className).toLowerCase();
      final family = (item.family ?? '').toLowerCase();
      final classIdText = item.classId.toString();

      return id.contains(q) ||
          name.contains(q) ||
          family.contains(q) ||
          classIdText.contains(q);
    }).toList();
  }

  CategoryState copyWith({
    bool? isLoading,
    bool? isLoadingClassDetail,
    String? keyword,
    int? selectedTab,
    List<Map<String, String>>? allCategories,
    Map<String, String>? coverImages,
    List<HistoryItem>? captureHistory,
    String? selectedClassId,
    String? selectedClassName,
    List<String>? selectedClassImages,
    String? selectedClassInfo,
    bool clearSelectedClass = false,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingClassDetail: isLoadingClassDetail ?? this.isLoadingClassDetail,
      keyword: keyword ?? this.keyword,
      selectedTab: selectedTab ?? this.selectedTab,
      allCategories: allCategories ?? this.allCategories,
      coverImages: coverImages ?? this.coverImages,
      captureHistory: captureHistory ?? this.captureHistory,
      selectedClassId: clearSelectedClass
          ? null
          : (selectedClassId ?? this.selectedClassId),
      selectedClassName: clearSelectedClass
          ? null
          : (selectedClassName ?? this.selectedClassName),
      selectedClassImages: clearSelectedClass
          ? const []
          : (selectedClassImages ?? this.selectedClassImages),
      selectedClassInfo: clearSelectedClass
          ? null
          : (selectedClassInfo ?? this.selectedClassInfo),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingClassDetail,
    keyword,
    selectedTab,
    allCategories,
    coverImages,
    captureHistory,
    selectedClassId,
    selectedClassName,
    selectedClassImages,
    selectedClassInfo,
  ];
}
