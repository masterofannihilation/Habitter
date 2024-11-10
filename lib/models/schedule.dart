import 'package:hive/hive.dart';

enum ScheduleType {
  periodic,
  statical,
  interval
}

@HiveType(typeId: 1)
class Schedule extends HiveObject {
  @HiveField(0)
  ScheduleType type;

  @HiveField(1)
  int frequency;

  @HiveField(2)
  String frequencyUnit;

  @HiveField(3)
  List <int> staticDays;

  Schedule({required this.type, required this.frequency, required this.frequencyUnit, required this.staticDays});  
}