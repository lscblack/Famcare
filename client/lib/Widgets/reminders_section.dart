import 'package:flutter/material.dart';

import 'calendar_strip.dart';
import 'task_reminder.dart';

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
        const TaskReminder(),
      ],
    );
  }
}