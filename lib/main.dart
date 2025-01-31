
import 'package:floi/cycle_tracker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox<int>('settings');
  Hive.registerAdapter(OptionsAdapter());
  await Hive.openBox<Options>('Options');
  Hive.registerAdapter(DailyDataAdapter());
  await Hive.openBox<DailyData>('dailyData');
  runApp(const MyApp());
}

class PredictedRange {
  final int index;
  final DateTime startDate;
  final DateTime endDate;

  PredictedRange({
    required this.index,
    required this.startDate,
    required this.endDate,
  });
}

class PhaseDetail {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;

  PhaseDetail({
    required this.name,
    required this.startDate,
    required this.endDate,
  }) : duration = endDate.difference(startDate).inDays + 1;
}

class PeriodRange {
  final DateTime startDate;
  final DateTime endDate;
  final int duration;

  PeriodRange(this.startDate, this.endDate)
      : duration = endDate.difference(startDate).inDays + 1;
}

@HiveType(typeId: 0)
class DailyData extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  bool isPeriod;

  @HiveField(2)
  String? mood;

  DailyData({
    required this.date,
    this.isPeriod = false,
    this.mood,
  });
}

class DailyDataAdapter extends TypeAdapter<DailyData> {
  @override
  final int typeId = 0;

  @override
  DailyData read(BinaryReader reader) {
    return DailyData(
      date: reader.read(),
      isPeriod: reader.read(),
      mood: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyData obj) {
    writer.write(obj.date);
    writer.write(obj.isPeriod);
    writer.write(obj.mood);
  }
}

@HiveType(typeId: 1)
class Options extends HiveObject {
  @HiveField(0)
  bool darkMode;

  Options({this.darkMode = false});
}

class OptionsAdapter extends TypeAdapter<Options> {
  @override
  final int typeId = 1;

  @override
  Options read(BinaryReader reader) {
    return Options(darkMode: reader.read());
  }

  @override
  void write(BinaryWriter writer, Options obj) {
    writer.write(obj.darkMode);
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context,) {
    

    return MaterialApp(
      title: 'Flowy',
      themeMode: ThemeMode.light,
      darkTheme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark().copyWith(
          primary: Colors.pink,
          secondary: Colors.pinkAccent,
        ),
        // snackBarTheme: SnackBarThemeData(
        //   backgroundColor: Colors.pink,
        //   contentTextStyle: const TextStyle(color: Colors.white)),
        cardColor: const Color(0xFF2C2C2C),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.702)),
          labelLarge: TextStyle(fontSize: 16, color: Colors.white),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
      theme: ThemeData(
        primarySwatch: Colors.pink,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.pink[50],
        colorScheme: const ColorScheme.light().copyWith(
          primary: Colors.pink,
          secondary: Colors.pinkAccent,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          labelLarge: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        cardColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
      home: const CycleTracker(),
      debugShowCheckedModeBanner: false,
    );
  }
}

