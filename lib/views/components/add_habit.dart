import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/constants.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/category.dart';
import 'package:habitter_itu/models/habit.dart'; // Import the Habit model
import 'package:habitter_itu/controllers/category_controller.dart';
import 'package:habitter_itu/views/components/add_category.dart';
import 'package:habitter_itu/models/schedule.dart';

class AddHabitDialog extends StatefulWidget {
  final DateTime? selectedDay;

  AddHabitDialog({
    this.selectedDay,
  });

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  String habitName = '';
  String scheduleType = 'Daily';
  bool hasReminder = false; // Default reminder state
  TimeOfDay? reminderTime; // Default reminder time
  String description = ''; // Description
  Category? selectedCategory; // Selected category for the habit

  final CategoryController _categoryController = CategoryController();
  final HabitController _habitController = HabitController();
  List<Category> categories = [];
  List<String> scheduleTypes = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _habitController.init();
  }

  Future<void> _loadCategories() async {
    await _categoryController.init();
    setState(() {
      categories = _categoryController.getCategories();
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScheduleType type;
      if (scheduleType == 'Daily') {
        type = ScheduleType.periodic;
      } else if (scheduleType == 'Weekly') {
        type = ScheduleType.periodic;
      } else {
        type = ScheduleType.periodic;
      }

      final newSchedule = Schedule(type: type);

      final newHabit = Habit(
          title: habitName, schedule: newSchedule, category: selectedCategory!);

      // Save the habit using HabitController
      _habitController.addHabit(newHabit);

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dialogBackgroundColor: backgroundColor,
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
                    onTap: () => Navigator.of(context).pop(),
                    child: SvgPicture.asset(
                      'assets/chevron-left.svg',
                      height: 24.0,
                      width: 24.0,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  const Text(
                    'Add Habit',
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: _submitForm, // Save the habit on tap
                    child: SvgPicture.asset(
                      'assets/check.svg',
                      height: 24.0,
                      width: 24.0,
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  'Choose a Category:',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final newCategory = await showDialog<Category>(
                        context: context,
                        builder: (_) => AddCategoryDialog(),
                      );
                      if (newCategory != null) {
                        setState(() {
                          _categoryController.addCategory(newCategory);
                          categories.add(newCategory);
                        });
                      }
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
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: selectedCategory == category,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedCategory = selected ? category : null;
                                });
                              },
                              backgroundColor: boxColor,
                              labelStyle: const TextStyle(color: Colors.white),
                              selectedColor: orangeColor,
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
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Habit Name Field
                _buildTextField(
                  label: "Name...",
                  onSaved: (value) => habitName = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a habit name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Schedule Type Dropdown
                _buildDropdown(
                  label: 'Schedule Type',
                  value: scheduleType,
                  items: scheduleTypes,
                  onChanged: (newValue) => setState(() {
                    scheduleType = newValue!;
                  }),
                ),

                const SizedBox(height: 16.0),

                // Reminder Switch
                _buildSwitch(
                  label: 'Reminder:',
                  value: hasReminder,
                  onChanged: (newValue) => setState(() {
                    hasReminder = newValue;
                  }),
                ),
                if (hasReminder)
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          reminderTime = picked;
                        });
                      }
                    },
                    child: Text(
                      reminderTime != null
                          ? reminderTime!.format(context)
                          : 'Set Time',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                const SizedBox(height: 16.0),

                // Description Field
                _buildTextField(
                  label: "Description...",
                  onSaved: (value) => description = value!,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: boxColor,
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child:
                        Text(item, style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          dropdownColor: boxColor,
        ),
      ],
    );
  }

  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: orangeColor,
        ),
      ],
    );
  }
}

void showAddHabitDialog(BuildContext context, HabitController habitController,
    DateTime? selectedDay) {
  showDialog(
    context: context,
    builder: (context) => AddHabitDialog(
      selectedDay: selectedDay,
    ),
  );
}
