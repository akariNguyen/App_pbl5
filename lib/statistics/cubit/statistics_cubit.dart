import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orchid_classifier/history/data/history_repository.dart';
import 'package:orchid_classifier/history/models/history_item.dart';
import '../models/statistics_data.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final HistoryRepository repository;

  StatisticsCubit({required this.repository})
      : super(StatisticsState(data: StatisticsData.empty()));

  Future<void> loadStatistics({DateRangeFilter? filter, DateTime? customStart, DateTime? customEnd}) async {
    final currentFilter = filter ?? state.filter;
    emit(state.copyWith(
      isLoading: true,
      filter: currentFilter,
      customStart: customStart,
      customEnd: customEnd,
    ));

    try {
      final allItems = await repository.getHistory();
      final filtered = _filterItems(allItems, currentFilter, customStart, customEnd);
      final data = _computeStatistics(filtered, currentFilter, customStart, customEnd);
      emit(state.copyWith(isLoading: false, data: data));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  List<HistoryItem> _filterItems(
    List<HistoryItem> items,
    DateRangeFilter filter,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (filter) {
      case DateRangeFilter.week:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRangeFilter.month:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRangeFilter.quarter:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89));
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case DateRangeFilter.all:
        return items;
      case DateRangeFilter.custom:
        start = customStart != null ? DateTime(customStart.year, customStart.month, customStart.day) : null;
        end = customEnd != null ? DateTime(customEnd.year, customEnd.month, customEnd.day, 23, 59, 59) : null;
        break;
    }

    return items.where((item) {
      if (start != null && item.createdAt.isBefore(start)) return false;
      if (end != null && item.createdAt.isAfter(end)) return false;
      return true;
    }).toList();
  }

  StatisticsData _computeStatistics(
    List<HistoryItem> items,
    DateRangeFilter filter,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    if (items.isEmpty) return StatisticsData.empty();

    // Daily counts
    final Map<String, int> dayCounts = {};
    for (final item in items) {
      final key = '${item.createdAt.year}-${_pad(item.createdAt.month)}-${_pad(item.createdAt.day)}';
      dayCounts[key] = (dayCounts[key] ?? 0) + 1;
    }

    // Build daily series for chart range
    final now = DateTime.now();
    DateTime rangeStart;
    DateTime rangeEnd = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case DateRangeFilter.week:
        rangeStart = rangeEnd.subtract(const Duration(days: 6));
        break;
      case DateRangeFilter.month:
        rangeStart = rangeEnd.subtract(const Duration(days: 29));
        break;
      case DateRangeFilter.quarter:
        rangeStart = rangeEnd.subtract(const Duration(days: 89));
        break;
      case DateRangeFilter.all:
        if (items.isNotEmpty) {
          final earliest = items.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
          rangeStart = DateTime(earliest.createdAt.year, earliest.createdAt.month, earliest.createdAt.day);
        } else {
          rangeStart = rangeEnd;
        }
        break;
      case DateRangeFilter.custom:
        rangeStart = customStart != null
            ? DateTime(customStart.year, customStart.month, customStart.day)
            : rangeEnd.subtract(const Duration(days: 29));
        rangeEnd = customEnd != null
            ? DateTime(customEnd.year, customEnd.month, customEnd.day)
            : rangeEnd;
        break;
    }

    final List<DailyScanPoint> dailyScans = [];
    DateTime cur = rangeStart;
    while (!cur.isAfter(rangeEnd)) {
      final key = '${cur.year}-${_pad(cur.month)}-${_pad(cur.day)}';
      dailyScans.add(DailyScanPoint(date: cur, count: dayCounts[key] ?? 0));
      cur = cur.add(const Duration(days: 1));
    }

    // Busiest day
    String? busiestDay;
    int busiestDayCount = 0;
    dayCounts.forEach((k, v) {
      if (v > busiestDayCount) {
        busiestDayCount = v;
        busiestDay = k;
      }
    });

    // Species counts
    final Map<String, Map<String, dynamic>> speciesMap = {};
    for (final item in items) {
      final name = item.vietnameseName ?? item.className;
      if (!speciesMap.containsKey(item.className)) {
        speciesMap[item.className] = {'name': name, 'count': 0};
      }
      speciesMap[item.className]!['count'] = (speciesMap[item.className]!['count'] as int) + 1;
    }

    final topSpeciesList = speciesMap.entries
        .map((e) => SpeciesCount(
              displayName: e.value['name'] as String,
              className: e.key,
              count: e.value['count'] as int,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    // Class distribution
    final Map<int, Map<String, dynamic>> classMap = {};
    for (final item in items) {
      final id = item.classId;
      if (!classMap.containsKey(id)) {
        classMap[id] = {
          'name': item.vietnameseName ?? item.className,
          'className': item.className,
          'count': 0,
        };
      }
      classMap[id]!['count'] = (classMap[id]!['count'] as int) + 1;
    }

    final classCounts = classMap.entries
        .map((e) => ClassCount(
              className: e.value['className'] as String,
              displayName: e.value['name'] as String,
              count: e.value['count'] as int,
            ))
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final topSpecies = topSpeciesList.isNotEmpty ? topSpeciesList.first : null;

    return StatisticsData(
      totalScans: items.length,
      uniqueSpecies: speciesMap.length,
      topSpeciesName: topSpecies?.displayName,
      topSpeciesCount: topSpecies?.count ?? 0,
      busiestDay: busiestDay,
      busiestDayCount: busiestDayCount,
      dailyScans: dailyScans,
      topSpecies: topSpeciesList.take(5).toList(),
      classCounts: classCounts.take(8).toList(),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}
