import 'package:client/Widgets/bottom_bar.dart';
import 'package:client/Widgets/profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:client/globals.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleFamilyManagement(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Family Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create New Family'),
              onTap: () => _createFamily(context, user.uid),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Join Existing Family'),
              onTap: () => _joinFamilyDialog(context, user.uid),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFamily(BuildContext context, String userId) async {
    final familyNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Family'),
        content: TextField(
          controller: familyNameController,
          decoration: const InputDecoration(labelText: 'Family Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (familyNameController.text.isEmpty) return;

              try {
                final docRef = await FirebaseFirestore.instance
                    .collection('families')
                    .add({
                  'familyName': familyNameController.text,
                  'members': [userId],
                  'patients': [],
                  'createdAt': Timestamp.now(),
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'families': FieldValue.arrayUnion([docRef.id]),
                });

                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Family created successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating family: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinFamilyDialog(BuildContext context, String userId) async {
    final familyIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Family'),
        content: TextField(
          controller: familyIdController,
          decoration: const InputDecoration(labelText: 'Family ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (familyIdController.text.isEmpty) return;

              try {
                final familyDoc = await FirebaseFirestore.instance
                    .collection('families')
                    .doc(familyIdController.text)
                    .get();

                if (!familyDoc.exists) {
                  throw Exception('Family not found');
                }

                await FirebaseFirestore.instance
                    .collection('families')
                    .doc(familyIdController.text)
                    .update({
                  'members': FieldValue.arrayUnion([userId]),
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'families': FieldValue.arrayUnion([familyIdController.text]),
                });

                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Joined family successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error joining family: $e')),
                );
              }
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    // Using StreamBuilder to listen for real-time updates from Firestore.
    return Scaffold(
      backgroundColor: primaryBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // While waiting for data, show a loading indicator.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          // Assuming your Firestore document has fields: name, joinDate, phone
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userName = userData['name'] ?? 'No Name';
          final joinDate = userData['joinDate'] ?? 'Unknown Date';
          final phone = userData['phone'] ?? 'No Phone';

          return ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              Row(
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
                  const Spacer(),
                  const Image(image: AssetImage("assets/logos/logo_name.png")),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 0.0),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(image: AssetImage("assets/icon.png")),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  joinDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF342B33),
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF342B33),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 50),
                        SvgPicture.asset("assets/fluent_pen-20-filled.svg"),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 0.0),
              const ProfileCard(
                iconPath: "assets/fluent_book-exclamation-mark-20-filled.svg",
                title: 'Health History',
                description: "Check your All Medical History",
              ),
              const SizedBox(height: 0.0),
              const ProfileCard(
                iconPath: "assets/mdi_account-child.svg",
                title: "Karekezi's History",
                description: "Receive and save up. Points to receive gifts",
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: primaryGreen,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            "Profile Settings",
                            style: TextStyle(
                              color: Color(0xFF091F44),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lock_open_sharp,
                            color: primaryGreen,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            "Reset Password",
                            style: TextStyle(
                              color: Color(0xFF091F44),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.door_front_door,
                            color: primaryGreen,
                          ),
                          SizedBox(width: 12.0),
                          Text(
                            "Log Out",
                            style: TextStyle(
                              color: Color(0xFF091F44),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
