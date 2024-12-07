import 'package:hive/hive.dart';

part 'schedule.g.dart';

enum ScheduleType { periodic, statical, interval }

enum FrequencyUnit { days, weeks, months }

@HiveType(typeId: 3)
class Schedule extends HiveObject {
  @HiveField(0)
  ScheduleType type;

  @HiveField(1)
  int frequency;

  @HiveField(2)
  FrequencyUnit frequencyUnit;

  @HiveField(3)
  List<int> staticDays;

  Schedule({
    required this.type,
    this.frequency = 1, // Default to every day/interval
    this.frequencyUnit = FrequencyUnit.days, // Default to days
    this.staticDays = const [], // Default to no specific days
  }) {
    _validateSchedule();
  }

  void _validateSchedule() {
    if (type == ScheduleType.periodic || type == ScheduleType.interval) {
      if (frequency <= 0) {
        throw ArgumentError(
            "Frequency must be greater than 0 for periodic or interval schedules.");
      }
    } else if (type == ScheduleType.statical) {
      if (staticDays.isEmpty) {
        throw ArgumentError(
            "Static days cannot be empty for statical schedules.");
      }
    }
  }
}
