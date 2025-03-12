import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'calendar_strip.dart';
import 'medication_reminder.dart';

class RemindersSection extends StatelessWidget {
  const RemindersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const CalendarStrip(),
        const SizedBox(height: 16),
        const MedicationReminder(),
      ],
    );
  }
}