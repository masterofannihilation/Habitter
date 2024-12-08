import 'package:flutter/material.dart';
import 'package:habitter_itu/views/category_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'views/components/appbar.dart';
import 'package:habitter_itu/constants.dart';
import 'views/components/bottom_bar.dart';
import 'views/components/add_button.dart';
import 'package:habitter_itu/views/profile_page.dart';
import 'views/components/add_habit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/category.dart';
import 'models/habit.dart';
import 'models/schedule.dart';
import 'controllers/habit_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ScheduleAdapter());

  Hive.registerAdapter(FrequencyUnitAdapter());
  Hive.registerAdapter(ScheduleTypeAdapter());

  await Hive.openBox<Habit>('habits');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habitter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final HabitController _habitController = HabitController();

  @override
  void initState() {
    super.initState();
    _habitController.init();
  }

  Future<List<Habit>> get _selectedDayHabits async {
    if (_selectedDay == null) {
      return [];
    }
    List<Habit> habits = await _habitController.getHabits();
    return habits.where((habit) {
      return isSameDay(habit.startDate, _selectedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                      16.0), // Add padding around the container
                  child: Container(
                    decoration: BoxDecoration(
                      color: habitColor, // Background color of the container
                      borderRadius:
                          BorderRadius.circular(16.0), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDay, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onFormatChanged: (format) {
                        if (_calendarFormat != format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        }
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(
                            color: Colors.white), // Default text color
                        weekendTextStyle: TextStyle(
                            color: Colors.white), // Weekend text color
                        selectedTextStyle: TextStyle(
                            color: Colors.white), // Selected day text color
                        todayTextStyle: TextStyle(
                            color: Colors.white), // Today's date text color
                      ),
                      headerStyle: HeaderStyle(
                        titleTextStyle:
                            TextStyle(color: Colors.white), // Title text color
                        formatButtonTextStyle: TextStyle(
                            color: Colors.white), // Format button text color
                        leftChevronIcon: Icon(Icons.chevron_left,
                            color: Colors.white), // Left chevron icon
                        rightChevronIcon: Icon(Icons.chevron_right,
                            color: Colors.white), // Right chevron icon
                      ),
                    ),
                  ),
                ),
                FutureBuilder<List<Habit>>(
                  future: _selectedDayHabits,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No habits for the selected day');
                    } else {
                      return Column(
                        children: snapshot.data!.map((habit) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 20.0),
                            child: Container(
                              height: 80.0, // Set the height of the container
                              decoration: BoxDecoration(
                                color: habitColor, // Set the tile color here
                                borderRadius: BorderRadius.circular(
                                    12.0), // Rounded corners
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                title: Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: Colors.white, // Set the text color
                                    fontSize: 18.0, // Increase the font size
                                  ),
                                ),
                                trailing: Checkbox(
                                  value: habit.isDone,
                                  onChanged: (value) {
                                    setState(() {
                                      habit.isDone = value!;
                                      _habitController.updateHabit(
                                          habit.key as int, habit);
                                    });
                                  },
                                  activeColor:
                                      Colors.white, // Set the active color
                                  checkColor: habitColor, // Set the check color
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AddButton(
                onPressed: _showAddHabitDialog,
                // child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        selectedIndex: 0,
      ),
    );
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddHabitDialog();
      },
    );
  }
}
