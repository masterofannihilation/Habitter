import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'schedule.dart'; // Assuming you have a schedule.dart file
import 'category.dart'; // Assuming you have a category.dart file

part 'habit.g.dart';

// enum ScheduleType {
//   periodic, // Habit occurs periodically (e.g., every day)
//   statical, // Habit occurs on specific days (e.g., every Monday)
//   interval // Habit occurs on a specific interval (e.g., every 4 days)
// }

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  Map<String, bool> completionStatus;

  @HiveField(2)
  Schedule schedule; // Type of schedule

  @HiveField(3)
  bool reminder;

  @HiveField(4)
  String description;

  @HiveField(5)
  DateTime reminderTime;

  @HiveField(6)
  DateTime startDate;

  Habit({
    required this.title,
    required this.schedule,
    this.reminder = false,
    this.description = '',
    DateTime? reminderTime,
    DateTime? startDate,
  })  : this.reminderTime = reminderTime ?? DateTime.now(),
        this.startDate = startDate ?? DateTime.now(),
        this.completionStatus = {};

  // Getter for isDone (for simplicity, checks if the habit is completed today)
  bool get isDone {
    String today = _dateToKey(DateTime.now());
    return completionStatus[today] ?? false;
  }

  // Setter for isDone (marks today's completion status)
  set isDone(bool value) {
    String today = _dateToKey(DateTime.now());
    completionStatus[today] = value;
    save(); // Save the habit after changing the status
  }

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

    switch (schedule.type) {
      case ScheduleType.periodic:
        return true;
      case ScheduleType.statical:
        return schedule.staticDays.contains(date.weekday);
      case ScheduleType.interval:
        return date.difference(startDate).inDays % schedule.frequency == 0;
    }
  }
}
