import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:client/providers/calendar_providers.dart';

class CalendarGrid extends ConsumerWidget {
  final DateTime focusedDate;
  
  const CalendarGrid({
    Key? key,
    required this.focusedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final firstDayOfMonth = currentMonth.weekday % 7;
    final daysInMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;
    final medications = ref.watch(medicationSchedulesProvider);
    final selectedDates = ref.watch(selectedDatesProvider);
    
    return Column(
      children: [
        _buildMonthHeader(context, ref),
        const SizedBox(height: 16),
        _buildWeekdayLabels(),
        const SizedBox(height: 8),
        ...List.generate((firstDayOfMonth + daysInMonth + 6) ~/ 7, (weekIndex) => 
          _buildWeekRow(
            context, 
            ref,
            weekIndex, 
            firstDayOfMonth, 
            daysInMonth, 
            currentMonth,
            selectedDates,
            medications
          )
        ),
      ],
    );
  }

  Widget _buildMonthHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(focusedDate), 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final newDate = DateTime(focusedDate.year, focusedDate.month - 1, 1);
                ref.read(focusedDateProvider.notifier).state = newDate;
              },
              color: Colors.grey,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final newDate = DateTime(focusedDate.year, focusedDate.month + 1, 1);
                ref.read(focusedDateProvider.notifier).state = newDate;
              },
              color: Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
        SizedBox(
          width: 40, 
          child: Text(
            day, 
            textAlign: TextAlign.center, 
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
          )
        )
      ).toList(),
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    WidgetRef ref,
    int weekIndex, 
    int firstDayOfMonth, 
    int daysInMonth, 
    DateTime currentMonth,
    List<DateTime> selectedDates,
    List<MedicationSchedule> medications
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (dayIndex) {
          final day = weekIndex * 7 + dayIndex - firstDayOfMonth + 1;
          final isCurrentMonth = day > 0 && day <= daysInMonth;
          
          if (!isCurrentMonth) return const SizedBox(width: 40, height: 40);
          
          final date = DateTime(currentMonth.year, currentMonth.month, day);
          final isSelected = selectedDates.any((d) => SelectedDatesNotifier.isSameDay(d, date));
          
          final hasMedication = medications.any((med) => 
            med.date.day == day && 
            med.date.month == currentMonth.month && 
            med.date.year == currentMonth.year);
          
          final isHighlighted = day == 3 && date.weekday == 2; // Tuesday the 3rd
          
          return CalendarDay(
            date: date,
            isSelected: isSelected,
            isHighlighted: isHighlighted,
            hasMedication: hasMedication,
          );
        }),
      ),
    );
  }
}

class CalendarDay extends ConsumerWidget {
  final DateTime date;
  final bool isSelected;
  final bool isHighlighted;
  final bool hasMedication;

  const CalendarDay({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.isHighlighted,
    required this.hasMedication,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () {
          ref.read(focusedDateProvider.notifier).state = date;
        },
        onDoubleTap: () {
          _showDateOptions(context, ref);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isSelected 
                    ? const Color(0xFF37B5B6) 
                    : isHighlighted 
                        ? const Color(0xFFE0F7FA) 
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : isHighlighted 
                            ? const Color(0xFF37B5B6) 
                            : Colors.black,
                    fontWeight: isSelected || isHighlighted 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
            if (hasMedication && !isSelected)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF37B5B6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDateOptions(BuildContext context, WidgetRef ref) {
    final selectedDatesNotifier = ref.read(selectedDatesProvider.notifier);
    final isCurrentlySelected = selectedDatesNotifier.isSelected(date);
    
    if (!isCurrentlySelected) {
      selectedDatesNotifier.toggleDate(date);
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Date: ${DateFormat('MMM d, yyyy').format(date)}'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              selectedDatesNotifier.toggleDate(date);
              Navigator.of(context).pop();
            },
            child: const Text('Remove Highlight'),
          ),
        ],
      ),
    );
  }
}