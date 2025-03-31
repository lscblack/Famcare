import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'chat_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/state_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // Function to log emergency alert to Firestore
  Future<void> _logEmergencyAlert(BuildContext context, String userId, String userName) async {
    try {
      // Generate a unique ID for the alert
      final String alertId = const Uuid().v4();

      // Get reference to emergencyAlerts collection
      final alertsCollection = FirebaseFirestore.instance.collection('emergencyAlerts');

      // Create the document with the alert information
      await alertsCollection.doc(alertId).set({
        'alertID': alertId,
        'patientId': userId, // Current logged in user
        'triggeredBy': userId, // Same as patientId in this case
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
        'notes': 'Emergency alert triggered by $userName',
      });

      // Show confirmation to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert sent to medical staff'),
          backgroundColor: Color(0xFF499F97),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      // Handle any errors
      print('Error logging emergency alert: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send emergency alert: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Top section with all content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF2D6D66),
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),

                        // Dashboard Header with User Info
                        BlocBuilder<AppCubit, AppState>(
                          builder: (context, state) {
                            // Access the user info from the AppCubit state
                            final userInfo = state is AppAuthenticated ? state.user : null;

                            return Column(
                              children: [
                                if (userInfo != null) ...[
                                  // User name section
                                  const SizedBox(height: 10),
                                  Text(
                                    userInfo.name ?? 'User Name', // Fallback if name is null
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ] else ...[
                                  // Optionally, show something else if userInfo is null
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No user info available',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        const Text(
                          "Are you in Emergency?",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Emergency call instruction
                        const Text(
                          "Press button to call Ambulance and send alert",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Emergency Button
                        BlocBuilder<AppCubit, AppState>(
                          builder: (context, state) {
                            final userInfo = state is AppAuthenticated ? state.user : null;
                            final userId = userInfo?.id ?? 'unknown_user';
                            final userName = userInfo?.name ?? 'Unknown User';

                            return GestureDetector(
                              onTap: () async {
                                // Log emergency alert to Firestore
                                await _logEmergencyAlert(context, userId, userName);

                                // Then try to make the emergency call
                                const emergencyNumber = 'tel:112';
                                if (await canLaunch(emergencyNumber)) {
                                  await launch(emergencyNumber);
                                } else {
                                  print("Cannot make a call from this device.");
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Problem detected"),
                                        content: const Text(
                                            "Your device cannot make calls. Please use your mobile to dial 112. An emergency alert has been sent to medical staff."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              backgroundColor: const Color(0xFF499F97),
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 182, 18, 34),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF15D6D).withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    "112",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Ambulance Card
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.ambulance,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Ambulance",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Emergency Status Card - Shows recent alerts
                        BlocBuilder<AppCubit, AppState>(
                          builder: (context, state) {
                            final userInfo = state is AppAuthenticated ? state.user : null;
                            final userId = userInfo?.id;

                            if (userId != null) {
                              return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('emergencyAlerts')
                                    .where('patientId', isEqualTo: userId)
                                    .orderBy('timestamp', descending: true)
                                    .limit(1)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                                    final alertData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                                    final status = alertData['status'] ?? 'unknown';
                                    final timestamp = alertData['timestamp'] as Timestamp?;
                                    final formattedTime = timestamp != null
                                        ? '${timestamp.toDate().hour}:${timestamp.toDate().minute}'
                                        : 'Recently';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Recent Emergency Alert",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Status: $status",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: status == 'active' ? Colors.red : Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                "Time: $formattedTime",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return const SizedBox.shrink(); // No previous alerts
                                },
                              );
                            }

                            return const SizedBox.shrink(); // No user logged in
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Navigation with updated BottomNavBar
              BottomNavBar(
                currentIndex: 0,
                onHomePressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                  );
                },
                onCalendarPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => CalendarScreen()),
                  );
                },
                onRecordPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RecordScreen()),
                  );
                },
                onChatPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatListScreen()),
                  );
                },
                onAddPressed: () {
                  // Show emergency screen or other action
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Emergency Options"),
                        content: const Text("Choose an emergency service"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}