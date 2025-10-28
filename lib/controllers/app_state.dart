import 'package:flutter/foundation.dart';

import '../data/local_database.dart';
import '../models/meal_entry.dart';
import '../models/sleep_log.dart';
import '../models/step_log.dart';
import '../models/user_account.dart';

class AppState extends ChangeNotifier {
  AppState(this._database);

  final LocalDatabase _database;

  UserAccount? _currentUser;
  List<StepLog> _stepLogs = <StepLog>[];
  List<SleepLog> _sleepLogs = <SleepLog>[];
  List<MealEntry> _mealEntries = <MealEntry>[];

  UserAccount? get currentUser => _currentUser;
  List<StepLog> get stepLogs => _stepLogs;
  List<SleepLog> get sleepLogs => _sleepLogs;
  List<MealEntry> get mealEntries => _mealEntries;
  bool get isAuthenticated => _currentUser != null;

  Future<void> ensureInitialized() async {
    await _database.ensureInitialized();
    await _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait<dynamic>([
      _loadSteps(),
      _loadSleep(),
      _loadMeals(),
    ]);
  }

  Future<bool> login(String email, String password) async {
    final user = await _database.fetchUserByCredentials(email, password);
    if (user == null) {
      return false;
    }
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadSteps() async {
    _stepLogs = await _database.fetchStepLogs();
    notifyListeners();
  }

  Future<void> _loadSleep() async {
    _sleepLogs = await _database.fetchSleepLogs();
    notifyListeners();
  }

  Future<void> _loadMeals() async {
    _mealEntries = await _database.fetchMealEntries();
    notifyListeners();
  }

  Future<void> addStepLog(StepLog log) async {
    await _database.insertStepLog(log);
    await _loadSteps();
  }

  Future<void> updateStepLog(StepLog log) async {
    await _database.updateStepLog(log);
    await _loadSteps();
  }

  Future<void> deleteStepLog(int id) async {
    await _database.deleteStepLog(id);
    await _loadSteps();
  }

  Future<void> addSleepLog(SleepLog log) async {
    await _database.insertSleepLog(log);
    await _loadSleep();
  }

  Future<void> updateSleepLog(SleepLog log) async {
    await _database.updateSleepLog(log);
    await _loadSleep();
  }

  Future<void> deleteSleepLog(int id) async {
    await _database.deleteSleepLog(id);
    await _loadSleep();
  }

  Future<void> addMealEntry(MealEntry entry) async {
    await _database.insertMealEntry(entry);
    await _loadMeals();
  }

  Future<void> updateMealEntry(MealEntry entry) async {
    await _database.updateMealEntry(entry);
    await _loadMeals();
  }

  Future<void> deleteMealEntry(int id) async {
    await _database.deleteMealEntry(id);
    await _loadMeals();
  }
}
