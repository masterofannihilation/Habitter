/**
 * @author Jakub Pogádl (xpogad00), Boris Semanco(xseman06), Boris Hatala (xhatal02)
 * @file main.dart
 */
import 'package:flutter/material.dart';
import 'package:habitter_itu/controllers/category_controller.dart';
import 'package:habitter_itu/example_data.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/category.dart';
import 'models/habit.dart';
import 'models/schedule.dart';
import 'models/profile.dart';
import 'models/journal.dart';
import 'views/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  Hive.registerAdapter(FrequencyUnitAdapter());
  Hive.registerAdapter(ScheduleTypeAdapter());
  Hive.registerAdapter(ProfileAdapter());
  Hive.registerAdapter(JournalEntryAdapter());

  // Open boxes
  await Hive.openBox<Profile>('profile');
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Category>('categoriesBox');
  await Hive.openBox<JournalEntry>('journalBox');
  CategoryController categoryController = CategoryController();
  await categoryController.init();

  // set example data if not already set
  putExampleData();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Habitter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}
