import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/habit.dart';
import 'package:habitter_itu/constants.dart';
import 'components/appbar.dart';
import 'components/bottom_bar.dart';
import 'components/edit_habit.dart';
import 'habit_page.dart'; // Import HabitPage

class HabitsListPage extends StatefulWidget {
  @override
  _HabitsListPageState createState() => _HabitsListPageState();
}

class _HabitsListPageState extends State<HabitsListPage> {
  final HabitController _habitController = HabitController();
  List<Habit> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    await _habitController.init();
    List<Habit> loadedHabits = await _habitController.getHabits();
    setState(() {
      habits = loadedHabits;
    });
  }

  void _editHabit(Habit habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditHabitDialog(habit: habit);
      },
    ).then((_) {
      _loadHabits(); // Reload habits after editing
    });
  }

  void _deleteHabit(int index) {
    _habitController.deleteHabit(index).then((_) {
      setState(() {
        habits.removeAt(index);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'All Habits'),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
            child: Slidable(
              key: ValueKey(habit.key),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.25,
                dismissible: DismissiblePane(onDismissed: () {
                  _deleteHabit(index);
                }),
                children: [
                  SlidableAction(
                    onPressed: (_) => _deleteHabit(index),
                    backgroundColor: redColor,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HabitPage(habit: habit)),
                  );
                },
                child: Container(
                  height: 80.0,
                  decoration: BoxDecoration(
                    color: habitColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: Text(
                      habit.category.emoji ??
                          '😀', // Display the category emoji
                      style: TextStyle(fontSize: 40.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _editHabit(habit),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomBar(selectedIndex: 1),
    );
  }
}
