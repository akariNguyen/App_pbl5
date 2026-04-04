part of 'history_cubit.dart';

class HistoryState extends Equatable {
  final bool isLoading;
  final List<HistoryItem> items;
  final String? errorMessage;

  const HistoryState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
  });

  HistoryState copyWith({
    bool? isLoading,
    List<HistoryItem>? items,
    String? errorMessage,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, errorMessage];
}