import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/habit.dart';
import 'package:habitter_itu/constants.dart';
import 'components/appbar.dart';
import 'components/bottom_bar.dart';
import 'components/edit_habit.dart';
import 'components/search_input.dart';
import 'habit_page.dart';
import 'package:habitter_itu/models/category.dart'; // Import Category model

class HabitsListPage extends StatefulWidget {
  final Category? category; // Add category parameter

  HabitsListPage({this.category});

  @override
  _HabitsListPageState createState() => _HabitsListPageState();
}

class _HabitsListPageState extends State<HabitsListPage> {
  final HabitController _habitController = HabitController();
  List<Habit> habits = [];
  List<Habit> filteredHabits = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
    searchController.addListener(_filterHabits);
  }

  Future<void> _loadHabits() async {
    await _habitController.init();
    List<Habit> loadedHabits = await _habitController.getHabits();
    setState(() {
      habits = loadedHabits;
      _filterHabits(); // Apply initial filter
    });
  }

  void _filterHabits() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredHabits = habits.where((habit) {
        bool matchesCategory =
            widget.category == null || habit.category.id == widget.category!.id;
        bool matchesQuery = habit.title.toLowerCase().contains(query) ||
            habit.description.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
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
        _filterHabits(); // Update the filtered list after deletion
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/target.svg',
                  color: Colors.white,
                ),
                Text(
                  widget.category != null
                      ? ' ${widget.category!.name}'
                      : ' All Habits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SearchInput(
            controller: searchController,
            onChanged: (value) => _filterHabits(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredHabits.length,
              itemBuilder: (context, index) {
                final habit = filteredHabits[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 20.0),
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
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomBar(selectedIndex: 1),
    );
  }
}
