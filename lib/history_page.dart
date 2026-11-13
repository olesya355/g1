
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'history_cubit.dart';
import 'database_helper.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryCubit(DatabaseHelper())..loadHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('История расчётов'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is HistoryError) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is HistoryLoaded) {
              if (state.calculations.isEmpty) {
                return const Center(
                  child: Text('История расчётов пуста'),
                );
              }

              return ListView.builder(
                itemCount: state.calculations.length,
                itemBuilder: (context, index) {
                  final item = state.calculations[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Расчёт №${item['id']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Начальная скорость: ${item['v0']}'),
                          Text('Конечная скорость: ${item['v']}'),
                          Text('Время: ${item['t']}'),
                          Text(
                            'Ускорение: ${item['a']} м/с²',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Дата: ${item['createdAt']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text('Нет данных'),
            );
          },
        ),
      ),
    );
  }
}
