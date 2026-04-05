part of 'statistics_cubit.dart';

enum DateRangeFilter { week, month, quarter, all, custom }

class StatisticsState {
  final bool isLoading;
  final String? errorMessage;
  final StatisticsData data;
  final DateRangeFilter filter;
  final DateTime? customStart;
  final DateTime? customEnd;

  const StatisticsState({
    this.isLoading = false,
    this.errorMessage,
    required this.data,
    this.filter = DateRangeFilter.month,
    this.customStart,
    this.customEnd,
  });

  StatisticsState copyWith({
    bool? isLoading,
    String? errorMessage,
    StatisticsData? data,
    DateRangeFilter? filter,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      data: data ?? this.data,
      filter: filter ?? this.filter,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }
}
