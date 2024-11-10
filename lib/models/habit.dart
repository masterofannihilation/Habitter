import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
//import schedule
import 'schedule.dart';
import 'category.dart';


part 'habit.g.dart';


// enum ScheduleType{
//   periodic, //4x do tyzdna
//   statical, // kazdy pondelok
//   interval // raz za 4 dni
// }

@HiveType(typeId: 1)
class Habit extends HiveObject {
  //@HiveField(0)
  // String id;

  @HiveField(0)
  String title;

  @HiveField(1)
  Map<String, bool> completionStatus;

  @HiveField(2)
  Schedule schedule;  // Type of schedule

  // @HiveField(4)
  // Category category;
 
  @HiveField(3)
  bool reminder;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime reminderTime;

  @HiveField(6)
  DateTime startDate;

  Habit({
    // String? id,
    required this.title,
    required this.schedule,
    // this.category = Category.none,
    this.reminder = false,
    this.description = '',
    DateTime? reminderTime,
    DateTime? startDate,
  })  : 
    // this.id = id ?? const Uuid().v4(),
    this.reminderTime = reminderTime ?? DateTime.now(),
    this.startDate = startDate ?? DateTime.now(),
    this.completionStatus = {};



  // Convert date to string key (e.g., "2024-11-09")
  String _dateToKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Mark a day as done/not done
  void markDay(DateTime date, bool completed) {
    completionStatus[_dateToKey(date)] = completed;
    save();
  }

  // Check if a day is completed
  bool isDayComplete(DateTime date) {
    return completionStatus[_dateToKey(date)] ?? false;
  }

  // Check if habit should occur on this date
  bool shouldOccurOnDate(DateTime date) {
    if (date.isBefore(startDate)) return false;

    switch(schedule.type){
      case ScheduleType.periodic:
        return true;
      //every wednesday
      case ScheduleType.statical:
      
        return schedule.staticDays.contains(date.weekday);
      case ScheduleType.interval:
        return date.difference(startDate).inDays % schedule.frequency == 0;  
    }
}
}