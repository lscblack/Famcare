import 'package:client/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MedicationManagementScreen extends StatefulWidget {
  const MedicationManagementScreen({super.key});

  @override
  State<MedicationManagementScreen> createState() => _MedicationManagementScreenState();
}

class _MedicationManagementScreenState extends State<MedicationManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user info
  String? _currentUserId;
  String? _userRole;
  bool _isLoading = true;

  // Filter options
  var _showPending = true;
  bool _showCompleted = true;
  String? _caregiverEmail;
  String? _familyMemberEmail;
  List<String> _caregiverIds = [];
  List<String> _familyMemberIds = [];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        _currentUserId = user.uid;

        DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUserId).get();
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          _userRole = userData['role'] as String?;

          // If user is patient, get their caregivers and family members
          if (_userRole == 'patient') {
            await _fetchCaregiversAndFamily();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting user info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCaregiversAndFamily() async {
    try {
      // Fetch caregivers
      if (_caregiverEmail != null && _caregiverEmail!.isNotEmpty) {
        QuerySnapshot caregiverQuery = await _firestore.collection('users')
            .where('email', isEqualTo: _caregiverEmail)
            .where('role', isEqualTo: 'caregiver')
            .get();

        _caregiverIds = caregiverQuery.docs.map((doc) => doc.id).toList();
      }

      // Fetch family members
      if (_familyMemberEmail != null && _familyMemberEmail!.isNotEmpty) {
        QuerySnapshot familyQuery = await _firestore.collection('users')
            .where('email', isEqualTo: _familyMemberEmail)
            .where('role', isEqualTo: 'family')
            .get();

        _familyMemberIds = familyQuery.docs.map((doc) => doc.id).toList();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching caregivers/family: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Query<Map<String, dynamic>> _getMedicationsQuery() {
    Query<Map<String, dynamic>> query = _firestore.collection('medications');

    // Filter based on user role
    // if (_userRole != 'patient') {
    //   query = query.where('patientId', isEqualTo: _currentUserId);
    // } else if (_userRole == 'caregiver') {
    //   query = query.where('assignedCaregiver', isEqualTo: _currentUserId);
    // } else if (_userRole == 'family') {
    //   query = query.where('familyId', isEqualTo: _currentUserId);
    // }
    query = query.where('patientId', isEqualTo: _currentUserId);
    // Apply status filters
    List<String> statusFilters = [];
    if (_showPending) statusFilters.add('pending');
    if (_showCompleted) statusFilters.add('completed');

    if (statusFilters.isNotEmpty) {
      if (statusFilters.length == 1) {
        query = query.where('status', isEqualTo: statusFilters[0]);
      } else {
        query = query.where('status', whereIn: statusFilters);
      }
    } else {
      // If no filters selected, return empty query
      query = query.where('status', isEqualTo: '__nonexistent__');
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Medications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF48B1A5),
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF48B1A5)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF48B1A5)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF48B1A5)))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Manage your medications and stay on schedule',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMedicationsQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF48B1A5)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showPending || _showCompleted
                              ? 'No medications found'
                              : 'No filters selected',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showPending || _showCompleted
                              ? 'Add a new medication to get started'
                              : 'Please select at least one filter',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                    DateTime startDate = (data['startDate'] as Timestamp).toDate();
                    DateTime endDate = (data['endDate'] as Timestamp).toDate();
                    List<dynamic> times = data['times'] as List<dynamic>;
                    bool isCompleted = data['status'] == 'completed';

                    return _buildMedicationCard(doc.id, data, startDate, endDate, times, isCompleted);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicationForm(context, null, null),
        backgroundColor: const Color(0xFF48B1A5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicationCard(
      String docId,
      Map<String, dynamic> data,
      DateTime startDate,
      DateTime endDate,
      List<dynamic> times,
      bool isCompleted,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white70,
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showMedicationDetails(docId, data),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF48B1A5),
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.grey[300]
                            : const Color(0x1A48B1A5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isCompleted
                              ? Colors.grey[700]
                              : const Color(0xFF48B1A5),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Dosage: ${data['dosage'] ?? ''}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: times.map((time) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0x1A48B1A5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              time.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF48B1A5),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                if (data['notes'] != null && data['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['notes'].toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue[700]),
                      onPressed: () => _showMedicationForm(context, docId, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(docId, data['name']),
                    ),
                    if (!isCompleted)
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Color(0xFF48B1A5)),
                        onPressed: () => _markAsCompleted(docId),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final caregiverController = TextEditingController(text: _caregiverEmail);
    final familyController = TextEditingController(text: _familyMemberEmail);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Filter Medications',
                style: TextStyle(
                  color: Color(0xFF48B1A5),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text('Pending', style: TextStyle(fontFamily: 'Poppins')),
                      value: _showPending,
                      activeColor: const Color(0xFF48B1A5),
                      onChanged: (value) {
                        setState(() {
                          _showPending = value! ;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Completed', style: TextStyle(fontFamily: 'Poppins')),
                      value: _showCompleted,
                      activeColor: const Color(0xFF48B1A5),
                      onChanged: (value) {
                        setState(() {
                          _showCompleted = value! ;
                        });
                      },
                    ),
                    if (_userRole == 'patient') ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Caregiver',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: caregiverController,
                        decoration: InputDecoration(
                          hintText: 'Enter caregiver email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          _caregiverEmail = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Family Member',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: familyController,
                        decoration: InputDecoration(
                          hintText: 'Enter family member email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          _familyMemberEmail = value;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_showPending && !_showCompleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one status filter'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_userRole == 'patient') {
                      // await _fetchCaregiversAndFamily();
                    }


                    if (mounted) {
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48B1A5),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMedicationDetails(String docId, Map<String, dynamic> data) {
    DateTime startDate = (data['startDate'] as Timestamp).toDate();
    DateTime endDate = (data['endDate'] as Timestamp).toDate();
    bool isCompleted = data['status'] == 'completed';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0x1A48B1A5),
                            radius: 30,
                            child: const Icon(
                              Icons.medication,
                              color: Color(0xFF48B1A5),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF48B1A5),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Text(
                                  'Dosage: ${data['dosage'] ?? ''}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _detailSection(
                        'Medication Details',
                        [
                          _detailRow('Frequency', data['frequency'] ?? ''),
                          _detailRow('Start Date', DateFormat('MMMM dd, yyyy').format(startDate)),
                          _detailRow('End Date', DateFormat('MMMM dd, yyyy').format(endDate)),
                          _detailRow('Status', isCompleted ? 'Completed' : 'Pending'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _detailSection(
                        'Reminder Times',
                        (data['times'] as List<dynamic>).map((time) {
                          return _detailRow('Time', time.toString());
                        }).toList(),
                      ),
                      if (data['notes'] != null && data['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _detailSection(
                          'Notes',
                          [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                data['notes'].toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton(
                            'Edit',
                            Icons.edit,
                            Colors.blue[700]!,
                                () {
                              Navigator.pop(context);
                              _showMedicationForm(context, docId, data);
                            },
                          ),
                          _actionButton(
                            'Delete',
                            Icons.delete,
                            Colors.red,
                                () {
                              Navigator.pop(context);
                              _confirmDelete(docId, data['name']);
                            },
                          ),
                          if (!isCompleted)
                            _actionButton(
                              'Complete',
                              Icons.check_circle,
                              const Color(0xFF48B1A5),
                                  () {
                                Navigator.pop(context);
                                _markAsCompleted(docId);
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF48B1A5),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 25,
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String docId, String? medicationName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              color: Colors.red,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${medicationName ?? 'this medication'}? This action cannot be undone.',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  await _firestore.collection('medications').doc(docId).delete();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully deleted ${medicationName ?? 'medication'}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting medication: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAsCompleted(String docId) async {
    try {
      await _firestore.collection('medications').doc(docId).update({
        'status': 'completed',
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMedicationForm(BuildContext context, String? docId, Map<String, dynamic>? existingData) {
    final formKey = GlobalKey<FormState>();

    // Form controllers
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final notesController = TextEditingController();

    // Default values
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    List<String> times = ['08:00'];
    String status = 'pending';

    // If editing, populate with existing data
    if (existingData != null) {
      nameController.text = existingData['name']?.toString() ?? '';
      dosageController.text = existingData['dosage']?.toString() ?? '';
      frequencyController.text = existingData['frequency']?.toString() ?? '';
      notesController.text = existingData['notes']?.toString() ?? '';

      startDate = (existingData['startDate'] as Timestamp).toDate();
      endDate = (existingData['endDate'] as Timestamp).toDate();
      times = List<String>.from(existingData['times']?.map((t) => t.toString()) ?? ['08:00']);
      status = existingData['status']?.toString() ?? 'pending';
    }

    // Temporary list for managing times
    List<String> tempTimes = List.from(times);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                docId == null ? 'Add Medication' : 'Edit Medication',
                style: const TextStyle(
                  color: Color(0xFF48B1A5),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxHeight: 500),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Medication Name',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF48B1A5),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter medication name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: dosageController,
                          decoration: InputDecoration(
                            labelText: 'Dosage (e.g., 500mg)',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF48B1A5),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: frequencyController,
                          decoration: InputDecoration(
                            labelText: 'Frequency (e.g., daily, twice daily)',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF48B1A5),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter frequency';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF48B1A5),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                startDate = pickedDate;
                                if (endDate.isBefore(startDate)) {
                                  endDate = startDate.add(const Duration(days: 30));
                                }
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(startDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Icon(Icons.calendar_today, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'End Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate,
                              firstDate: startDate,
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF48B1A5),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              setState(() {
                                endDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM dd, yyyy').format(endDate),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Icon(Icons.calendar_today, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Reminder Times',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            for (int i = 0; i < tempTimes.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () async {
                                          final timeParts = tempTimes[i].split(':');
                                          final pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                              hour: int.parse(timeParts[0]),
                                              minute: int.parse(timeParts[1]),
                                            ),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  colorScheme: const ColorScheme.light(
                                                    primary: Color(0xFF48B1A5),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedTime != null) {
                                            setState(() {
                                              String hour = pickedTime.hour.toString().padLeft(2, '0');
                                              String minute = pickedTime.minute.toString().padLeft(2, '0');
                                              tempTimes[i] = '$hour:$minute';
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[400]!),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                tempTimes[i],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[800],
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                              Icon(Icons.access_time, color: Colors.grey[600]),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (tempTimes.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            tempTimes.removeAt(i);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  tempTimes.add('08:00');
                                });
                              },
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Add Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF48B1A5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF48B1A5),
                                width: 2,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text(
                                'Pending',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text(
                                'Completed',
                                style: TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                          ],
                          onChanged: (newValue)  {
                            setState(() {
                              status = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            labelStyle: TextStyle(
                              color: Colors.grey[700],
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFF48B1A5),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        final medicationData = {
                          'patientId': _currentUserId,
                          'name': nameController.text,
                          'dosage': dosageController.text,
                          'frequency': frequencyController.text,
                          'times': tempTimes,
                          'startDate': Timestamp.fromDate(startDate),
                          'endDate': Timestamp.fromDate(endDate),
                          'notes': notesController.text,
                          'status': status,
                          'lastUpdated': FieldValue.serverTimestamp(),
                        };

                        // Add caregiver and family if they exist
                        if (_caregiverIds.isNotEmpty) {
                          medicationData['assignedCaregiver'] = _caregiverIds.first;
                        }
                        if (_familyMemberIds.isNotEmpty) {
                          medicationData['familyId'] = _familyMemberIds.first;
                        }

                        if (docId == null) {
                          await _firestore.collection('medications').add(medicationData);
                        } else {
                          await _firestore.collection('medications').doc(docId).update(medicationData);
                        }

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                docId == null
                                    ? 'Medication added successfully'
                                    : 'Medication updated successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48B1A5),
                  ),
                  child: Text(
                    docId == null ? 'Add' : 'Update',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}