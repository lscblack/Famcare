import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'chat_list_screen.dart';
import '../Widgets/dashboard_header.dart';
import '../Widgets/search_bar.dart';
import '../Widgets/services_section.dart';
import '../Widgets/plan_section.dart';
import '../Widgets/reminders_section.dart';
import '../Widgets/bottom_nav_bar.dart';
import '../providers/state_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          // Wrap the entire Column in SingleChildScrollView
          child: Column(
            children: [
              // Dashboard Header with User Info and Profile Navigation Button
              BlocBuilder<AppCubit, AppState>(
                builder: (context, state) {
                  // Access the user info from the AppCubit state
                  final userInfo =
                      state is AppAuthenticated ? state.user : null;

                  return  DashboardHeader(userName: userInfo?.name ?? 'Guest');

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
        currentIndex: _currentIndex,
        onHomePressed: () {
          setState(() {
            _currentIndex = 0;
          });
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
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
      ),
    );
  }
}
