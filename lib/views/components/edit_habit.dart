import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/constants.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/category.dart';
import 'package:habitter_itu/models/habit.dart';
import 'package:habitter_itu/controllers/category_controller.dart';
import 'package:habitter_itu/views/components/add_category.dart';
import 'package:habitter_itu/models/schedule.dart';

class EditHabitDialog extends StatefulWidget {
  final Habit habit;

  EditHabitDialog({required this.habit});

  @override
  _EditHabitDialogState createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  String habitName = '';
  String scheduleType = 'periodic';
  int frequency = 1;
  String frequencyUnit = 'weeks';
  String frequencyUnitPeriodic = 'week';
  List<int> selectedDays = [];
  bool hasReminder = false; // Default reminder state
  TimeOfDay? reminderTime; // Default reminder time
  String description = ''; // Description
  Category? selectedCategory; // Selected category for the habit

  final CategoryController _categoryController = CategoryController();
  final HabitController _habitController = HabitController();
  List<Category> categories = [];
  List<String> scheduleTypes = ['periodic', 'interval', 'static'];
  List<String> frequencyUnitsPeriodic = ['week', 'month'];
  List<String> frequencyUnits = ['days', 'weeks', 'months'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _habitController.init();
    _initializeFormFields();
  }

  Future<void> _loadCategories() async {
    await _categoryController.init();
    setState(() {
      categories = _categoryController.getCategories();
    });
  }

  void _initializeFormFields() {
    final habit = widget.habit;
    habitName = habit.title;
    scheduleType = habit.schedule.type.toString().split('.').last;
    frequency = habit.schedule.frequency;
    frequencyUnit = habit.schedule.frequencyUnit.toString().split('.').last;
    frequencyUnitPeriodic =
        habit.schedule.frequencyUnit == FrequencyUnit.weeks ? 'week' : 'month';
    selectedDays = habit.schedule.staticDays;
    hasReminder = habit.reminder;
    reminderTime = TimeOfDay.fromDateTime(habit.reminderTime);
    description = habit.description;
    selectedCategory = habit.category;

    // Ensure scheduleType and frequencyUnit are valid
    if (!scheduleTypes.contains(scheduleType)) {
      scheduleType = scheduleTypes.first;
    }
    if (!frequencyUnits.contains(frequencyUnit)) {
      frequencyUnit = frequencyUnits.first;
    }
    if (!frequencyUnitsPeriodic.contains(frequencyUnitPeriodic)) {
      frequencyUnitPeriodic = frequencyUnitsPeriodic.first;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScheduleType type;
      if (scheduleType == 'periodic') {
        type = ScheduleType.periodic;
        frequencyUnit = frequencyUnitPeriodic;
      } else if (scheduleType == 'interval') {
        type = ScheduleType.interval;
      } else {
        type = ScheduleType.statical;
      }

      FrequencyUnit freqUnit;
      if (frequencyUnit == 'weeks' || frequencyUnit == 'week') {
        freqUnit = FrequencyUnit.weeks;
      } else if (frequencyUnit == 'months' || frequencyUnit == 'month') {
        freqUnit = FrequencyUnit.months;
      } else {
        freqUnit = FrequencyUnit.days;
      }

      // Ensure selectedCategory are not null
      if (selectedCategory == null) {
        // Show an error message or handle the error appropriately
        return;
      }

      // Create the schedule and assign all attributes before validation
      final newSchedule = Schedule(
        type: type,
        frequency: frequency,
        frequencyUnit: freqUnit,
        staticDays: selectedDays,
      );

      final updatedHabit = Habit(
        title: habitName,
        schedule: newSchedule,
        category: selectedCategory!,
        description: description,
        reminder: hasReminder,
        reminderTime: reminderTime != null
            ? DateTime(0, 0, 0, reminderTime!.hour, reminderTime!.minute)
            : DateTime.now(),
      );

      // Update existing habit
      _habitController.updateHabit(widget.habit.key as int, updatedHabit);

      // Close the dialog
      Navigator.of(context).pop(true);
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
                    'Edit Habit',
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
            const Divider(color: Colors.grey, thickness: 1),
            const Padding(
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
                  initialValue: habitName, // Set initial value
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
                if (scheduleType == 'periodic')
                  // Frequency input
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: "",
                          initialValue:
                              frequency.toString(), // Set initial value
                          onSaved: (value) =>
                              frequency = int.tryParse(value!) ?? 1,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'times per ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: _buildDropdown(
                          label: '',
                          value: frequencyUnitPeriodic,
                          items: frequencyUnitsPeriodic,
                          onChanged: (newValue) => setState(() {
                            frequencyUnitPeriodic = newValue!;
                          }),
                        ),
                      ),
                    ],
                  ),

                if (scheduleType == 'interval')
                  // Frequency input
                  Row(
                    children: [
                      const SizedBox(width: 8.0),
                      const Text(
                        'Every ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: _buildTextField(
                          label: "",
                          initialValue:
                              frequency.toString(), // Set initial value
                          onSaved: (value) =>
                              frequency = int.tryParse(value!) ?? 1,
                        ),
                      ),
                      Expanded(
                        child: _buildDropdown(
                          label: '',
                          value: frequencyUnit,
                          items: frequencyUnits,
                          onChanged: (newValue) => setState(() {
                            frequencyUnit = newValue!;
                          }),
                        ),
                      ),
                    ],
                  ),

                if (scheduleType == 'static')
                  Row(
                    children: [
                      const SizedBox(width: 8.0),
                      const Text(
                        'Every ',
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(child: _buildDayButtons())
                    ],
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
                  initialValue: description, // Set initial value
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

  Widget _buildDayButtons() {
    final daysOfWeek = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };

    return Container(
      padding: EdgeInsets.all(4.0),
      height: 100,
      child: Row(
        children: daysOfWeek.keys.map((day) {
          return Expanded(
            child: Container(
              height: 100,
              padding: EdgeInsets.only(left: 4.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    int dayValue = daysOfWeek[day]!;
                    if (selectedDays.contains(dayValue)) {
                      selectedDays.remove(dayValue);
                    } else {
                      selectedDays.add(dayValue);
                    }
                    print(
                        'Selected days: $selectedDays'); // Print selected days to console
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedDays.contains(daysOfWeek[day])
                      ? orangeColor
                      : boxColor, // Highlight selected button
                  foregroundColor: Colors.white, // Text color
                  shape: CircleBorder(),
                  minimumSize:
                      Size(40, 40), // Button size (adjust if necessary)
                  padding: EdgeInsets.zero, // Remove internal padding
                ),
                child: Text(
                  day,
                  style: TextStyle(fontSize: 12), // Adjust font size as needed
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
    String? initialValue, // Add initialValue parameter
  }) {
    return TextFormField(
      onSaved: onSaved,
      validator: validator,
      maxLines: maxLines,
      initialValue: initialValue, // Set initial value
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.white),
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
          value: items.contains(value)
              ? value
              : items.first, // Ensure value is in items
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
