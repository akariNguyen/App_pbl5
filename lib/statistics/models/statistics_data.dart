class StatisticsData {
  final int totalScans;
  final int uniqueSpecies;
  final String? topSpeciesName;
  final int topSpeciesCount;
  final String? busiestDay;
  final int busiestDayCount;
  final List<DailyScanPoint> dailyScans;
  final List<SpeciesCount> topSpecies;
  final List<ClassCount> classCounts;

  const StatisticsData({
    required this.totalScans,
    required this.uniqueSpecies,
    this.topSpeciesName,
    required this.topSpeciesCount,
    this.busiestDay,
    required this.busiestDayCount,
    required this.dailyScans,
    required this.topSpecies,
    required this.classCounts,
  });

  static StatisticsData empty() => const StatisticsData(
        totalScans: 0,
        uniqueSpecies: 0,
        topSpeciesCount: 0,
        busiestDayCount: 0,
        dailyScans: [],
        topSpecies: [],
        classCounts: [],
      );
}

class DailyScanPoint {
  final DateTime date;
  final int count;

  const DailyScanPoint({required this.date, required this.count});
}

class SpeciesCount {
  final String displayName;
  final String className;
  final int count;

  const SpeciesCount({
    required this.displayName,
    required this.className,
    required this.count,
  });
}

class ClassCount {
  final String className;
  final String displayName;
  final int count;

  const ClassCount({
    required this.className,
    required this.displayName,
    required this.count,
  });
}
