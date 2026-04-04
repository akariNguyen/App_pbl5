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
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green),
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
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.12),
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
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
                              item.scientificName ?? 'Cymbidium ensifolium',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Họ ${item.family ?? 'Orchidaceae'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                _HeroChip(icon: Icons.eco, text: 'Lan'),
                                _HeroChip(icon: Icons.thumb_up_alt, text: 'Trung Bình'),
                                _HeroChip(icon: Icons.wb_sunny_outlined, text: 'Bóng Râm\nMột Phần'),
                              ],
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
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
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
                            Expanded(
                              child: _TopActionTab(
                                selected: selectedTab == 2,
                                icon: Icons.thumb_up_alt_outlined,
                                text: 'Hướng dẫn\nchăm sóc',
                                onTap: () => setState(() => selectedTab = 2),
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
                          content: item.overview ??
                              'Cây thuộc họ Lan, phổ biến trong trang trí nhờ hoa đẹp và mùi hương dễ chịu.',
                        ),
                        const SizedBox(height: 22),
                        _ClassificationCard(
                          scientificName: item.scientificName ?? 'Cymbidium ensifolium',
                          family: item.family ?? 'Orchidaceae',
                        ),
                      ],
                      if (selectedTab == 1) ...[
                        _InfoCard(
                          icon: Icons.eco_outlined,
                          title: 'Nhận dạng',
                          content: item.identification ??
                              'Dựa trên hình dáng lá, màu hoa, cấu trúc cánh và đặc điểm tổng thể của cây.',
                        ),
                      ],
                      if (selectedTab == 2) ...[
                        _InfoCard(
                          icon: Icons.thumb_up_alt_outlined,
                          title: 'Hướng dẫn chăm sóc',
                          content: item.careGuide ??
                              'Đặt cây nơi thoáng, có ánh sáng nhẹ. Tưới vừa phải, tránh úng nước, bón phân định kỳ.',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B7C5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Lưu cây'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? const Color(0xFFF1AFC0) : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFFF1AFC0) : Colors.grey,
                fontSize: 15,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            content,
            style: const TextStyle(
              fontSize: 22,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  final String scientificName;
  final String family;

  const _ClassificationCard({
    required this.scientificName,
    required this.family,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      ['Giới', 'Plantae'],
      ['Ngành', 'Tracheophyta'],
      ['Bộ', 'Asparagales'],
      ['Họ', family],
      ['Chi', scientificName.split(' ').first],
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
                child: Icon(Icons.description_outlined, color: Color(0xFFF1AFC0)),
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
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