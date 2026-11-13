
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'acceleration_history.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE calculations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            v0 REAL NOT NULL,
            v REAL NOT NULL,
            t REAL NOT NULL,
            a REAL NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<void> insertCalculation(
    double v0,
    double v,
    double t,
    double a,
  ) async {
    final db = await database;

    await db.insert('calculations', {
      'v0': v0,
      'v': v,
      't': t,
      'a': a,
      'createdAt': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getCalculations() async {
    final db = await database;

    return await db.query(
      'calculations',
      orderBy: 'id DESC',
    );
  }
}
