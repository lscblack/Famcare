import 'package:client/globals.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Color(0xFF1648CE),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 0.0),
          Text(
            "Change Password",
            style: TextStyle(fontSize: 24.0),
          ),
          const SizedBox(height: 0.0),
          Text("Your Password Must Be At Least 6 Characters"),
          const SizedBox(height: 0.0),
          TextField(
            decoration: InputDecoration(
              labelText: "Current Password",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              labelText: "Confirm Password",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text("Change Password"),
          ),
        ],
      ),
    );
  }
}
