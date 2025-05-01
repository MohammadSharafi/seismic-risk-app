import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final RegExp nameRegExp = RegExp('[a-zA-Z]');
int countDaysBetweenInString(
    {required String startDate, required String endDate}) {
  if (startDate.isEmpty || endDate.isEmpty) return 0;
  return countDaysBetween(
    endDate: DateTime.parse(endDate),
    startDate: DateTime.parse(startDate),
  );
}

String convertSecondsToTime(String seconds) {
  if (seconds == '0' || seconds == '') {
    return "";
  }

  int value = int.parse(seconds);
  // Calculate days, hours, minutes, and seconds
  int days = value ~/ 86400;
  value %= 86400;
  int hours = value ~/ 3600;
  value %= 3600;
  int minutes = value ~/ 60;
  value %= 60;

  // Create the formatted time string
  String timeString =
      "${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${value.toString().padLeft(2, '0')}";

// Check if the string starts with "00:" and remove it if true
  if (timeString.startsWith("00:")) {
    timeString = timeString.substring(3); // Removes the first "00:"
  }

  return timeString;
}

bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

String formatTimeAgo(DateTime targetTime) {
  final now = DateTime.now();
  final difference = now.difference(targetTime);

  if (difference.inHours > 0) {
    if (difference.inHours == 1) {
      return '1 hour ago';
    } else {
      return '${difference.inHours} hours ago';
    }
  } else if (difference.inMinutes > 0) {
    if (difference.inMinutes == 1) {
      return '1 minute ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  } else {
    return 'just now';
  }
}

bool isSameDate(DateTime date1, DateTime date2) {
  if (date2 == date1) {
    return true;
  }
  return date1.month == date2.month &&
      date1.year == date2.year &&
      date1.day == date2.day;
}

/// Checks if the given date is equal to the current date.
bool isCurrentDate(DateTime date) {
  final DateTime now = DateTime.now();
  return date.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
}

String formatDate(DateTime date) {
  initializeDateFormatting();
  return DateFormat("d , MMMM , y", 'en_US').format(date);
}

String formatDateChat(DateTime date) {
  initializeDateFormatting();
  return DateFormat("yyyy.MM.dd", 'en_US').format(date);
}

String formatDateRing(DateTime date) {
  initializeDateFormatting();
  return DateFormat("MMMM d, y", 'en_US').format(date);
}

String uiFormatDate(DateTime date) {
  initializeDateFormatting();
  return DateFormat.MMMd('en_US').format(date);
}

String yearFormatDate(DateTime date) {
  initializeDateFormatting();
  return DateFormat.y('en_US').format(date);
}

String apiFormatDate(DateTime date) {
  initializeDateFormatting();
  return DateFormat("yyyy-MM-dd", 'en_US').format(date);
}

/// Checks if the given date is a highlighted date.
bool isHighlightedDate(DateTime date, List<DateTime> highlightedDates) {
  return highlightedDates.any((DateTime highlightedDate) =>
      date.isAtSameMomentAs(DateTime(
          highlightedDate.year, highlightedDate.month, highlightedDate.day)));
}

/// Gets the number of days for the given month,
/// by taking the next month on day 0 and getting the number of days.
int getDaysInMonth(int year, int month) {
  return month < DateTime.monthsPerYear
      ? DateTime(year, month + 1, 0).day
      : DateTime(year + 1, 1, 0).day;
}

/// Gets the name of the given month by its number,
/// using either the supplied or default name.
String getMonthName(int month, {required List<String> monthNames}) {
  final List<String> names = monthNames;
  return names[month - 1];
}

int countDaysBetween({required DateTime startDate, required DateTime endDate}) {
  return endDate.difference(startDate).inDays + 1;
}

String shortenMonth(String month) {
  final monthMap = {
    'January': 'Jan',
    'February': 'Feb',
    'March': 'Mar',
    'April': 'Apr',
    'May': 'May',
    'June': 'Jun',
    'July': 'Jul',
    'August': 'Aug',
    'September': 'Sep',
    'October': 'Oct',
    'November': 'Nov',
    'December': 'Dec',
  };

  return monthMap[month] ?? month;
}

String monthAndDayName(DateTime date) {
  List<String> month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  return month.elementAt(date.month - 1) + ' ${date.day}';
}

String indexToMonthNames(int index) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return monthNames.elementAt(index - 1);
}

String getDayOfWeek(DateTime date) {
  List<String> daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];
  return daysOfWeek[date.weekday - 1];
}

DateTime StringToDateTime({required String date}) {
  try {
    String divider = date[4];
    List<String> splitDates = date.substring(0, 10).split(divider);
    DateTime sDate = DateTime(int.parse(splitDates.first),
        int.parse(splitDates[1]), int.parse(splitDates[2]));
    return sDate;
  } catch (e) {
    return DateTime.now();
  }
}

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

List<String> weekdays = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

class NotificationWeekAndTime {

  NotificationWeekAndTime({
    required this.dayOfTheWeek,
    required this.timeOfDay,
  });
  final int dayOfTheWeek;
  final TimeOfDay timeOfDay;
}

Future<NotificationWeekAndTime?> pickSchedule(
  BuildContext context,
) async {
  TimeOfDay? timeOfDay;
  DateTime now = DateTime.now();
  int? selectedDay;

  await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'I want to be reminded every:',
            textAlign: TextAlign.center,
          ),
          content: Wrap(
            alignment: WrapAlignment.center,
            spacing: 3,
            children: [
              for (int index = 0; index < weekdays.length; index++)
                ElevatedButton(
                  onPressed: () {
                    selectedDay = index + 1;
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.teal,
                    ),
                  ),
                  child: Text(weekdays[index]),
                ),
            ],
          ),
        );
      });

  if (selectedDay != null) {
    timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          now.add(
            const Duration(minutes: 1),
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              colorScheme: const ColorScheme.light(
                primary: Colors.teal,
              ),
            ),
            child: child!,
          );
        });

    if (timeOfDay != null) {
      return NotificationWeekAndTime(
          dayOfTheWeek: selectedDay!, timeOfDay: timeOfDay);
    }
  }
  return null;
}

bool isDate(String date) {
  try {
    if (date.length == 10) {
      if (date.split('/').length == 3) {
        return true;
      }
      return false;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
