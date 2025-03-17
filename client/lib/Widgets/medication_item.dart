import 'package:flutter/material.dart';

class MedicationItem extends StatelessWidget {
  final String title;
  final String details;
  final bool isCompleted;
  final VoidCallback onToggle;

  const MedicationItem({
    super.key, 
    required this.title, 
    required this.details, 
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Image.asset('assets/pill.png', height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(details, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? const Color(0xFF37B5B6) : Colors.grey, width: 2),
                color: isCompleted ? const Color(0xFFE0F7FA) : Colors.transparent,
              ),
              child: isCompleted 
                ? const Icon(Icons.check, color: Color(0xFF37B5B6), size: 16) 
                : const SizedBox(width: 16, height: 16),
            ),
          ),
        ],
      ),
    );
  }
}