// main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'views/components/appbar.dart';
import 'package:habitter_itu/constants.dart';
import 'views/components/bottom_bar.dart';
import 'views/components/add_button.dart';
import 'views/components/add_habit.dart';
import 'models/category.dart';
import 'models/habit.dart';
import 'models/schedule.dart';
import 'controllers/habit_controller.dart';
import 'models/profile.dart';
import 'models/journal.dart';
import 'views/components/app_drawer.dart';
import 'views/components/calendar.dart';
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
  await Hive.openBox<JournalEntry>('journalBox');

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

