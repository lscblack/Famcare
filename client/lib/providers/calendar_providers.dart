import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

// Medication Schedule Model
class MedicationSchedule {
  final DateTime date;
  final String title;
  final String time;

  MedicationSchedule({
    required this.date,
    required this.title,
    required this.time,
  });
}

// BLoC Events
abstract class MedicationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleMedicationStatus extends MedicationEvent {
  final String id;
  ToggleMedicationStatus(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleSelectedDate extends MedicationEvent {
  final DateTime date;
  ToggleSelectedDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeFocusedDate extends MedicationEvent {
  final DateTime newDate;
  ChangeFocusedDate(this.newDate);

  @override
  List<Object?> get props => [newDate];
}

// BLoC State
class MedicationState extends Equatable {
  final Map<String, bool> medicationStatuses;
  final List<DateTime> selectedDates;
  final DateTime focusedDate;

  const MedicationState({
    required this.medicationStatuses,
    required this.selectedDates,
    required this.focusedDate,
  });

  factory MedicationState.initial() {
    return MedicationState(
      medicationStatuses: {'morning': true, 'night': false},
      selectedDates: [DateTime.now()],
      focusedDate: DateTime.now(),
    );
  }

  MedicationState copyWith({
    Map<String, bool>? medicationStatuses,
    List<DateTime>? selectedDates,
    DateTime? focusedDate,
  }) {
    return MedicationState(
      medicationStatuses: medicationStatuses ?? this.medicationStatuses,
      selectedDates: selectedDates ?? this.selectedDates,
      focusedDate: focusedDate ?? this.focusedDate,
    );
  }

  @override
  List<Object?> get props => [medicationStatuses, selectedDates, focusedDate];
}

// BLoC
class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  MedicationBloc() : super(MedicationState.initial()) {
    on<ToggleMedicationStatus>(_onToggleMedicationStatus);
    on<ToggleSelectedDate>(_onToggleSelectedDate);
    on<ChangeFocusedDate>(_onChangeFocusedDate);
  }

  void _onToggleMedicationStatus(ToggleMedicationStatus event, Emitter<MedicationState> emit) {
    final updatedStatuses = Map<String, bool>.from(state.medicationStatuses);
    updatedStatuses[event.id] = !(updatedStatuses[event.id] ?? false);
    emit(state.copyWith(medicationStatuses: updatedStatuses));
  }

  void _onToggleSelectedDate(ToggleSelectedDate event, Emitter<MedicationState> emit) {
    final normalizedDate = DateTime(event.date.year, event.date.month, event.date.day);
    final updatedDates = List<DateTime>.from(state.selectedDates);

    if (updatedDates.any((d) => _isSameDay(d, normalizedDate))) {
      updatedDates.removeWhere((d) => _isSameDay(d, normalizedDate));
    } else {
      updatedDates.add(normalizedDate);
    }

    emit(state.copyWith(selectedDates: updatedDates));
  }

  void _onChangeFocusedDate(ChangeFocusedDate event, Emitter<MedicationState> emit) {
    emit(state.copyWith(focusedDate: event.newDate));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Medication Schedules (Static Data)
final medicationSchedules = [
  MedicationSchedule(
    date: DateTime(DateTime.now().year, DateTime.now().month, 3),
    title: 'Aspirin 500 mg',
    time: '6:00 AM',
  ),
  MedicationSchedule(
    date: DateTime(DateTime.now().year, DateTime.now().month, 3),
    title: 'Aspirin 500 mg',
    time: '10:00 PM',
  ),
  MedicationSchedule(
    date: DateTime(DateTime.now().year, DateTime.now().month, 9),
    title: 'Aspirin 500 mg',
    time: '6:00 AM',
  ),
];