import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../screens/calendar_screen.dart';
import '../screens/emergency_screen.dart';  // Add this import
import '../screens/chat_list_screen.dart';
import '../screens/MedicalRecords.dart';
class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildServiceItem(
              FontAwesomeIcons.tablets,
              const Color(0xFF003F5F),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicationManagementScreen()),
                );
              },
            ),
            _buildServiceItem(
              FontAwesomeIcons.calendarCheck,
              Colors.teal,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CalendarScreen()),
                );
              },
            ),
            _buildServiceItem(
              FontAwesomeIcons.userFriends,
              const Color(0xFF277DA1),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>   ChatListScreen()),
                );
              },
            ),
            _buildServiceItem(
              FontAwesomeIcons.ambulance,
              const Color.fromARGB(255, 235, 71, 76),
              () {
                // Navigate to the emergency screen when ambulance icon is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EmergencyScreen()),
                );
              },
            ),
          ],
        )
      ],
    );
  }
  
  Widget _buildServiceItem(IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}