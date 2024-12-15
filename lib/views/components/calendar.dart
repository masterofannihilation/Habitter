import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habitter_itu/constants.dart';

class Calendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  Calendar({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Add padding around the container
      child: Container(
        decoration: BoxDecoration(
          color: habitColor, // Background color of the container
          borderRadius: BorderRadius.circular(16.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: TableCalendar(
          focusedDay: focusedDay,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          calendarFormat: calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(selectedDay, day);
          },
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          onPageChanged: onPageChanged,
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
            titleTextStyle: TextStyle(
              color: Colors.white, // Set the month and year text color to white
              fontSize: 16.0,
            ),
            formatButtonTextStyle: TextStyle(
              color: Colors.white, // Set the format button text color to white
            ),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: Colors.white), // Set the format button border color to white
              borderRadius: BorderRadius.circular(12.0),
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Colors.white, // Set the left chevron icon color to white
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Colors.white, // Set the right chevron icon color to white
            ),
          ),
        ),
      ),
    );
  }
}