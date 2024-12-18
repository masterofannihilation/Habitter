// function to put example data into the Hive database

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'controllers/category_controller.dart';
import 'models/category.dart';
import 'models/habit.dart';
import 'models/schedule.dart';
import 'models/journal.dart';
import 'controllers/journal_controller.dart';

Future<void> putExampleData() async {
  CategoryController categoryController = CategoryController();
  await categoryController.init();

  // set example data
  if (Hive.box<Category>('categoriesBox').isEmpty) {
    await categoryController.addCategory(Category(name: 'Work', emoji: '💼'));
    await categoryController.addCategory(Category(name: 'Health', emoji: '💪'));
    await categoryController
        .addCategory(Category(name: 'Hobbies', emoji: '🎨'));
    await categoryController.addCategory(Category(name: 'Social', emoji: '👫'));
  }

  if (Hive.box<Habit>('habits').isEmpty) {
    Category? workCategory = categoryController.getCategoryByName('Work');
    Category? healthCategory = categoryController.getCategoryByName('Health');
    Category? hobbiesCategory = categoryController.getCategoryByName('Hobbies');
    Category? socialCategory = categoryController.getCategoryByName('Social');

    if (workCategory != null) {
      Hive.box<Habit>('habits').add(Habit(
        title: 'Work on project',
        description: 'Work on the project for 2 hours',
        category: workCategory,
        schedule: Schedule(
            type: ScheduleType.interval,
            frequency: 2,
            frequencyUnit: FrequencyUnit.days),
        startDate: DateTime.now(),
      ));
    }

    if (healthCategory != null) {
      Hive.box<Habit>('habits').add(Habit(
        title: 'Exercise',
        description: 'Exercise for 30 minutes',
        category: healthCategory,
        schedule: Schedule(
            type: ScheduleType.interval,
            frequency: 1,
            frequencyUnit: FrequencyUnit.days),
        startDate: DateTime.now(),
      ));
    }

    if (hobbiesCategory != null) {
      Hive.box<Habit>('habits').add(Habit(
        title: 'Painting',
        description: 'Paint for 1 hour',
        category: hobbiesCategory,
        schedule: Schedule(
            type: ScheduleType.periodic,
            frequency: 3,
            frequencyUnit: FrequencyUnit.weeks),
        startDate: DateTime.now(),
      ));
    }

    if (socialCategory != null) {
      Hive.box<Habit>('habits').add(Habit(
        title: 'Call mom',
        description: 'Call mom every sunday',
        category: socialCategory,
        schedule: Schedule(
            type: ScheduleType.statical,
            frequency: 1,
            frequencyUnit: FrequencyUnit.days,
            staticDays: [DateTime.sunday]),
        startDate: DateTime.now(),
      ));
    }

    categoryController.closeBox();
  }
  if (Hive.box<JournalEntry>('journalBox').isEmpty) {
    final entry = JournalEntry()
      ..id = Uuid().v4()
      ..title = 'Example entry'
      ..content = 'This is the first entry in the journal'
      ..date = DateTime.now();
    JournalController journalController = JournalController();
    await journalController.init();
    await journalController.addJournalEntry(entry);
  }
}
