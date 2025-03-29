import 'package:client/screens/LoginScreen.dart';
import 'package:client/screens/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/state_provider.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? userEmail;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.userEmail,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Remove user from app state
      await context.read<AppCubit>().removeUser();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logout failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Placeholder
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF48B1A5).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: const Color(0xFF48B1A5),
                  size: 35,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hello !!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF48B1A5),
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (userEmail != null)
                    Text(
                      userEmail!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Logout Button
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF48B1A5),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48B1A5).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}