import 'dart:io';

import 'package:flutter/material.dart';

import '../models/history_item.dart';

class HistoryDetailPage extends StatefulWidget {
  final HistoryItem item;

  const HistoryDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final file = File(item.imagePath);

    final rawContent =
        item.overview ?? item.identification ?? item.careGuide ?? '';

    final parsed = _ParsedOrchidInfo.fromMarkdown(rawContent);

    final overviewText = parsed.introduction.isNotEmpty
        ? parsed.introduction
        : 'Chưa có thông tin tổng quan.';

    final identificationText = parsed.identification.isNotEmpty
        ? parsed.identification
        : 'Chưa có thông tin nhận dạng.';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 430,
                pinned: true,
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.green,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Lịch Sử Chụp',
                  style: TextStyle(color: Colors.transparent),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      file.existsSync()
                          ? Image.file(file, fit: BoxFit.cover)
                          : Container(color: Colors.grey.shade400),
                      Positioned(
                        left: 22,
                        right: 22,
                        bottom: 34,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.vietnameseName ?? item.className,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.scientificName ?? parsed.species,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Họ ${item.family ?? parsed.family}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _TopActionTab(
                                selected: selectedTab == 0,
                                icon: Icons.info,
                                text: 'Tổng quan',
                                onTap: () => setState(() => selectedTab = 0),
                              ),
                            ),
                            Expanded(
                              child: _TopActionTab(
                                selected: selectedTab == 1,
                                icon: Icons.eco_outlined,
                                text: 'Nhận dạng',
                                onTap: () => setState(() => selectedTab = 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      if (selectedTab == 0) ...[
                        _InfoCard(
                          icon: Icons.info,
                          title: 'Giới thiệu',
                          content: overviewText,
                        ),
                        const SizedBox(height: 22),
                        _ClassificationCard(
                          division: parsed.division,
                          order: parsed.order,
                          family: item.family ?? parsed.family,
                          genus: parsed.genus,
                          species: item.scientificName ?? parsed.species,
                          detailUrl: parsed.detailUrl,
                        ),
                      ],

                      if (selectedTab == 1) ...[
                        _InfoCard(
                          icon: Icons.local_florist_outlined,
                          title: 'Đặc điểm hoa',
                          content: parsed.flower.isNotEmpty
                              ? parsed.flower
                              : identificationText,
                        ),
                        const SizedBox(height: 22),
                        _InfoCard(
                          icon: Icons.eco_outlined,
                          title: 'Đặc điểm lá',
                          content: parsed.leaf.isNotEmpty
                              ? parsed.leaf
                              : 'Chưa có thông tin đặc điểm lá.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }
}

class _ParsedOrchidInfo {
  final String introduction;
  final String division;
  final String order;
  final String family;
  final String genus;
  final String species;
  final String flower;
  final String leaf;
  final String detailUrl;

  const _ParsedOrchidInfo({
    required this.introduction,
    required this.division,
    required this.order,
    required this.family,
    required this.genus,
    required this.species,
    required this.flower,
    required this.leaf,
    required this.detailUrl,
  });

  factory _ParsedOrchidInfo.fromMarkdown(String markdown) {
    String clean(String value) {
      return value
          .replaceAll(RegExp(r'\*\*'), '')
          .replaceAll(RegExp(r'\*'), '')
          .replaceAll(RegExp(r'^#+\s*', multiLine: true), '')
          .replaceAll(RegExp(r'^---$', multiLine: true), '')
          .trim();
    }

    String extractBetween(String start, List<String> endMarkers) {
      final startIndex = markdown.indexOf(start);
      if (startIndex == -1) return '';

      final contentStart = startIndex + start.length;
      var endIndex = markdown.length;

      for (final marker in endMarkers) {
        final index = markdown.indexOf(marker, contentStart);
        if (index != -1 && index < endIndex) {
          endIndex = index;
        }
      }

      return clean(markdown.substring(contentStart, endIndex));
    }

    String extractLineValue(String label) {
      final regex = RegExp(
        r'-\s*\*\*' + RegExp.escape(label) + r'\*\*\s*:\s*(.+)',
        caseSensitive: false,
      );
      final match = regex.firstMatch(markdown);
      return clean(match?.group(1) ?? '');
    }

    String extractDetailUrl() {
      final regex = RegExp(r'\[Thông tin chi tiết\]\((.*?)\)');
      final match = regex.firstMatch(markdown);
      return match?.group(1)?.trim() ?? '';
    }

    final titleEnd = markdown.indexOf('\n\n');
    final afterTitle = titleEnd == -1 ? markdown : markdown.substring(titleEnd);

    final introEndCandidates = [
      '**Phân loại:**',
      '## 🌸 Đặc điểm hoa',
      '## Đặc điểm hoa',
    ];

    var introEnd = afterTitle.length;
    for (final marker in introEndCandidates) {
      final index = afterTitle.indexOf(marker);
      if (index != -1 && index < introEnd) {
        introEnd = index;
      }
    }

    final introduction = clean(afterTitle.substring(0, introEnd));

    final flower = extractBetween(
      '## 🌸 Đặc điểm hoa',
      ['## 🌿 Đặc điểm lá', '[Thông tin chi tiết]'],
    );

    final leaf = extractBetween(
      '## 🌿 Đặc điểm lá',
      ['[Thông tin chi tiết]'],
    );

    return _ParsedOrchidInfo(
      introduction: introduction,
      division: extractLineValue('Ngành').isNotEmpty
          ? extractLineValue('Ngành')
          : 'Angiosperms',
      order: extractLineValue('Bộ').isNotEmpty
          ? extractLineValue('Bộ')
          : 'Asparagales',
      family: extractLineValue('Họ').isNotEmpty
          ? extractLineValue('Họ')
          : 'Orchidaceae',
      genus:
          extractLineValue('Chi').isNotEmpty ? extractLineValue('Chi') : 'Cymbidium',
      species: extractLineValue('Loài').isNotEmpty
          ? extractLineValue('Loài')
          : 'Cymbidium goeringii',
      flower: flower,
      leaf: leaf,
      detailUrl: extractDetailUrl(),
    );
  }

  String get identification {
    final parts = <String>[];

    if (flower.isNotEmpty) {
      parts.add('Đặc điểm hoa\n$flower');
    }

    if (leaf.isNotEmpty) {
      parts.add('Đặc điểm lá\n$leaf');
    }

    return parts.join('\n\n');
  }
}

class _TopActionTab extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _TopActionTab({
    required this.selected,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFFFBE5EA);
    final primaryColor = const Color(0xFFF06292);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryColor.withOpacity(0.18) : Colors.transparent,
            width: 1.2,
          ),
          
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          style: TextStyle(
            color: selected ? primaryColor : Colors.grey,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Icon(
                  icon,
                  color: selected ? primaryColor : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFBE5EA),
                child: Icon(icon, color: const Color(0xFFF1AFC0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            content,
            style: const TextStyle(
              fontSize: 20,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  final String division;
  final String order;
  final String family;
  final String genus;
  final String species;
  final String detailUrl;

  const _ClassificationCard({
    required this.division,
    required this.order,
    required this.family,
    required this.genus,
    required this.species,
    required this.detailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Ngành', division],
      ['Bộ', order],
      ['Họ', family],
      ['Chi', genus],
      ['Loài', species],
      if (detailUrl.isNotEmpty) ['Thông tin chi tiết', detailUrl],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFFBE5EA),
                child: Icon(
                  Icons.description_outlined,
                  color: Color(0xFFF1AFC0),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Phân loại',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F6F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        row[0],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row[1],
                        style: TextStyle(
                          fontSize: row[0] == 'Thông tin chi tiết' ? 15 : 18,
                          fontWeight: FontWeight.w500,
                          color: row[0] == 'Thông tin chi tiết'
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}