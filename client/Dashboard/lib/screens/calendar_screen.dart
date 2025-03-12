import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:lesly_project/main.dart';
// import 'package:lesly_project/screens/ChatScreen.dart';
// import 'package:lesly_project/screens/record_screen.dart';
import 'package:lesly_project/Widgets/bottom_nav_bar.dart';
import 'package:lesly_project/Widgets/calendar_grid.dart';
import 'package:lesly_project/Widgets/medication_item.dart';
import 'package:lesly_project/providers/calendar_providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDate = ref.watch(focusedDateProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCalendar(context, ref, focusedDate),
                    _buildLegend(focusedDate),
                    _buildMedicationList(ref, focusedDate),
                  ],
                ),
              ),
            ),
            BottomNavBar(
              onHomePressed: () {
                // Implement action for home button
                print('Home Pressed');
              },
              onCalendarPressed: () {
                // Implement action for calendar button
                print('Calendar Pressed');
              },
              onRecordPressed: () {
                // Implement action for record button
                print('Record Pressed');
              },
              onChatPressed: () {
                // Implement action for chat button
                print('Chat Pressed');
              },
              onAddPressed: () {
                // Implement action for add button
                print('FAB Pressed');
              },
              currentIndex: 1, // Current screen index for calendar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Calendar', style: TextStyle(color: Color(0xFF37B5B6), fontSize: 24, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildCalendar(BuildContext context, WidgetRef ref, DateTime focusedDate) {
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
          _buildDateSelector(context, ref, focusedDate),
          const SizedBox(height: 20),
          CalendarGrid(focusedDate: focusedDate),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, WidgetRef ref, DateTime focusedDate) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context, ref),
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

  Future<void> _selectDate(BuildContext context, WidgetRef ref) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: ref.read(focusedDateProvider),
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
      ref.read(focusedDateProvider.notifier).state = picked;
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

  Widget _buildMedicationList(WidgetRef ref, DateTime focusedDate) {
    final medStatuses = ref.watch(medicationStatusProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMMM').format(focusedDate), 
               style: const TextStyle(color: Color(0xFF37B5B6), fontSize: 20, fontWeight: FontWeight.w600)),
          const Text('You have to take 2 medicines', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),
          MedicationItem(
            title: 'Aspirin 500 mg | 1 piece', 
            details: '6:00 AM | ${DateFormat('E, dd').format(focusedDate)} | Before food', 
            isCompleted: medStatuses['morning'] ?? false,
            onToggle: () => ref.read(medicationStatusProvider.notifier).toggleStatus('morning'),
          ),
          const SizedBox(height: 12),
          MedicationItem(
            title: 'Aspirin 500 mg | 1 pair', 
            details: '10:00 PM | ${DateFormat('E, dd').format(focusedDate)} | Before food', 
            isCompleted: medStatuses['night'] ?? false,
            onToggle: () => ref.read(medicationStatusProvider.notifier).toggleStatus('night'),
          ),
        ],
      ),
    );
  }
}
