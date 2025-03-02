import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'ChatScreen.dart';
import '../Widgets/dashboard_header.dart';
import '../Widgets/search_bar.dart';
import '../Widgets/services_section.dart';
import '../Widgets/plan_section.dart';
import '../Widgets/reminders_section.dart';
import '../Widgets/bottom_nav_bar.dart';



class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentIndex = 0; // You can change the value based on your logic

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
            const SearchBarWidget(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ServicesSection(),
                      const SizedBox(height: 24),
                      const PlanSection(),
                      const SizedBox(height: 24),
                      const RemindersSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        onHomePressed: () {
          print("Home Pressed");
        },
        onCalendarPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        onRecordPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );
        },
        onChatPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
        currentIndex: currentIndex, // Pass currentIndex
      ),
    );
  }
}
