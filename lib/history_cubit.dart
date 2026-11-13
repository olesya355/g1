
import 'package:flutter_bloc/flutter_bloc.dart';
import 'database_helper.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Map<String, dynamic>> calculations;

  HistoryLoaded(this.calculations);
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);
}

class HistoryCubit extends Cubit<HistoryState> {
  final DatabaseHelper databaseHelper;

  HistoryCubit(this.databaseHelper) : super(HistoryInitial());

  Future<void> loadHistory() async {
    emit(HistoryLoading());

    try {
      final calculations = await databaseHelper.getCalculations();
      emit(HistoryLoaded(calculations));
    } catch (e) {
      emit(HistoryError('Не удалось загрузить историю: $e'));
    }
  }
}
