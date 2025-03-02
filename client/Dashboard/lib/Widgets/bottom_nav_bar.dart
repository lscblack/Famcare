import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onCalendarPressed;
  final VoidCallback onRecordPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onAddPressed;

  const BottomNavBar({
    super.key,
    required this.onHomePressed,
    required this.onCalendarPressed,
    required this.onRecordPressed,
    required this.onChatPressed,
    required this.onAddPressed, required int currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, onHomePressed),
              _buildNavItem(Icons.calendar_month, onCalendarPressed),
              const SizedBox(width: 60),
              _buildNavItem(Icons.medical_services, onRecordPressed),
              _buildNavItem(Icons.chat_outlined, onChatPressed),
            ],
          ),
        ),
        Positioned(
          top: -28,
          child: FloatingActionButton(
            onPressed: onAddPressed,
            backgroundColor: const Color(0xFF3F8585),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, size: 40, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: const Color(0xFF3F8585), size: 28),
    );
  }
}