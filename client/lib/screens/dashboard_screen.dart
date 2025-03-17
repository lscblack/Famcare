import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'ChatScreen.dart';
import '../Widgets/dashboard_header.dart';
import '../Widgets/search_bar.dart';
import '../Widgets/services_section.dart';
import '../Widgets/plan_section.dart';
import '../Widgets/reminders_section.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../providers/state_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0; // You can change the value based on your logic

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap the entire Column in SingleChildScrollView
          child: Column(
            children: [
              // Dashboard Header with User Info
              BlocBuilder<AppBloc, AppState>(
                builder: (context, state) {
                  // Access the user info from the AppBloc state
                  final userInfo = state.users.isNotEmpty ? state.users.first : null;
                  return DashboardHeader(userName: userInfo?.name ?? 'Guest'); // Pass userName
                },
              ),
              const SearchBarWidget(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ServicesSection(),
                    SizedBox(height: 24),
                    PlanSection(),
                    SizedBox(height: 24),
                    RemindersSection(),
                  ],
                ),
              ),
            ],
          ),
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