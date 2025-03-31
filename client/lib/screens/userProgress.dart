import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProgressScreen extends StatefulWidget {
  const UserProgressScreen({Key? key}) : super(key: key);

  @override
  _UserProgressScreenState createState() => _UserProgressScreenState();
}

class _UserProgressScreenState extends State<UserProgressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  int _completedMedications = 0;
  int _completedTasks = 0;

  @override
  void initState() {
    super.initState();
    _loadCompletedItems();
  }

  Future<void> _loadCompletedItems() async {
    setState(() => _isLoading = true);
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Count completed medications
      final medQuery = _firestore.collection('medications')
          .where('status', isEqualTo: 'completed')
          .where('assignedTo', isEqualTo: userId);
      final medSnapshot = await medQuery.get();
      _completedMedications = medSnapshot.docs.length;

      // Count completed tasks
      final taskQuery = _firestore.collection('tasks')
          .where('status', isEqualTo: 'completed')
          .where('assignedTo', isEqualTo: userId);
      final taskSnapshot = await taskQuery.get();
      _completedTasks = taskSnapshot.docs.length;

      // Calculate points (10 points per medication, 5 per task)
      final totalPoints = (_completedMedications * 10) + (_completedTasks * 5);

      // Update user progress in Firestore
      await _firestore.collection('userProgress').doc(userId).set({
        'points': FieldValue.increment(totalPoints),
        'lastUpdated': FieldValue.serverTimestamp(),
        'completedMedications': _completedMedications,
        'completedTasks': _completedTasks,
      }, SetOptions(merge: true));

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading progress: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'My Progress',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF009F9F)),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 26,color: Color(0xFF009F9F),),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : userId == null
          ? const Center(child: Text('Please sign in to view progress'))
          : StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('userProgress').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final progressData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final points = progressData['points'] ?? 0;
          final badges = List<String>.from(progressData['badges'] ?? []);
          final streaks = progressData['streaks'] as Map<String, dynamic>? ?? {};
          final completedMeds = progressData['completedMedications'] ?? 0;
          final completedTasks = progressData['completedTasks'] ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPointsCard(points),
                const SizedBox(height: 28),

                // Completion counters
                _buildCompletionSection(completedMeds, completedTasks),
                const SizedBox(height: 28),

                // Streaks section
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Current Streaks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildStreaksSection(streaks),
                const SizedBox(height: 28),

                // Badges section
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Earned Badges',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildBadgesGrid(badges),

                // Tips section
                const SizedBox(height: 32),
                _buildProgressTips(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsCard(int points) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF009F9F), Color(0xFF009F9F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Points',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            points.toString(),
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (points % 1000) / 1000,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 12),
          Text(
            '${1000 - (points % 1000)} points to next level',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionSection(int meds, int tasks) {
    return Row(
      children: [
        Expanded(
          child: _buildCompletionCard(
            title: 'Medications Taken',
            count: meds,
            icon: Icons.medical_services_outlined,
            color: const Color(0xFF3F8585),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildCompletionCard(
            title: 'Tasks Completed',
            count: tasks,
            icon: Icons.task_outlined,
            color: const Color(0xFF5E7CE2),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksSection(Map<String, dynamic> streaks) {
    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            title: 'Medication',
            count: streaks['medication'] ?? 0,
            icon: Icons.medical_services_outlined,
            color: const Color(0xFF3F8585),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStreakCard(
            title: 'Tasks',
            count: streaks['tasks'] ?? 0,
            icon: Icons.task_outlined,
            color: const Color(0xFF5E7CE2),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count days',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(List<String> badges) {
    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 50,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No badges yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete activities to earn badges',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 0.9,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: badges.map((badge) => _buildBadgeItem(badge)).toList(),
    );
  }

  Widget _buildBadgeItem(String badge) {
    final Map<String, Map<String, dynamic>> badgeTypes = {
      'medication_streak_7': {
        'title': '7-Day Streak',
        'icon': Icons.medical_services,
        'gradient': [const Color(0xFF3F8585), const Color(0xFF4CA1A3)],
      },
      'task_master': {
        'title': 'Task Master',
        'icon': Icons.task,
        'gradient': [const Color(0xFF5E7CE2), const Color(0xFF738AE6)],
      },
    };

    final badgeData = badgeTypes[badge] ?? {
      'title': badge.replaceAll('_', ' ').capitalize(),
      'icon': Icons.star,
      'gradient': [const Color(0xFFFFA726), const Color(0xFFFFCA28)],
    };

    final icon = badgeData['icon'] as IconData;
    final gradient = badgeData['gradient'] as List<Color>;
    final title = badgeData['title'] as String;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to Earn Points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipItem('Complete daily medication', 10, Icons.medical_services),
          _buildTipItem('Finish tasks on time', 5, Icons.task),
          _buildTipItem('Maintain 7-day streak', 50, Icons.local_fire_department),
          _buildTipItem('Earn new badges', 25, Icons.emoji_events),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, int points, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF3F8585).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF3F8585),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF3F8585).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$points',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3F8585),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}