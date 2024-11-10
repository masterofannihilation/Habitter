import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/constants.dart';
import 'package:hive/hive.dart';
import 'package:habitter_itu/models/habit.dart'; // Import the Habit model

class AddHabitDialog extends StatefulWidget {
  // final Box<Habit> habitBox;
  final DateTime? selectedDay;

  AddHabitDialog({/*required this.habitBox,*/ this.selectedDay});

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  String habitName = '';
  String scheduleType = 'Daily'; // Default schedule type
  bool hasReminder = false; // Default reminder state
  TimeOfDay? reminderTime; // Default reminder time
  String description = ''; // Description
  List<String> categories = ['Work', 'Health', 'Hobby']; // Example categories
  List<String> scheduleTypes = [
    'Daily',
    'Weekly',
    'Monthly'
  ]; // Example schedule types

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor:
            backgroundColor, // Change the background color here
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
                      colorFilter: ColorFilter.mode(Colors.white,
                          BlendMode.srcIn), // Change the color to white
                    ),
                  ),
                  Center(
                    child: Text(
                      'Add Habit',
                      style: TextStyle(
                          color: Colors.white), // Change the text color here
                    ),
                  ),
                  GestureDetector(
                    // onTap: () {
                    //   if (_formKey.currentState!.validate()) {
                    //     _formKey.currentState!.save();
                    //     setState(() {
                    //       final newHabit = Habit(
                    //         title: habitName,
                    //         schedule: Schedule(type: ScheduleType.values.firstWhere((e) => e.toString().split('.').last == scheduleType)),
                    //         reminder: hasReminder,
                    //         reminderTime: reminderTime != null ? DateTime(0, 0, 0, reminderTime!.hour, reminderTime!.minute) : null,
                    //         description: description,
                    //       );
                    //       widget.habitBox.add(newHabit);
                    //     });
                    //     Navigator.of(context).pop();
                    //   }
                    // },
                    child: SvgPicture.asset(
                      'assets/check.svg', // Path to your right SVG
                      height: 24.0,
                      width: 24.0,
                      colorFilter: ColorFilter.mode(Colors.white,
                          BlendMode.srcIn), // Change the color to white
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
                  style: TextStyle(
                      color: Colors.white), // Change the text color here
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Chip(
                              label: Text(category),
                              backgroundColor:
                                  boxColor, // Change the color of the category bubbles here
                              labelStyle: TextStyle(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15.0), // Change the corner radius here
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
                        color:
                            boxColor, // Change the background color of the bubble here
                        borderRadius: BorderRadius.circular(
                            15.0), // Change the corner radius here
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
                          style: TextStyle(
                              color:
                                  Colors.white), // Change the text color here
                        ),
                        Container(
                          width: 150, // Set the width of the dropdown
                          height: 40, // Set the height of the dropdown
                          decoration: BoxDecoration(
                            color:
                                boxColor, // Change the background color of the dropdown here
                            borderRadius: BorderRadius.circular(
                                15.0), // Change the corner radius here
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: DropdownButton<String>(
                            value: scheduleType,
                            dropdownColor:
                                boxColor, // Change the dropdown background color here
                            onChanged: (String? newValue) {
                              setState(() {
                                scheduleType = newValue!;
                              });
                            },
                            items: scheduleTypes
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: TextStyle(
                                        color: Colors
                                            .white)), // Change the text color here
                              );
                            }).toList(),
                            isExpanded:
                                true, // Make the dropdown take the full width of the container
                            underline:
                                SizedBox(), // Remove the default underline
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
                          style: TextStyle(
                              color:
                                  Colors.white), // Change the text color here
                        ),
                        Switch(
                          value: hasReminder,
                          onChanged: (bool value) {
                            setState(() {
                              hasReminder = value;
                            });
                          },
                          activeColor: Colors
                              .white, // Change the active color of the switch here
                          activeTrackColor:
                              orangeColor, // Change the active track color of the switch here
                          inactiveThumbColor: Colors
                              .white, // Change the inactive thumb color to white
                        ),
                        if (hasReminder)
                          TextButton(
                            onPressed: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: reminderTime ?? TimeOfDay.now(),
                              );
                              if (picked != null && picked != reminderTime) {
                                setState(() {
                                  reminderTime = picked;
                                });
                              }
                            },
                            child: Text(
                              reminderTime != null
                                  ? reminderTime!.format(context)
                                  : 'Set Time',
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
                        color:
                            boxColor, // Change the background color of the bubble here
                        borderRadius: BorderRadius.circular(
                            15.0), // Change the corner radius here
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
  }
}

void showAddHabitDialog(
    BuildContext context, /*Box<Habit> habitBox,*/ DateTime? selectedDay) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddHabitDialog(/*habitBox: habitBox,*/ selectedDay: selectedDay);
    },
  );
}
