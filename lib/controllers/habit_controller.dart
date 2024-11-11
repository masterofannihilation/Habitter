import 'package:hive/hive.dart';
import 'package:habitter_itu/models/habit.dart';

class HabitController {
  final Box<Habit> _habitBox;

  HabitController(this._habitBox);

  Future<void> addHabit(Habit habit) async {
    await _habitBox.add(habit);
  }

  Future<void> updateHabit(int index, Habit habit) async {
    await _habitBox.putAt(index, habit);
  }

  Future<void> deleteHabit(int index) async {
    await _habitBox.deleteAt(index);
  }

  List<Habit> getHabits() {
    return _habitBox.values.toList();
  }

  Habit? getHabit(int index) {
    return _habitBox.getAt(index);
  }
}
