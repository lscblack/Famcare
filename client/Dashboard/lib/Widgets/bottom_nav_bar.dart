import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/record_screen.dart';
import '../screens/ChatScreen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key, required Null Function() onChatPressed, required Null Function() onAddPressed, required int currentIndex, required Null Function() onHomePressed, required Null Function() onCalendarPressed, required Null Function() onRecordPressed});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  // List of pages to navigate
  final List<Widget> _pages = [
    DashboardScreen(),
    CalendarScreen(),
    RecordScreen(),
    ChatScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to the selected page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

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
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.calendar_month, 1),
              const SizedBox(width: 60), // Space for the floating button
              _buildNavItem(Icons.medical_services, 2),
              _buildNavItem(Icons.chat_outlined, 3),
            ],
          ),
        ),
        Positioned(
          top: -28,
          child: FloatingActionButton(
            onPressed: () {
              // Add button action here
              print("Add button pressed");
            },
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

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        color: _selectedIndex == index ? const Color(0xFF3F8585) : const Color(0xFF3F8585),
        size: 28,
      ),
    );
  }
}
