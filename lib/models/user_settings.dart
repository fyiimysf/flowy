import 'package:hive_flutter/hive_flutter.dart';

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
