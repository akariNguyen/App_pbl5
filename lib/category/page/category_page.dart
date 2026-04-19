import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:orchid_classifier/category/cubit/category_cubit.dart';
import 'package:orchid_classifier/category/widget/category_card.dart';
import 'package:orchid_classifier/category/widget/class_info_card.dart';
import 'package:orchid_classifier/category/widget/detail_action_card.dart';
import 'package:orchid_classifier/category/widget/history_card.dart';
import 'package:orchid_classifier/category/widget/image_grid_tab_card.dart';
import 'package:orchid_classifier/category/widget/top_tab_button.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';
import 'package:orchid_classifier/history/page/history_detail_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CategoryCubit(historyRepository: HistoryRepository())..init(),
      child: const _CategoryView(),
    );
  }
}

class _CategoryView extends StatefulWidget {
  const _CategoryView();

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final TabController _detailTabController;
  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.hour)}:${two(dt.minute)} ${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  void initState() {
    super.initState();
    _detailTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _detailTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<CategoryCubit, CategoryState>(
      listenWhen: (previous, current) =>
          previous.selectedClassId != current.selectedClassId,
      listener: (context, state) {
        if (state.selectedClassId != null) {
          _detailTabController.animateTo(0);
        } else {
          _detailTabController.animateTo(0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            centerTitle: true,
            title: const Text(
              'Danh mục hoa lan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    if (!state.isShowingDetail) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TopTabButton(
                                  text: 'Thực vật',
                                  selected: state.selectedTab == 0,
                                  onTap: () {
                                    context.read<CategoryCubit>().changeTopTab(
                                      0,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: TopTabButton(
                                  text: 'Lịch sử chụp',
                                  selected: state.selectedTab == 1,
                                  onTap: () async {
                                    context.read<CategoryCubit>().changeTopTab(
                                      1,
                                    );
                                    await context
                                        .read<CategoryCubit>()
                                        .refreshHistory();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: context
                                .read<CategoryCubit>()
                                .changeKeyword,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: scheme.outline),
                              hintText: state.selectedTab == 0
                                  ? 'Tìm kiếm class hoặc tên lan'
                                  : 'Tìm kiếm lịch sử chụp',
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              state.selectedTab == 0
                                  ? 'Tổng: ${state.filteredCategories.length} class'
                                  : 'Tổng: ${state.filteredHistory.length} mục lịch sử',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context
                                    .read<CategoryCubit>()
                                    .backToCategoryList();
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: scheme.surfaceContainerHighest,
                              ),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.selectedClassId ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      state.selectedClassName ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Expanded(
                      child: !state.isShowingDetail
                          ? _buildMainContent(context, state)
                          : _buildDetailContent(context, state),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, CategoryState state) {
    final scheme = Theme.of(context).colorScheme;

    if (state.selectedTab == 0) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state.filteredCategories.isEmpty) {
        return Center(
          child: Text(
            'Không tìm thấy class nào',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        itemCount: state.filteredCategories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = state.filteredCategories[index];
          final classId = item['id']!;
          final className = item['name']!;
          final imagePath = state.coverImages[classId];

          return CategoryCard(
            id: classId,
            name: className,
            imagePath: imagePath,
            onTap: () {
              context.read<CategoryCubit>().selectCategory(
                classId: classId,
                className: className,
              );
            },
          );
        },
      );
    }

    if (state.filteredHistory.isEmpty) {
      return Center(
        child: Text(
          'Chưa có lịch sử chụp',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      itemCount: state.filteredHistory.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.filteredHistory[index];
        return HistoryCard(
          title: item.className,
          subtitle: _formatDate(item.createdAt),
          imagePath: item.imagePath,
          showDivider: index != state.filteredHistory.length - 1,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoryDetailPage(item: item)),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailContent(BuildContext context, CategoryState state) {
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoadingClassDetail) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: DetailActionCard(
                  icon: Icons.photo_library_outlined,
                  title: 'Danh mục hình ảnh',
                  subtitle: '${state.selectedClassImages.length} ảnh',
                  color: scheme.primary,
                  onTap: () => _detailTabController.animateTo(0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DetailActionCard(
                  icon: Icons.description_outlined,
                  title: 'Thông tin chi tiết',
                  subtitle: state.selectedClassInfo == null
                      ? 'Chưa có dữ liệu'
                      : 'Mô tả class',
                  color: scheme.tertiary,
                  onTap: () => _detailTabController.animateTo(1),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _detailTabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ImageGridTab(images: state.selectedClassImages),
              ClassInfoTab(
                classId: state.selectedClassId!,
                content: state.selectedClassInfo,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
