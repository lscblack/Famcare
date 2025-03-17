import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/Widgets/calendar_grid.dart';
import 'package:client/Widgets/medication_item.dart';
import '../providers/calendar_providers.dart'; // Assuming this file contains MedicationBloc

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedicationBloc(), // Use MedicationBloc instead of CalendarBloc
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<MedicationBloc, MedicationState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          _buildCalendar(context, state.focusedDate),
                          _buildLegend(state.focusedDate),
                          _buildMedicationList(context, state),
                        ],
                      );
                    },
                  ),
                ),
              ),
              BottomNavBar(
                onHomePressed: () {
                  print('Home Pressed');
                },
                onCalendarPressed: () {
                  print('Calendar Pressed');
                },
                onRecordPressed: () {
                  print('Record Pressed');
                },
                onChatPressed: () {
                  print('Chat Pressed');
                },
                onAddPressed: () {
                  print('FAB Pressed');
                },
                currentIndex: 1, // Current screen index for calendar
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Calendar',
        style: TextStyle(
          color: Color(0xFF37B5B6),
          fontSize: 24,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, DateTime focusedDate) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildDateSelector(context, focusedDate),
          const SizedBox(height: 20),
          CalendarGrid(focusedDate: focusedDate),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, DateTime focusedDate) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context), // Pass context here
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20, color: Color(0xFF37B5B6)),
                  const SizedBox(width: 10),
                  Text(DateFormat('MMMM d, yyyy').format(focusedDate), style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<MedicationBloc>().state.focusedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF37B5B6), onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      context.read<MedicationBloc>().add(ChangeFocusedDate(picked));
    }
  }

  Widget _buildLegend(DateTime focusedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFF37B5B6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Medication scheduled (Aspirin 500 mg - 6:00 AM) ${DateFormat('MMM d').format(focusedDate)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList(BuildContext context, MedicationState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMMM').format(state.focusedDate),
              style: const TextStyle(color: Color(0xFF37B5B6), fontSize: 20, fontWeight: FontWeight.w600)),
          const Text('You have to take 2 medicines', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          MedicationItem(
            title: 'Aspirin 500 mg | 1 piece',
            details: '6:00 AM | ${DateFormat('E, dd').format(state.focusedDate)} | Before food',
            isCompleted: state.medicationStatuses['morning'] ?? false,
            onToggle: () => context.read<MedicationBloc>().add(ToggleMedicationStatus('morning')),
          ),
          const SizedBox(height: 12),
          MedicationItem(
            title: 'Aspirin 500 mg | 1 pair',
            details: '10:00 PM | ${DateFormat('E, dd').format(state.focusedDate)} | Before food',
            isCompleted: state.medicationStatuses['night'] ?? false,
            onToggle: () => context.read<MedicationBloc>().add(ToggleMedicationStatus('night')),
          ),
        ],
      ),
    );
  }
}