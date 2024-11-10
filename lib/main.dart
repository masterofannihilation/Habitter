import 'package:flutter/material.dart';
import 'package:itu_habitter/views/category_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'habit_service.dart';
import 'habit.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:itu_habitter/firebase_options.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'habit.dart';
import 'habit_service.dart';
import 'components/appbar.dart';
import 'package:itu_habitter/constants.dart';

import 'components/bottom_bar.dart';
import 'components/add_button.dart';
import 'package:itu_habitter/views/profile_page.dart';
import 'components/add_habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'models/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  bool hasReminder = false;

  final Box<Habit> _habitBox = Hive.box<Habit>('habits');

  List<Habit> get _selectedDayHabits {
    if (_selectedDay == null) {
      return [];
    }
    return _habitBox.values.where((habit) {
      return isSameDay(habit.date, _selectedDay);
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

          ..._selectedDayHabits.map((habit) => ListTile(
                tileColor: habitColor, // Set the tile color here
                title: Text(habit.name),
                trailing: Checkbox(
                  value: habit.isDone,
                  onChanged: (bool? value) {
                    setState(() {
                      habit.isDone = value!;
                      habit.save();
                    });
                  },
                ),
              )),
          // TODO: dajte to dole doprava hosi
          
          
          // Use the existing AddButton to show the AddHabitDialog
          AddButton(onPressed: () {
            showAddHabitDialog(context, /*_habitBox,*/ _selectedDay);
          }),

          AddButton(onPressed: _showAddHabitDialog),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        tooltip: 'Add Habit',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitSection(String title, List<Habit> habits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
)),
        ),
        ...habits.map((habit) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text(habit.name),
              trailing: Checkbox(
                value: habit.isDone,
                onChanged: (bool? value) {
                  setState(() {
                    habit.isDone = value ?? false;
                  });
                },
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

void _showAddHabitDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final _formKey = GlobalKey<FormState>();
      String habitName = '';
      String scheduleType = 'Daily'; // Default schedule type
      bool hasReminder = false; // Default reminder state
      TimeOfDay? reminderTime; // Default reminder time
      String description = ''; // Default description
      List<String> categories = ['Work', 'Health', 'Hobby']; // Example categories
      List<String> scheduleTypes = ['Daily', 'Weekly', 'Monthly']; // Example schedule types

      return Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: backgroundColor, // Change the background color here
        ),
        child: AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(
                        'assets/chevron-left.svg', // Path to your left SVG
                        height: 24.0,
                        width: 24.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), // Change the color to white
                      ),
                    ),
                    Center(
                      child: Text(
                        'Add Habit',
                        style: TextStyle(color: Colors.white), // Change the text color here
                      ),
                    ),
                    GestureDetector(
                      // onTap: () {
                      //   if (_formKey.currentState!.validate()) {
                      //     _formKey.currentState!.save();
                      //     setState(() {
                      //       final newHabit = Habit(
                      //           name: habitName,
                      //           date: _selectedDay ?? DateTime.now(),
                      //           isDone: false,
                      //           reminder: hasReminder,
                      //           reminderTime: reminderTime);
                      //       _habitBox.add(newHabit);
                      //     });
                      //     Navigator.of(context).pop();
                      //   }
                      // },
                      child: SvgPicture.asset(
                        'assets/check.svg', // Path to your right SVG
                        height: 24.0,
                        width: 24.0,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn), // Change the color to white
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey, // Change the color of the line here
                thickness: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Choose a Category:',
                    style: TextStyle(color: Colors.white), // Change the text color here
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        // Add your logic to add a new category
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Chip(
                                label: Text(category),
                                backgroundColor: boxColor, // Change the color of the category bubbles here
                                labelStyle: TextStyle(color: Colors.white),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0), // Change the corner radius here
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: boxColor, // Change the background color of the bubble here
                        borderRadius: BorderRadius.circular(15.0), // Change the corner radius here
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextFormField(
                        onChanged: (value) {
                          habitName = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Name...",
                          border: InputBorder.none, // Remove the default border
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a habit name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          habitName = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Schedule Type:',
                          style: TextStyle(color: Colors.white), // Change the text color here
                        ),
                        Container(
                          width: 150, // Set the width of the dropdown
                          height: 40, // Set the height of the dropdown
                          decoration: BoxDecoration(
                            color: boxColor, // Change the background color of the dropdown here
                            borderRadius: BorderRadius.circular(15.0), // Change the corner radius here
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: DropdownButton<String>(
                            value: scheduleType,
                            dropdownColor: boxColor, // Change the dropdown background color here
                            onChanged: (String? newValue) {
                              setState(() {
                                scheduleType = newValue!;
                              });
                            },
                            items: scheduleTypes.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(color: Colors.white)), // Change the text color here
                              );
                            }).toList(),
                            isExpanded: true, // Make the dropdown take the full width of the container
                            underline: SizedBox(), // Remove the default underline
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reminder:',
                          style: TextStyle(color: Colors.white), // Change the text color here
                        ),
                        Switch(
                          value: hasReminder,
                          onChanged: (bool value) {
                            setState(() {
                              hasReminder = value;
                            });
                          },
                          activeColor: Colors.white, // Change the active color of the switch here
                          activeTrackColor: orangeColor, // Change the active track color of the switch here
                          inactiveThumbColor: Colors.white, // Change the inactive thumb color to white
                        ),
                        // if (hasReminder)
                          TextButton(
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            );
                            if (picked != null && picked != reminderTime) {
                            setState(() {
                              reminderTime = picked;
                            });
                            }
                          },
                          child: Text(
                            reminderTime != null ? reminderTime!.format(context) : TimeOfDay.now().format(context),
                            style: TextStyle(color: Colors.white),
                          ),
                          ),
                      ],
                    ),
                  SizedBox(height: 16.0),
                    Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: boxColor, // Change the background color of the bubble here
                        borderRadius: BorderRadius.circular(15.0), // Change the corner radius here
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextFormField(
                        maxLines: 3,
                        onChanged: (value) {
                          description = value;
                        },
                        decoration: InputDecoration(
                          hintText: "Description...",
                          border: InputBorder.none, // Remove the default border
                        ),
                        onSaved: (value) {
                          description = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              );
            },
          ),
        ),
      );
    },
  );
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                setState(() {

                  _habits.add(Habit(
                      name: habitName,
                      date: _selectedDay ?? DateTime.now(),
                      isDone: false));
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
}