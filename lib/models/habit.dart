import 'package:hive/hive.dart';
import 'schedule.dart';
import 'package:uuid/uuid.dart';
import 'category.dart';

part 'habit.g.dart';

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

  @HiveField(7)
  Category category;

  @HiveField(8)
  String id;

  Habit({
    required this.title,
    required this.schedule,
    this.reminder = false,
    this.description = "",
    DateTime? reminderTime,
    DateTime? startDate,
    required this.category,
  })  : this.reminderTime = reminderTime ?? DateTime.now(),
        this.startDate = startDate ?? DateTime.now(),
        this.id = Uuid().v4(), // Generate unique ID
        this.completionStatus = {};

  // Check if the habit is completed on a specific date
  bool isDoneOn(DateTime date) {
    String dateKey = _dateToKey(date);
    return completionStatus[dateKey] ?? false;
  }

  // Mark the habit as done or not done on a specific date
  void setDoneOn(DateTime date, bool value) {
    String dateKey = _dateToKey(date);
    completionStatus[dateKey] = value;
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
    // Normalize both dates to 00:00:00
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    if (normalizedDate.isBefore(normalizedStartDate)) {
      return false;
    }

    switch (schedule.type) {
      case ScheduleType.periodic:
        if (schedule.frequencyUnit == FrequencyUnit.weeks)
          return shouldDisplayForWeek(date);
        else
          return shouldDisplayForMonth(date);
      case ScheduleType.statical:
        return schedule.staticDays.contains(normalizedDate.weekday);
      case ScheduleType.interval:
        final daysSinceStart =
            normalizedDate.difference(normalizedStartDate).inDays;

        // Handle different frequency units
        switch (schedule.frequencyUnit) {
          case FrequencyUnit.days:
            return daysSinceStart % schedule.frequency == 0;

          case FrequencyUnit.weeks:
            // Check if today matches the habit's schedule
            if (daysSinceStart >= 0 &&
                daysSinceStart % (7 * schedule.frequency) == 0) {
                  print("$daysSinceStart and ${schedule.frequency}:: ${daysSinceStart % (7 * schedule.frequency)}");
                  print("NOW:  ${DateTime.now().weekday}");
                  return true; // Habit is due today
            }
            return false; // Habit is not due today

          case FrequencyUnit.months:
            // Calculate the difference in months
            final monthsSinceStart =
                (normalizedDate.year - normalizedStartDate.year) * 12 +
                    (normalizedDate.month - normalizedStartDate.month);

            return monthsSinceStart % schedule.frequency == 0 &&
                normalizedDate.day == normalizedStartDate.day;

          default:
            return false;
        }
    }
  }

  int getTotalCompletions() {
    return completionStatus.values.where((status) => status).length;
  }

  // Get the current streak of completions
  int getStreak() {
    int streak = 0;
    DateTime today = DateTime.now();
    while (isDoneOn(today.subtract(Duration(days: streak)))) {
      streak++;
    }
    return streak;
  }

  // Get static days as a string
  String getStaticDays() {
    List<String> days = [];
    for (int day in schedule.staticDays) {
      switch (day) {
        case DateTime.monday:
          days.add("Mon");
          break;
        case DateTime.tuesday:
          days.add("Tue");
          break;
        case DateTime.wednesday:
          days.add("Wed");
          break;
        case DateTime.thursday:
          days.add("Thu");
          break;
        case DateTime.friday:
          days.add("Fri");
          break;
        case DateTime.saturday:
          days.add("Sat");
          break;
        case DateTime.sunday:
          days.add("Sun");
          break;
      }
    }
    return days.join(", ");
  }

  int getCompletions(DateTime date) {
    if (schedule.frequencyUnit == FrequencyUnit.weeks) {
      return getWeeklyCompletions(date);
    } else if (schedule.frequencyUnit == FrequencyUnit.months) {
      return getMonthlyCompletions(date);
    } else {
      return 0;
    }
  }

  // Calculate the number of completions for the current week
  int getWeeklyCompletions(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));

    int completedThisWeek = 0;
    for (var i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      final currentDayKey = _dateToKey(currentDay);
      if (completionStatus.containsKey(currentDayKey) &&
          completionStatus[currentDayKey] == true) {
        completedThisWeek++;
      }
    }
    return completedThisWeek;
  }

  // Calculate the number of completions for the current month
  int getMonthlyCompletions(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    int completedThisMonth = 0;
    for (var i = 0; i < endOfMonth.day; i++) {
      final currentDay = startOfMonth.add(Duration(days: i));
      final currentDayKey = _dateToKey(currentDay);
      if (completionStatus.containsKey(currentDayKey) &&
          completionStatus[currentDayKey] == true) {
        completedThisMonth++;
      }
    }
    return completedThisMonth;
  }

  // Check if habit should be displayed based on weekly completion count
  bool shouldDisplayForWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    // Check if the habit was done on the given day
    if (isDoneOn(date)) {
      return true;
    }

    print("tu SOM");
    // Count the number of completions this week
    int completedThisWeek = 0;
    for (var i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      if (completionStatus.containsKey(_dateToKey(currentDay)) &&
          completionStatus[_dateToKey(currentDay)] == true) {
        completedThisWeek++;
      }
    }

    // Return true if the habit wasn't done more than n times that week
    return completedThisWeek < schedule.frequency;
  }

// Check if habit should be displayed based on monthly completion count
  bool shouldDisplayForMonth(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);

    // Check if the habit was done on the given day
    if (isDoneOn(date)) {
      return true;
    }

    // Count the number of completions this month
    int completedThisMonth = 0;
    for (var i = 0; i < endOfMonth.day; i++) {
      final currentDay = startOfMonth.add(Duration(days: i));
      if (completionStatus.containsKey(_dateToKey(currentDay)) &&
          completionStatus[_dateToKey(currentDay)] == true) {
        completedThisMonth++;
      }
    }

    // Return true if the habit wasn't done more than n times that month
    return completedThisMonth < schedule.frequency;
  }
}
