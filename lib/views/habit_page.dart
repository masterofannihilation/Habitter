import 'package:flutter/material.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/habit.dart';
import 'package:habitter_itu/constants.dart';
import 'components/appbar.dart';
import 'components/bottom_bar.dart';
import 'components/edit_habit.dart';

class HabitPage extends StatefulWidget {
  final Habit habit;

  HabitPage({required this.habit});

  @override
  _HabitPageState createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final HabitController _habitController = HabitController();

  @override
  void initState() {
    super.initState();
  }

  void _editHabit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditHabitDialog(habit: widget.habit);
      },
    ).then((_) {
      setState(() {}); // Refresh the page after editing
    });
  }

  void _toggleHabitCompletion() {
    setState(() {
      widget.habit.isDone = !widget.habit.isDone;
      _habitController.updateHabit(widget.habit.key as int, widget.habit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.habit.title),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: habitColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        widget.habit.category.emoji ??
                            '😀', // Display the category emoji
                        style: TextStyle(fontSize: 80.0),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Category: ${widget.habit.category.name}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Frequency: ${widget.habit.schedule.frequency} times per ${widget.habit.schedule.frequencyUnit.toString().split('.').last}',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Completion Rate: ${widget.habit.completionStatus.length}%',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        'Description',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            widget.habit.description,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: habitColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleHabitCompletion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          widget.habit.isDone ? Colors.green : Colors.red,
                    ),
                    child: Text(
                      widget.habit.isDone ? 'Undo' : 'Complete',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _editHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomBar(selectedIndex: 1),
    );
  }
}
