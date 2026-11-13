
import 'package:flutter_bloc/flutter_bloc.dart';
import 'database_helper.dart';

abstract class AccelerationState {}

class AccelerationInitial extends AccelerationState {}

class AccelerationResult extends AccelerationState {
  final double v0;
  final double v;
  final double t;
  final double a;

  AccelerationResult({
    required this.v0,
    required this.v,
    required this.t,
    required this.a,
  });
}

class AccelerationError extends AccelerationState {
  final String message;

  AccelerationError(this.message);
}

class AccelerationCubit extends Cubit<AccelerationState> {
  final DatabaseHelper databaseHelper;

  AccelerationCubit(this.databaseHelper) : super(AccelerationInitial());

  Future<void> calculate(
    String v0Text,
    String vText,
    String tText,
  ) async {
    final v0 = double.tryParse(v0Text.replaceAll(',', '.'));
    final v = double.tryParse(vText.replaceAll(',', '.'));
    final t = double.tryParse(tText.replaceAll(',', '.'));

    if (v0 == null || v == null || t == null) {
      emit(AccelerationError('Введите корректные числа'));
      return;
    }

    if (t <= 0) {
      emit(AccelerationError('Время должно быть больше 0'));
      return;
    }

    final a = (v - v0) / t;

    try {
      await databaseHelper.insertCalculation(v0, v, t, a);

      emit(AccelerationResult(
        v0: v0,
        v: v,
        t: t,
        a: a,
      ));
    } catch (e) {
      emit(AccelerationError('Ошибка сохранения расчёта: $e'));
    }
  }

  void reset() {
    emit(AccelerationInitial());
  }
}
