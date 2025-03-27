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
      backgroundColor: const Color(0xFFF1F5FF),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            if (state is AppLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentUser = state is AppAuthenticated ? state.user : null;

            return SingleChildScrollView(
              child: Column(
                children: [
                  DashboardHeader(
                    userName: currentUser?.name ?? 'Guest',
                    userEmail: currentUser?.email,
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
            );
          },
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
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
      ),
    );
  }
}