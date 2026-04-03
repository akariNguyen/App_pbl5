import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();

  String keyword = '';
  bool isLoading = true;
  int selectedTab = 0; // 0 = Thực vật, 1 = Lịch sử chụp

  late final List<Map<String, String>> allCategories;
  Map<String, String> coverImages = {};

  final List<Map<String, String>> captureHistory = [
    {
      'id': 'his001',
      'name': 'Ảnh chụp class0003',
      'time': 'Hôm nay, 20:45',
    },
    {
      'id': 'his002',
      'name': 'Ảnh chụp class0012',
      'time': 'Hôm nay, 18:12',
    },
    {
      'id': 'his003',
      'name': 'Ảnh chụp class0036',
      'time': 'Hôm qua, 21:03',
    },
    {
      'id': 'his004',
      'name': 'Ảnh chụp class0008',
      'time': 'Hôm qua, 14:26',
    },
  ];

  @override
  void initState() {
    super.initState();

    allCategories = List.generate(45, (index) {
      final id = 'class${index.toString().padLeft(4, '0')}';
      return {
        'id': id,
        'name': id,
      };
    });

    _loadCoverImages();
  }

  Future<void> _loadCoverImages() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();

      final Map<String, String> foundCovers = {};

      for (final item in allCategories) {
        final classId = item['id']!;
        final folder = 'lib/classifier/data/category/$classId/';

        final images = allAssets.where((path) {
          final lower = path.toLowerCase();
          return path.startsWith(folder) &&
              (lower.endsWith('.png') ||
                  lower.endsWith('.jpg') ||
                  lower.endsWith('.jpeg') ||
                  lower.endsWith('.webp'));
        }).toList();

        images.sort();

        if (images.isNotEmpty) {
          foundCovers[classId] = images.first;
        }
      }

      if (mounted) {
        setState(() {
          coverImages = foundCovers;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi load cover images: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final filteredCategories = allCategories.where((item) {
      final id = item['id']!.toLowerCase();
      final name = item['name']!.toLowerCase();
      final q = keyword.toLowerCase().trim();
      return id.contains(q) || name.contains(q);
    }).toList();

    final filteredHistory = captureHistory.where((item) {
      final id = item['id']!.toLowerCase();
      final name = item['name']!.toLowerCase();
      final time = item['time']!.toLowerCase();
      final q = keyword.toLowerCase().trim();
      return id.contains(q) || name.contains(q) || time.contains(q);
    }).toList();

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
                          child: _TopTabButton(
                            text: 'Thực vật',
                            selected: selectedTab == 0,
                            onTap: () {
                              setState(() {
                                selectedTab = 0;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: _TopTabButton(
                            text: 'Lịch sử chụp',
                            selected: selectedTab == 1,
                            onTap: () {
                              setState(() {
                                selectedTab = 1;
                              });
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
                      onChanged: (value) {
                        setState(() {
                          keyword = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: scheme.outline),
                        hintText: selectedTab == 0
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
                        selectedTab == 0
                            ? 'Tổng: ${filteredCategories.length} class'
                            : 'Tổng: ${filteredHistory.length} mục lịch sử',
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
                Expanded(
                  child: selectedTab == 0
                      ? (isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredCategories.isEmpty
                              ? Center(
                                  child: Text(
                                    'Không tìm thấy class nào',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    0,
                                    14,
                                    14,
                                  ),
                                  itemCount: filteredCategories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = filteredCategories[index];
                                    final classId = item['id']!;
                                    final className = item['name']!;
                                    final imagePath = coverImages[classId];

                                    return _CategoryCard(
                                      id: classId,
                                      name: className,
                                      imagePath: imagePath,
                                      onTap: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('Bạn chọn $classId'),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ))
                      : (filteredHistory.isEmpty
                          ? Center(
                              child: Text(
                                'Chưa có lịch sử chụp',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                              itemCount: filteredHistory.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filteredHistory[index];
                                return _HistoryCard(
                                  title: item['name']!,
                                  subtitle: item['time']!,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Mở ${item['name']}'),
                                      ),
                                    );
                                  },
                                );
                              },
                            )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TopTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary.withOpacity(0.22) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final String? imagePath;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imagePath != null)
                Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: scheme.surfaceContainerHighest,
                    );
                  },
                )
              else
                Container(
                  color: scheme.surfaceContainerHighest,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.68),
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0.08),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.history,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}