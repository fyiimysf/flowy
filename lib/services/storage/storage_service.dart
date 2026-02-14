import 'package:hive_flutter/hive_flutter.dart';
import '../../models/cycle_models.dart';

class StorageKeys {
  static const String settings = 'settings';
  static const String options = 'options';
  static const String dailyData = 'dailyData';
  static const String userSettings = 'userSettings';
  static const String menstrualDays = 'menstrualDays';
  static const String darkMode = 'darkMode';
}

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Box<DailyData> get dailyDataBox {
    if (!Hive.isBoxOpen(StorageKeys.dailyData)) {
      throw StateError(
          'dailyData box not opened. Ensure Hive.openBox<DailyData>("${StorageKeys.dailyData}") is called in main.dart');
    }
    return Hive.box<DailyData>(StorageKeys.dailyData);
  }

  Box<int> get settingsBox {
    if (!Hive.isBoxOpen(StorageKeys.settings)) {
      throw StateError(
          'settings box not opened. Ensure Hive.openBox<int>("${StorageKeys.settings}") is called in main.dart');
    }
    return Hive.box<int>(StorageKeys.settings);
  }

  Box<Options> get optionsBox {
    if (!Hive.isBoxOpen(StorageKeys.options)) {
      throw StateError(
          'options box not opened. Ensure Hive.openBox<Options>("${StorageKeys.options}") is called in main.dart');
    }
    return Hive.box<Options>(StorageKeys.options);
  }

  Future<void> saveDailyData(DateTime date, DailyData data) async {
    final key = _dateToKey(date);
    await dailyDataBox.put(key, data);
  }

  DailyData? getDailyData(DateTime date) {
    final key = _dateToKey(date);
    return dailyDataBox.get(key);
  }

  List<DailyData> getAllDailyData() {
    return dailyDataBox.values.toList();
  }

  List<DailyData> getPeriodDays() {
    return dailyDataBox.values.where((d) => d.isPeriod).toList();
  }

  int getMenstrualDays({int defaultValue = 7}) {
    return settingsBox.get(StorageKeys.menstrualDays,
            defaultValue: defaultValue) ??
        defaultValue;
  }

  Future<void> setMenstrualDays(int days) async {
    await settingsBox.put(StorageKeys.menstrualDays, days);
  }

  bool getDarkMode({bool defaultValue = false}) {
    final options = optionsBox.get('theme');
    return options?.darkMode ?? defaultValue;
  }

  Future<void> setDarkMode(bool isDark) async {
    var options = optionsBox.get('theme') ?? Options();
    options.darkMode = isDark;
    await optionsBox.put('theme', options);
  }

  Future<void> clearAllData() async {
    await dailyDataBox.clear();
    await settingsBox.clear();
    await optionsBox.clear();
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
