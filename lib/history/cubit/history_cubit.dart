import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/history_repository.dart';
import '../models/history_item.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({required this.repository}) : super(const HistoryState());

  final HistoryRepository repository;

  Future<void> loadHistory() async {
    emit(state.copyWith(isLoading: true));

    try {
      final items = await repository.getHistory();
      emit(state.copyWith(
        isLoading: false,
        items: items,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteItem(String id) async {
    await repository.deleteHistoryItem(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await repository.clearHistory();
    await loadHistory();
  }
}