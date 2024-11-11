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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  await Hive.openBox<Habit>('habits');

  Hive.registerAdapter(CategoryAdapter());

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

  final Box<Habit> _habitBox = Hive.box<Habit>('habits');

  List<Habit> get _selectedDayHabits {
    if (_selectedDay == null) {
      return [];
    }
    return _habitBox.values.where((habit) {
      return isSameDay(habit.startDate, _selectedDay);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(16.0), // Add padding around the container
            child: Container(
              decoration: BoxDecoration(
                color: habitColor, // Background color of the container
                borderRadius: BorderRadius.circular(16.0), // Rounded corners
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
                  defaultTextStyle:
                      TextStyle(color: Colors.white), // Default text color
                  weekendTextStyle:
                      TextStyle(color: Colors.white), // Weekend text color
                  selectedTextStyle:
                      TextStyle(color: Colors.white), // Selected day text color
                  todayTextStyle:
                      TextStyle(color: Colors.white), // Today's date text color
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

          // ..._selectedDayHabits.map((habit) => ListTile(
          //       tileColor: habitColor, // Set the tile color here
          //       title: Text(habit.name),
          //       trailing: Checkbox(
          //         value: habit.isDone,
          //         onChanged: (bool? value) {
          //           setState(() {
          //             habit.isDone = value!;
          //             habit.save();
          //           });
          //         },
          //       ),
          //     )),
          // TODO: dajte to dole doprava hosi

          AddButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddHabitDialog(),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: BottomBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
