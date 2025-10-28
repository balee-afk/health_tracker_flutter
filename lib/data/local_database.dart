import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/meal_entry.dart';
import '../models/sleep_log.dart';
import '../models/step_log.dart';
import '../models/user_account.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _init();
    return _database!;
  }

  Future<void> ensureInitialized() async {
    await database;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'heart_tracker.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE step_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL,
            goal INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sleep_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            quality TEXT NOT NULL,
            sleep_start TEXT,
            sleep_end TEXT,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE meal_entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            calories INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            protein INTEGER NOT NULL,
            carbs INTEGER NOT NULL,
            fat INTEGER NOT NULL
          )
        ''');

        await _seedInitialData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE sleep_logs ADD COLUMN sleep_start TEXT',
          );
          await db.execute(
            'ALTER TABLE sleep_logs ADD COLUMN sleep_end TEXT',
          );
          await db.execute(
            'ALTER TABLE sleep_logs ADD COLUMN notes TEXT',
          );
        }
      },
    );
  }

  Future<void> _seedInitialData(Database db) async {
    await db.insert(
      'users',
      {
        'name': 'Andi',
        'email': 'andi@healthtrack.com',
        'password': 'rahasia123',
      },
    );

    await db.insert(
      'step_logs',
      {
        'date': DateTime.now().toIso8601String(),
        'steps': 8254,
        'goal': 10000,
      },
    );

    await db.insert(
      'sleep_logs',
      {
        'date': DateTime.now().toIso8601String(),
        'duration_minutes': 435,
        'quality': 'Baik',
        'sleep_start':
            DateTime.now().subtract(const Duration(hours: 7, minutes: 15)).toIso8601String(),
        'sleep_end': DateTime.now().toIso8601String(),
        'notes': 'Terbangun sekali untuk minum',
      },
    );

    await db.insert(
      'meal_entries',
      {
        'name': 'Oatmeal dengan Stroberi',
        'category': 'Sarapan',
        'calories': 250,
        'quantity': 1,
        'protein': 8,
        'carbs': 30,
        'fat': 5,
      },
    );

    await db.insert(
      'meal_entries',
      {
        'name': 'Telur Orak-arik',
        'category': 'Sarapan',
        'calories': 200,
        'quantity': 1,
        'protein': 12,
        'carbs': 2,
        'fat': 14,
      },
    );
  }

  // --- User helpers ---
  Future<UserAccount?> fetchUserByCredentials(
    String email,
    String password,
  ) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return UserAccount.fromMap(rows.first);
  }

  // --- Steps CRUD ---
  Future<List<StepLog>> fetchStepLogs() async {
    final db = await database;
    final rows = await db.query(
      'step_logs',
      orderBy: 'date DESC',
    );
    return rows.map(StepLog.fromMap).toList();
  }

  Future<int> insertStepLog(StepLog log) async {
    final db = await database;
    return db.insert('step_logs', log.toMap());
  }

  Future<int> updateStepLog(StepLog log) async {
    final db = await database;
    return db.update(
      'step_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteStepLog(int id) async {
    final db = await database;
    return db.delete(
      'step_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Sleep CRUD ---
  Future<List<SleepLog>> fetchSleepLogs() async {
    final db = await database;
    final rows = await db.query(
      'sleep_logs',
      orderBy: 'date DESC',
    );
    return rows.map(SleepLog.fromMap).toList();
  }

  Future<int> insertSleepLog(SleepLog log) async {
    final db = await database;
    return db.insert('sleep_logs', log.toMap());
  }

  Future<int> updateSleepLog(SleepLog log) async {
    final db = await database;
    return db.update(
      'sleep_logs',
      log.toMap(),
      where: 'id = ?',
      whereArgs: [log.id],
    );
  }

  Future<int> deleteSleepLog(int id) async {
    final db = await database;
    return db.delete(
      'sleep_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Meal CRUD ---
  Future<List<MealEntry>> fetchMealEntries() async {
    final db = await database;
    final rows = await db.query(
      'meal_entries',
      orderBy: 'category ASC, id DESC',
    );
    return rows.map(MealEntry.fromMap).toList();
  }

  Future<int> insertMealEntry(MealEntry meal) async {
    final db = await database;
    return db.insert('meal_entries', meal.toMap());
  }

  Future<int> updateMealEntry(MealEntry meal) async {
    final db = await database;
    return db.update(
      'meal_entries',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  Future<int> deleteMealEntry(int id) async {
    final db = await database;
    return db.delete(
      'meal_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
