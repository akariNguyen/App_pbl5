import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/core/theme/orchid_colors.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';

import '../cubit/statistics_cubit.dart';
import '../models/statistics_data.dart';
import '../widgets/daily_bar_chart.dart';
import '../widgets/donut_chart.dart';
import '../widgets/stat_summary_card.dart';
import '../widgets/top_species_list.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final StatisticsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = StatisticsCubit(repository: HistoryRepository());
    _cubit.loadStatistics();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.orchidColors;

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: colors.bg,
            body: CustomScrollView(
              slivers: [
                _buildAppBar(context, colors),
                if (state.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  )
                else ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: _QuickFilterChips(
                        currentFilter: state.filter,
                        colors: colors,
                        onFilterChanged: (f) => _cubit.loadStatistics(filter: f),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: _DateRangeSelector(
                        currentFilter: state.filter,
                        customStart: state.customStart,
                        customEnd: state.customEnd,
                        colors: colors,
                        onPickRange: () => _pickCustomRange(context),
                        onClear: () => _cubit.loadStatistics(filter: DateRangeFilter.month),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildContent(context, state, colors),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, OrchidColors colors) {
    return SliverAppBar(
      backgroundColor: colors.bg,
      pinned: true,
      expandedHeight: 110,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thống Kê',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Phân tích lịch sử scan lan',
                    style: TextStyle(color: colors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StatisticsState state, OrchidColors colors) {
    final data = state.data;

    if (data.totalScans == 0) {
      return _buildEmptyState(colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary cards
        _SectionLabel(label: 'Tổng Quan', colors: colors),
        const SizedBox(height: 10),
        _buildSummaryCards(data, colors),
        const SizedBox(height: 24),

        // Daily bar chart
        _SectionLabel(label: 'Scan Theo Ngày', colors: colors),
        const SizedBox(height: 12),
        _buildBarChartCard(data, colors),
        const SizedBox(height: 24),

        // Top species
        if (data.topSpecies.isNotEmpty) ...[
          _SectionLabel(label: 'Top Loài Scan Nhiều Nhất', colors: colors),
          const SizedBox(height: 12),
          _buildTopSpeciesCard(data, colors),
          const SizedBox(height: 24),
        ],

        // Donut chart
        if (data.classCounts.length > 1) ...[
          _SectionLabel(label: 'Phân Bố Theo Loài', colors: colors),
          const SizedBox(height: 12),
          _buildDonutCard(data, colors),
        ],
      ],
    );
  }

  Widget _buildEmptyState(OrchidColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(Icons.analytics_outlined, size: 72, color: colors.muted.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Chưa có dữ liệu',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy chụp và phân loại lan để xem thống kê',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(StatisticsData data, OrchidColors colors) {
    String busiestLabel = '';
    if (data.busiestDay != null) {
      final parts = data.busiestDay!.split('-');
      if (parts.length == 3) {
        busiestLabel = '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    }

    return Row(
      children: [
        Expanded(
          child: StatSummaryCard(
            title: 'Tổng lần scan',
            value: data.totalScans.toString(),
            subtitle: 'lần chụp',
            icon: Icons.camera_alt_outlined,
            iconColor: colors.primary,
            bgColor: colors.card,
            textColor: colors.text,
            mutedColor: colors.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatSummaryCard(
            title: 'Loài đã scan',
            value: data.uniqueSpecies.toString(),
            subtitle: 'loài khác nhau',
            icon: Icons.local_florist_outlined,
            iconColor: colors.accent,
            bgColor: colors.card,
            textColor: colors.text,
            mutedColor: colors.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatSummaryCard(
            title: 'Ngày nhiều nhất',
            value: data.busiestDayCount.toString(),
            subtitle: busiestLabel,
            icon: Icons.calendar_today_outlined,
            iconColor: colors.success,
            bgColor: colors.card,
            textColor: colors.text,
            mutedColor: colors.muted,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartCard(StatisticsData data, OrchidColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: colors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Số lần scan',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.totalScans} lần',
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: DailyBarChart(
              points: data.dailyScans,
              barColor: colors.primary,
              barColorEnd: colors.accent,
              textColor: colors.text,
              gridColor: colors.border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpeciesCard(StatisticsData data, OrchidColors colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.topSpeciesName != null) ...[
            Row(
              children: [
                Text('🏆', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.topSpeciesName!,
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${data.topSpeciesCount} lần',
                  style: TextStyle(
                    color: colors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: 16),
          ],
          TopSpeciesList(
            species: data.topSpecies,
            primaryColor: colors.primary,
            accentColor: colors.accent,
            textColor: colors.text,
            mutedColor: colors.muted,
            cardColor: colors.card2,
          ),
        ],
      ),
    );
  }

  Widget _buildDonutCard(StatisticsData data, OrchidColors colors) {
    final palette = _buildPalette(colors, data.classCounts.length);
    final chartData = List.generate(
      data.classCounts.length,
      (i) => DonutChartData(
        label: data.classCounts[i].displayName,
        value: data.classCounts[i].count.toDouble(),
        color: palette[i % palette.length],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Donut on the left
              DonutChart(
                data: chartData,
                size: 160,
                strokeWidth: 28,
              ),
              const SizedBox(width: 20),
              // Legend on the right
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    math.min(chartData.length, 6),
                    (i) {
                      final d = chartData[i];
                      final total = chartData.fold<double>(0, (s, e) => s + e.value);
                      final pct = total > 0 ? (d.value / total * 100).toStringAsFixed(1) : '0';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: d.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: TextStyle(color: colors.text, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _buildPalette(OrchidColors colors, int count) {
    final base = [
      colors.primary,
      colors.accent,
      colors.success,
      colors.warning,
      colors.secondary,
      colors.error,
      colors.primary.withGreen(180),
      colors.accent.withBlue(200),
    ];
    if (count <= base.length) return base.sublist(0, count);
    final extended = List<Color>.from(base);
    for (int i = base.length; i < count; i++) {
      final hue = (i * 47.0) % 360;
      extended.add(HSLColor.fromAHSL(1, hue, 0.65, 0.55).toColor());
    }
    return extended;
  }

  Future<void> _pickCustomRange(BuildContext ctx) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: ctx,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: context.orchidColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (range != null) {
      _cubit.loadStatistics(
        filter: DateRangeFilter.custom,
        customStart: range.start,
        customEnd: range.end,
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final OrchidColors colors;

  const _SectionLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: colors.text,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─── Quick filter chips (7D / 30D / 90D / All) ────────────────────────────
class _QuickFilterChips extends StatelessWidget {
  final DateRangeFilter currentFilter;
  final OrchidColors colors;
  final ValueChanged<DateRangeFilter> onFilterChanged;

  const _QuickFilterChips({
    required this.currentFilter,
    required this.colors,
    required this.onFilterChanged,
  });

  static const _filters = [
    (DateRangeFilter.week, '7 Ngày'),
    (DateRangeFilter.month, '30 Ngày'),
    (DateRangeFilter.quarter, '90 Ngày'),
    (DateRangeFilter.all, 'Tất cả'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((pair) {
          final (filter, label) = pair;
          final isActive = currentFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(colors: [colors.primary, colors.accent])
                      : null,
                  color: isActive ? null : colors.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : colors.muted,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Prominent date range selector ────────────────────────────────────────
class _DateRangeSelector extends StatelessWidget {
  final DateRangeFilter currentFilter;
  final DateTime? customStart;
  final DateTime? customEnd;
  final OrchidColors colors;
  final VoidCallback onPickRange;
  final VoidCallback onClear;

  const _DateRangeSelector({
    required this.currentFilter,
    required this.customStart,
    required this.customEnd,
    required this.colors,
    required this.onPickRange,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasCustom = currentFilter == DateRangeFilter.custom &&
        customStart != null &&
        customEnd != null;

    return GestureDetector(
      onTap: onPickRange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: hasCustom ? colors.primary.withOpacity(0.1) : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasCustom ? colors.primary : colors.border,
            width: hasCustom ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colors.primary, colors.accent]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.date_range_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chọn khoảng ngày',
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasCustom
                        ? '${_fmt(customStart!)}  →  ${_fmt(customEnd!)}'
                        : 'Từ ngày nào … đến ngày nào',
                    style: TextStyle(
                      color: hasCustom ? colors.primary : colors.text.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: hasCustom ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (hasCustom)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.error.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 16, color: colors.error),
                ),
              )
            else
              Icon(Icons.chevron_right_rounded, color: colors.muted, size: 22),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

