import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class PeriodDateSelector extends StatefulWidget {
  const PeriodDateSelector({super.key, required this.onSelect});

  final Function(DateTime a) onSelect;
  @override
  _PeriodDateSelectorState createState() => _PeriodDateSelectorState();
}

class _PeriodDateSelectorState extends State<PeriodDateSelector> {
  late DateTime _currentDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now(); // Starts with the current date
    _selectedDate = _currentDate;
  }

  // Format the date as "dd/MM/yyyy"
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Move to the previous month
  void _moveToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  // Move to the next month
  void _moveToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  // Create the calendar grid
  Widget _buildCalendar() {
    // Get the first day of the current month
    DateTime firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    // Get the number of days in the current month
    int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;

    // Find the starting weekday of the month (1 = Monday, 7 = Sunday)
    int startingWeekday = firstDayOfMonth.weekday; // Sunday is 7, Monday is 1

    // Calculate the number of empty days before the first day of the month
    int emptyDays = (startingWeekday % 7);

    // Build the grid of calendar days
    List<Widget> dayWidgets = [];
    for (int i = 0; i < emptyDays; i++) {
      dayWidgets.add(Container()); // Empty space
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(_currentDate.year, _currentDate.month, day);
      bool isFutureDate = currentDay.isAfter(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: isFutureDate
              ? null // Disables tap on future dates
              : () {
            widget.onSelect.call(currentDay);
            // Only allow selection of past or today dates
            setState(() {
              _selectedDate = currentDay;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: _selectedDate.day == day && _selectedDate.month == _currentDate.month
                  ? Colors.red // Change selected date to red
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _selectedDate.day == day && _selectedDate.month == _currentDate.month
                    ? Colors.white
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isFutureDate
                      ? Colors.grey // Grayed-out color for future dates
                      : (_selectedDate.day == day && _selectedDate.month == _currentDate.month
                      ? Colors.white
                      : Colors.black),
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller font size
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GridView.count(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // Disables grid scrolling
        children: dayWidgets,
      ),
    );
  }

  // Get the list of day names (e.g., Sunday, Monday, etc.)
  List<String> getWeekdayNames() {
    return List.generate(7, (index) {
      DateTime day = DateTime(2023, 1, 1).add(Duration(days: index)); // Start from Sunday
      return DateFormat('E').format(day); // 'E' gives abbreviated weekday names like Sun, Mon, etc.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left_rounded,color: Colors.grey,size: 30,),
                  onPressed: _moveToPreviousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentDate),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(
                      color:
                      Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right_rounded,color: Colors.grey,size: 30,),
                  onPressed: _moveToNextMonth,
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getWeekdayNames().map((day) {
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                          color:
                         Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),

            child: _buildCalendar(),
          ),

        ],
      ),
    );
  }
}








class DateSelector extends StatefulWidget {
  const DateSelector({super.key, required this.onSelect});

  final Function(DateTime) onSelect;

  @override
  _DateSelectorState createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _currentDate;
  late DateTime _selectedDate;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now(); // Starts with the current date
    _selectedDate = _currentDate;
    _selectedYear = _currentDate.year;
  }

  // Format the date as "dd/MM/yyyy"
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Move to the previous month
  void _moveToPreviousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  // Move to the next month
  void _moveToNextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  // Create the calendar grid
  Widget _buildCalendar() {
    // Get the first day of the current month
    DateTime firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    // Get the number of days in the current month
    int daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;

    // Find the starting weekday of the month (1 = Monday, 7 = Sunday)
    int startingWeekday = firstDayOfMonth.weekday; // Sunday is 7, Monday is 1

    // Calculate the number of empty days before the first day of the month
    int emptyDays = (startingWeekday % 7);

    // Build the grid of calendar days
    List<Widget> dayWidgets = [];
    for (int i = 0; i < emptyDays; i++) {
      dayWidgets.add(Container()); // Empty space
    }

    for (int day = 1; day <= daysInMonth; day++) {
      DateTime currentDay = DateTime(_currentDate.year, _currentDate.month, day);
      bool isFutureDate = currentDay.isAfter(DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: isFutureDate
              ? null // Disables tap on future dates
              : () {
            widget.onSelect.call(currentDay);
            // Only allow selection of past or today dates
            setState(() {
              _selectedDate = currentDay;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: _selectedDate.day == day && _selectedDate.month == _currentDate.month
                  ? Colors.red // Change selected date to red
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _selectedDate.day == day && _selectedDate.month == _currentDate.month
                    ? Colors.white
                    : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isFutureDate
                      ? Colors.grey // Grayed-out color for future dates
                      : (_selectedDate.day == day && _selectedDate.month == _currentDate.month
                      ? Colors.white
                      : Colors.black),
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Smaller font size
                ),
              ),
            ),
          ),
        ),
      );
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: GridView.count(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Disables grid scrolling
        children: dayWidgets,
      ),
    );
  }

  // Get the list of day names (e.g., Sunday, Monday, etc.)
  List<String> getWeekdayNames() {
    return List.generate(7, (index) {
      DateTime day = DateTime(2023, 1, 1).add(Duration(days: index)); // Start from Sunday
      return DateFormat('E').format(day); // 'E' gives abbreviated weekday names like Sun, Mon, etc.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left_rounded, color: Colors.grey, size: 30),
                  onPressed: _moveToPreviousMonth,
                ),
                GestureDetector(
                  onTap: () async {
                    final selectedYear = await showDialog<int>(
                      context: context,
                      builder: (context) {
                        return YearPickerDialog(
                          initialYear: _selectedYear,
                          onYearSelected: (year) {
                            Navigator.pop(context, year);
                          },
                        );
                      },
                    );
                    if (selectedYear != null) {
                      setState(() {
                        _selectedYear = selectedYear;
                        _currentDate = DateTime(_selectedYear, _currentDate.month, 1);
                      });
                    }
                  },
                  child: Text(
                    DateFormat('MMMM yyyy').format(_currentDate),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right_rounded, color: Colors.grey, size: 30),
                  onPressed: _moveToNextMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: getWeekdayNames().map((day) {
                return Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: _buildCalendar(),
          ),
        ],
      ),
    );
  }
}

class YearPickerDialog extends StatelessWidget {
  final int initialYear;
  final Function(int) onYearSelected;

  const YearPickerDialog({super.key, required this.initialYear, required this.onYearSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Year'),
      content: SizedBox(
        width: 200,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          initialDate: DateTime(initialYear),
          selectedDate: DateTime(initialYear),
          onChanged: (date) {
            onYearSelected(date.year);
          },
        ),
      ),
    );
  }
}


