import 'package:hive_flutter/hive_flutter.dart';

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
