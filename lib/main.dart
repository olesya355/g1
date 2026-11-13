
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'acceleration_cubit.dart';
import 'database_helper.dart';
import 'history_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final databaseHelper = DatabaseHelper();

  runApp(
    BlocProvider(
      create: (_) => AccelerationCubit(databaseHelper),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Расчёт ускорения',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _v0 = TextEditingController();
  final TextEditingController _v = TextEditingController();
  final TextEditingController _t = TextEditingController();

  bool _agree = false;

  @override
  void initState() {
    super.initState();
    _loadLastValues();
  }

  Future<void> _loadLastValues() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _v0.text = prefs.getString('v0') ?? '';
      _v.text = prefs.getString('v') ?? '';
      _t.text = prefs.getString('t') ?? '';
    });
  }

  Future<void> _saveLastValues() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('v0', _v0.text);
    await prefs.setString('v', _v.text);
    await prefs.setString('t', _t.text);
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласиться на обработку данных'),
        ),
      );
      return;
    }

    await _saveLastValues();

    if (!mounted) return;

    context.read<AccelerationCubit>().calculate(
          _v0.text,
          _v.text,
          _t.text,
        );
  }

  @override
  void dispose() {
    _v0.dispose();
    _v.dispose();
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расчёт ускорения'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'История расчётов',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HistoryPage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _v0,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Начальная скорость (м/с)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите начальную скорость';
                  }

                  if (double.tryParse(
                        value.trim().replaceAll(',', '.'),
                      ) ==
                      null) {
                    return 'Введите корректное число';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _v,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Конечная скорость (м/с)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите конечную скорость';
                  }

                  if (double.tryParse(
                        value.trim().replaceAll(',', '.'),
                      ) ==
                      null) {
                    return 'Введите корректное число';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _t,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Время (с)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите время';
                  }

                  final time = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );

                  if (time == null) {
                    return 'Введите корректное число';
                  }

                  if (time <= 0) {
                    return 'Время должно быть больше 0';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Согласен на обработку данных',
                ),
                value: _agree,
                onChanged: (value) {
                  setState(() {
                    _agree = value ?? false;
                  });
                },
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('Рассчитать ускорение'),
                ),
              ),

              const SizedBox(height: 20),

              BlocBuilder<AccelerationCubit, AccelerationState>(
                builder: (context, state) {
                  if (state is AccelerationResult) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Результат расчёта',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              'Начальная скорость: ${state.v0} м/с',
                            ),
                            Text(
                              'Конечная скорость: ${state.v} м/с',
                            ),
                            Text('Время: ${state.t} с'),

                            const SizedBox(height: 10),

                            Text(
                              'Ускорение: ${state.a.toStringAsFixed(2)} м/с²',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),

                            const SizedBox(height: 10),

                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<AccelerationCubit>()
                                    .reset();

                                _v0.clear();
                                _v.clear();
                                _t.clear();
                              },
                              child: const Text('Новый расчёт'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is AccelerationError) {
                    return Text(
                      state.message,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
