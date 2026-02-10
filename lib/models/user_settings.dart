// lib/models/user_settings.dart

import 'package:hive_flutter/hive_flutter.dart';

// Note: This file uses Hive without code generation (for simplicity)
// If you want code generation, uncomment the line below and run: flutter packages pub run build_runner build
// part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  int defaultMenstrualDays;

  @HiveField(1)
  int defaultCycleLength;

  @HiveField(2)
  bool notificationsEnabled;

  @HiveField(3)
  DateTime? reminderTime;

  UserSettings({
    this.defaultMenstrualDays = 7,
    this.defaultCycleLength = 28,
    this.notificationsEnabled = true,
    this.reminderTime,
  });
}

/// Manual adapter for UserSettings (no code generation required)
class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    return UserSettings(
      defaultMenstrualDays: reader.read(),
      defaultCycleLength: reader.read(),
      notificationsEnabled: reader.read(),
      reminderTime: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer.write(obj.defaultMenstrualDays);
    writer.write(obj.defaultCycleLength);
    writer.write(obj.notificationsEnabled);
    writer.write(obj.reminderTime);
  }
}
