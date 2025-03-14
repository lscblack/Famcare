import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for medication status
final medicationStatusProvider = StateNotifierProvider<MedicationStatusNotifier, Map<String, bool>>((ref) {
  return MedicationStatusNotifier();
});

class MedicationStatusNotifier extends StateNotifier<Map<String, bool>> {
  MedicationStatusNotifier() : super({'morning': true, 'night': false});

  void toggleStatus(String id) {
    state = {...state, id: !(state[id] ?? false)};
  }
}

// Provider for selected date(s)
final selectedDatesProvider = StateNotifierProvider<SelectedDatesNotifier, List<DateTime>>((ref) {
  return SelectedDatesNotifier();
});

class SelectedDatesNotifier extends StateNotifier<List<DateTime>> {
  SelectedDatesNotifier() : super([DateTime.now()]);

  void toggleDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (state.any((d) => isSameDay(d, normalizedDate))) {
      state = state.where((d) => !isSameDay(d, normalizedDate)).toList();
    } else {
      state = [...state, normalizedDate];
    }
  }

  bool isSelected(DateTime date) {
    return state.any((d) => isSameDay(d, date));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Provider for focused date (current month view)
final focusedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Model and provider for medication schedules
class MedicationSchedule {
  final DateTime date;
  final String title;
  final String time;
  
  MedicationSchedule({required this.date, required this.title, required this.time});
}

final medicationSchedulesProvider = Provider<List<MedicationSchedule>>((ref) {
  final now = DateTime.now();
  return [
    MedicationSchedule(date: DateTime(now.year, now.month, 3), title: 'Aspirin 500 mg', time: '6:00 AM'),
    MedicationSchedule(date: DateTime(now.year, now.month, 3), title: 'Aspirin 500 mg', time: '10:00 PM'),
    MedicationSchedule(date: DateTime(now.year, now.month, 9), title: 'Aspirin 500 mg', time: '6:00 AM'),
  ];
});