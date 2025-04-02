import 'package:client/Widgets/bottom_bar.dart';
import 'package:client/Widgets/profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:client/globals.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/dashboard_screen.dart';
class _FamilyListSection extends StatelessWidget {
  final List<dynamic> familyIds;

  const _FamilyListSection({required this.familyIds});

  @override
  Widget build(BuildContext context) {
    if (familyIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'Your Families',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF091F44),
            ),
          ),
        ),
        FutureBuilder<List<DocumentSnapshot>>(
          future: _getFamiliesData(familyIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No family information found'),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final family = snapshot.data![index];
                return _FamilyListItem(family: family);
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<DocumentSnapshot>> _getFamiliesData(
      List<dynamic> familyIds) async {
    final futures = familyIds
        .map((id) =>
            FirebaseFirestore.instance.collection('families').doc(id).get())
        .toList();
    return Future.wait(futures);
  }
}

// Add this widget class for individual family items
class _FamilyListItem extends StatelessWidget {
  final DocumentSnapshot family;

  const _FamilyListItem({required this.family});

  @override
  Widget build(BuildContext context) {
    final data = family.data() as Map<String, dynamic>;
    final familyName = data['familyName'] ?? 'Unnamed Family';
    final familyId = family.id;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: const Icon(Icons.family_restroom, color: primaryGreen),
        title: Text(familyName),
        subtitle: Text(
          'ID: $familyId',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: familyId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Family ID copied to clipboard!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleFamilyManagement(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Family Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              _buildDialogButton(
                context,
                icon: Icons.group_add,
                text: 'Create New Family',
                onPressed: () => _createFamily(context, user.uid),
              ),
              const SizedBox(height: 16),
              _buildDialogButton(
                context,
                icon: Icons.group,
                text: 'Join Existing Family',
                onPressed: () => _joinFamilyDialog(context, user.uid),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(BuildContext context,
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen.withOpacity(0.1),
        foregroundColor: primaryGreen,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Future<void> _createFamily(BuildContext context, String userId) async {
    final familyNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Family',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: familyNameController,
                decoration: InputDecoration(
                  labelText: 'Family Name',
                  hintText: 'Enter family name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.family_restroom, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (familyNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange[300],
                            content: const Text('Please enter a family name'),
                          ),
                        );
                        return;
                      }

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
                          SnackBar(
                            backgroundColor: primaryGreen,
                            content: const Text('Family created successfully!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[300],
                            content: Text('Error: ${e.toString()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Create',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinFamilyDialog(BuildContext context, String userId) async {
    final familyIdController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join Family',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: familyIdController,
                decoration: InputDecoration(
                  labelText: 'Family ID',
                  hintText: 'Enter family ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.group, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (familyIdController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange[300],
                            content: const Text('Please enter a family ID'),
                          ),
                        );
                        return;
                      }

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
                          'families':
                              FieldValue.arrayUnion([familyIdController.text]),
                        });

                        Navigator.pop(context);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryGreen,
                            content: const Text('Joined family successfully!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red[300],
                            content: Text('Error: ${e.toString()}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Join',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
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
      appBar: AppBar(
        automaticallyImplyLeading: true, // This shows the back button by default
        leading: Container(
          margin: const EdgeInsets.all(4.0), // Add some margin around the icon
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 40,
            ),
            onPressed: () {
              Navigator.pop(context); // This will navigate back
            },
          ),
        ),
        title: const Image(
          image: AssetImage("assets/logos/logo_name.png"),
          height: 40, // Adjust height as needed
        ),
        centerTitle: true,
        actions: const [
          // If you need any actions on the right side
          SizedBox(width: 48), // This balances the leading icon space
        ],
      ),
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
          final userName = userData['fullName'] ?? 'No Name';
          final joinDate =
              userData['createdAt']?.toDate().toString() ?? 'Unknown Date';
          final phone = userData['phone'] ?? 'No Phone';

          final families = userData['families'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
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
                        const Image(image: AssetImage("assets/logos/trans.png") ,width: 120,),
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
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: InkWell(
                  onTap: () => _handleFamilyManagement(context),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons
                                  .family_restroom, // Make sure you have this icon
                              color: primaryGreen,
                            ),
                            const SizedBox(width: 12.0),
                            const Text(
                              "Family Management",
                              style: TextStyle(
                                color: Color(0xFF091F44),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _handleFamilyManagement(context),
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _FamilyListSection(familyIds: families.cast<String>()),
              const SizedBox(height: 0.0),
              const ProfileCard(
                iconPath: "assets/fluent_book-exclamation-mark-20-filled.svg",
                title: 'Health History',
                description: "Check your All Medical History",
              ),
              const SizedBox(height: 0.0),
              ProfileCard(
                iconPath: "assets/mdi_account-child.svg",
                title: "${userName.split(' ')[0]}'s History",
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
      // bottomNavigationBar: const BottomBar(),
    );
  }
}
