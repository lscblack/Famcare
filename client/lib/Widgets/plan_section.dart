import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PlanSection extends StatefulWidget {
  const PlanSection({super.key});

  @override
  State<PlanSection> createState() => _PlanSectionState();
}

class _PlanSectionState extends State<PlanSection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;
  List<Map<String, dynamic>> _pendingMeds = [];
  int _completedCount = 0;
  int _totalCount = 0;
  bool _isLoading = true;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      await _fetchMedications();
    }
  }

  Future<void> _fetchMedications() async {
    try {
      if (_currentUserId == null) return;

      // Get pending medications
      final pendingQuery = await _firestore.collection('medications')
          .where('patientId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Get completed medications count
      final completedQuery = await _firestore.collection('medications')
          .where('patientId', isEqualTo: _currentUserId)
          .where('status', isEqualTo: 'completed')
          .get();

      final pendingMeds = pendingQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'dosage': data['dosage'] ?? '',
          'startDate': (data['startDate'] as Timestamp).toDate(),
          'endDate': (data['endDate'] as Timestamp).toDate(),
          'times': data['times'] ?? [],
        };
      }).toList();

      if (mounted) {
        setState(() {
          _pendingMeds = pendingMeds;
          _completedCount = completedQuery.size;
          _totalCount = _pendingMeds.length + _completedCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsCompleted(String docId) async {
    try {
      await _firestore.collection('medications').doc(docId).update({
        'status': 'completed',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      await _fetchMedications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as completed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your plan today',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.teal.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Text(
                  '$_completedCount of $_totalCount completed',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleLarge!.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _pendingMeds.isEmpty
                    ? const Center(
                  child: Text(
                    'No pending medications found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : PageView.builder(
                  controller: _pageController,
                  itemCount: _pendingMeds.length,
                  itemBuilder: (context, index) {
                    final med = _pendingMeds[index];
                    return _buildMedicationCard(med);
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -15,
          right: 0,
          child: Image.asset(
            'assets/pill.png',
            height: 90,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Image.asset('assets/aspirin.png', height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  med['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosage: ${med['dosage']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(med['startDate'])} - ${dateFormat.format(med['endDate'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.teal, size: 30),
            onPressed: () => _markAsCompleted(med['id']),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}