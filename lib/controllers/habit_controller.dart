import 'package:hive/hive.dart';
import 'package:habitter_itu/models/habit.dart';

class HabitController {
  static const String _boxName = 'habits';
  late Box<Habit> _habitBox;

  HabitController();

  // Initialize Hive box
  Future<void> init() async {
    _habitBox = await Hive.openBox<Habit>(_boxName);
  }

  Future<void> addHabit(Habit habit) async {
    try {
      await _habitBox.add(habit);
    } catch (e) {
      print("Error adding habit: $e");
    }
  }

  Future<void> updateHabit(int index, Habit habit) async {
    try {
      await _habitBox.putAt(index, habit);
    } catch (e) {
      print("Error updating habit: $e");
    }
  }

  Future<void> deleteHabit(int index) async {
    try {
      await _habitBox.deleteAt(index);
    } catch (e) {
      print("Error deleting habit: $e");
    }
  }

  Future<List<Habit>> getHabits() async {
    return _habitBox.values.toList();
  }

  Future<Habit?> getHabit(int index) async {
    return _habitBox.getAt(index);
  }

  List<Habit> getHabitsByTitle(String title) {
    return _habitBox.values
        .where((habit) => habit.title.contains(title))
        .toList();
  }

  // Close the box
  Future<void> closeBox() async {
    await _habitBox.close();
  }
}
