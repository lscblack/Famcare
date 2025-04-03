import 'package:flutter/material.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({super.key});

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime todayDate = DateTime(today.year, today.month, today.day);
    final DateTime startOfWeek =
        todayDate.subtract(Duration(days: todayDate.weekday - 1));

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final DateTime currentDate = startOfWeek.add(Duration(days: index));
          final bool isSelected = _isSameDate(currentDate, todayDate);

          return Container(
            width: 50,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 26, 95, 88)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${currentDate.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.titleSmall!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][index],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.titleSmall!.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
