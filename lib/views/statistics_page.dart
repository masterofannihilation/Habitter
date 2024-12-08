import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:habitter_itu/controllers/habit_controller.dart';
import 'package:habitter_itu/models/habit.dart';
import 'package:habitter_itu/constants.dart';
import 'components/appbar.dart';
import 'components/bottom_bar.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final HabitController _habitController = HabitController();
  List<Habit> habits = [];
  double totalHabitCompletionRate = 0;
  double totalGoalCompletionRate = 0;
  Map<String, double> categoryDistribution = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _habitController.init();
    List<Habit> loadedHabits = await _habitController.getHabits();
    setState(() {
      habits = loadedHabits;
      _calculateStats();
    });
  }

  void _calculateStats() {
    double totalCompletionRate = 0;
    double totalGoalRate = 0;
    Map<String, double> categoryCount = {};

    for (Habit habit in habits) {
      totalCompletionRate +=
          habit.completionStatus.values.where((status) => status).length;
      totalGoalRate += habit.completionStatus.length;

      String categoryName = habit.category.name;
      categoryCount[categoryName] = (categoryCount[categoryName] ?? 0) + 1;
    }

    totalHabitCompletionRate =
        habits.isEmpty ? 0 : (totalCompletionRate / totalGoalRate) * 100;
    totalGoalCompletionRate =
        habits.isEmpty ? 0 : (totalCompletionRate / habits.length) * 100;

    categoryDistribution = categoryCount.map((key, value) {
      return MapEntry(key, (value / habits.length) * 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/pie-chart.svg',
                    color: Colors.white,
                  ),
                  Text(
                    " Statistics",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Total Habit Completion Rate: ${totalHabitCompletionRate.toStringAsFixed(2)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Total Goal Completion Rate: ${totalGoalCompletionRate.toStringAsFixed(2)}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Past Habit Completion Rate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: habits.map((habit) {
                      double completionCount = habit.completionStatus.values
                          .where((status) => status)
                          .length
                          .toDouble();
                      double totalCount =
                          habit.completionStatus.length.toDouble();
                      double barHeight = totalCount == 0
                          ? 0
                          : (completionCount / totalCount) * 100;
                      double barWidth = maxWidth / habits.length - 8;
                      return Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: barHeight.isNaN ? 0 : barHeight,
                              width: barWidth,
                              color: Colors.orange,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              habit.category.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Category Distribution',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView(
                children: categoryDistribution.entries.map((entry) {
                  return ListTile(
                    title: Text(
                      entry.key,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    trailing: Text(
                      '${entry.value.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomBar(selectedIndex: 3),
    );
  }
}
