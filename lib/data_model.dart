// data_model.dart

import 'package:hive_flutter/hive_flutter.dart';

class DailyData {
  final DateTime date;
  late final bool isPeriod;
  final String mood;
  

  DailyData({
    required this.date,
    this.isPeriod = false,
    required this.mood,
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