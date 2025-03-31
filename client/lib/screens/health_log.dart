import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../providers/state_provider.dart';
import '../Widgets/bottom_nav_bar.dart';
import 'dashboard_screen.dart';
import 'calendar_screen.dart';
import 'record_screen.dart';
import 'chat_list_screen.dart';

class HealthLogTrackerScreen extends StatefulWidget {
  const HealthLogTrackerScreen({Key? key}) : super(key: key);

  @override
  State<HealthLogTrackerScreen> createState() => _HealthLogTrackerScreenState();
}

class _HealthLogTrackerScreenState extends State<HealthLogTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _notesController = TextEditingController();

  final Map<String, bool> _symptoms = {
    'Headache': false,
    'Fatigue': false,
    'Fever': false,
    'Cough': false,
    'Shortness of Breath': false,
    'Nausea': false,
    'Dizziness': false,
    'Joint Pain': false,
    'Chest Pain': false,
    'Other': false,
  };

  String? _editingLogId;
  bool _isLoading = false;
  DateTime? _selectedDate;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleFormVisibility() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _bloodPressureController.clear();
    _heartRateController.clear();
    _notesController.clear();

    setState(() {
      _editingLogId = null;
      for (var symptom in _symptoms.keys) {
        _symptoms[symptom] = false;
      }
    });
  }

  void _loadLogForEdit(DocumentSnapshot log) {
    final data = log.data() as Map<String, dynamic>;

    _editingLogId = log.id;

    for (var symptom in _symptoms.keys) {
      _symptoms[symptom] = false;
    }

    final logSymptoms = data['symptoms'] as List<dynamic>? ?? [];
    for (var symptom in logSymptoms) {
      if (_symptoms.containsKey(symptom)) {
        _symptoms[symptom] = true;
      }
    }

    final vitals = data['vitals'] as Map<String, dynamic>? ?? {};
    _bloodPressureController.text = vitals['bloodPressure']?.toString() ?? '';
    _heartRateController.text = vitals['heartRate']?.toString() ?? '';
    _notesController.text = data['notes']?.toString() ?? '';

    if (!_showForm) {
      setState(() {
        _showForm = true;
      });
    }
  }

  Future<void> _saveHealthLog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final state = context.read<AppCubit>().state;
      final user = state is AppAuthenticated ? state.user : null;

      if (user == null) {
        _showSnackBar('You must be logged in to save health logs');
        setState(() => _isLoading = false);
        return;
      }

      final selectedSymptoms = _symptoms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final vitals = {
        'bloodPressure': _bloodPressureController.text.trim(),
        'heartRate': int.tryParse(_heartRateController.text.trim()) ?? 0,
      };

      final logData = {
        'patientId': user.id,
        'symptoms': selectedSymptoms,
        'vitals': vitals,
        'notes': _notesController.text.trim(),
        'loggedBy': user.id,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final logsCollection = FirebaseFirestore.instance.collection('healthLogs');

      if (_editingLogId != null) {
        await logsCollection.doc(_editingLogId).update(logData);
        _showSnackBar('Health log updated successfully');
      } else {
        final logId = const Uuid().v4();
        await logsCollection.doc(logId).set({
          'logID': logId,
          ...logData,
        });
        _showSnackBar('Health log saved successfully');
      }

      _resetForm();
    } catch (e) {
      _showSnackBar('Error saving health log: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteHealthLog(String logId) async {
    try {
      await FirebaseFirestore.instance.collection('healthLogs').doc(logId).delete();
      _showSnackBar('Health log deleted successfully');
      _resetForm();
    } catch (e) {
      _showSnackBar('Error deleting health log: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D6D66),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2D6D66),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _clearDateFilter() {
    if (mounted) {
      setState(() => _selectedDate = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF2D6D66),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2D6D66),
                        size: 22,
                      ),
                    ),
                  ),
                  const Text(
                    "Health Tracker",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:  Color(0xFF2D6D66),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _toggleFormVisibility,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _showForm ? Icons.visibility_off : Icons.add,
                            color: const Color(0xFF2D6D66),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showForm)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2D6D66).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.health_and_safety,
                                              color: Color(0xFF2D6D66),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _editingLogId == null ? "Add New Health Log" : "Edit Health Log",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D6D66),
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: _toggleFormVisibility,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Symptoms",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF464646),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: _symptoms.keys.map((symptom) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _symptoms[symptom] = !_symptoms[symptom]!;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _symptoms[symptom]!
                                                  ? const Color(0xFF2D6D66)
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(
                                                color: _symptoms[symptom]!
                                                    ? const Color(0xFF2D6D66)
                                                    : Colors.grey.shade300,
                                              ),
                                              boxShadow: _symptoms[symptom]!
                                                  ? [
                                                BoxShadow(
                                                  color: const Color(0xFF2D6D66).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (_symptoms[symptom]!)
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 6),
                                                    child: Icon(
                                                      Icons.check_circle,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                Text(
                                                  symptom,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: _symptoms[symptom]!
                                                        ? Colors.white
                                                        : Colors.grey.shade800,
                                                    fontWeight: _symptoms[symptom]!
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Vitals",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF464646),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _bloodPressureController,
                                          decoration: InputDecoration(
                                            labelText: "Blood Pressure",
                                            hintText: "e.g., 120/80",
                                            prefixIcon: Icon(Icons.bloodtype,
                                                color: Color(0xFF2D6D66).withOpacity(0.7)),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: const Color(0xFF2D6D66),
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.5,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter blood pressure';
                                            }
                                            if (!RegExp(r'^\d{1,3}/\d{1,3}$').hasMatch(value)) {
                                              return 'Enter valid BP (e.g., 120/80)';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _heartRateController,
                                          decoration: InputDecoration(
                                            labelText: "Heart Rate",
                                            hintText: "e.g., 72",
                                            prefixIcon: Icon(Icons.favorite,
                                                color: Colors.redAccent.withOpacity(0.7)),
                                            filled: true,
                                            fillColor: Colors.grey.shade50,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: const Color(0xFF2D6D66),
                                                width: 1.5,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Colors.redAccent,
                                                width: 1.5,
                                              ),
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter heart rate';
                                            }
                                            if (int.tryParse(value) == null) {
                                              return 'Please enter a valid number';
                                            }
                                            final hr = int.parse(value);
                                            if (hr < 30 || hr > 250) {
                                              return 'Enter a realistic HR (30-250)';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Notes",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF464646),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _notesController,
                                    decoration: InputDecoration(
                                      hintText: "Any additional observations...",
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: const Color(0xFF2D6D66),
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                    maxLines: 4,
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: _isLoading ? null : _saveHealthLog,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      decoration: BoxDecoration(
                                        color: _isLoading ? Colors.grey : const Color(0xFF2D6D66),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF2D6D66).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                            : Text(
                                          _editingLogId == null ? "Save Log" : "Update Log",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Previous Logs",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D6D66),
                                ),
                              ),
                              Row(
                                children: [
                                  if (_selectedDate != null)
                                    GestureDetector(
                                      onTap: _clearDateFilter,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red.shade400,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _selectedDate != null
                                            ? const Color(0xFF2D6D66).withOpacity(0.1)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: _selectedDate != null
                                              ? const Color(0xFF2D6D66).withOpacity(0.3)
                                              : Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: _selectedDate != null
                                                ? const Color(0xFF2D6D66)
                                                : Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _selectedDate == null
                                                ? "Filter"
                                                : DateFormat('MMM d, y').format(_selectedDate!),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _selectedDate != null
                                                  ? const Color(0xFF2D6D66)
                                                  : Colors.grey.shade700,
                                              fontWeight: _selectedDate != null
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<AppCubit, AppState>(
                          builder: (context, state) {
                            final userInfo = state is AppAuthenticated ? state.user : null;

                            if (userInfo == null) {
                              return _buildEmptyState(
                                icon: Icons.lock,
                                message: "Please log in to view your health logs",
                              );
                            }

                            return StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('healthLogs')
                                  .where('patientId', isEqualTo: userInfo.id)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF2D6D66),
                                      ),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return _buildEmptyState(
                                    icon: Icons.error_outline,
                                    message: "Error loading health logs: ${snapshot.error}",
                                  );
                                }

                                List<QueryDocumentSnapshot> logs = snapshot.data?.docs ?? [];

                                if (_selectedDate != null) {
                                  final startDate = DateTime(
                                    _selectedDate!.year,
                                    _selectedDate!.month,
                                    _selectedDate!.day,
                                  );
                                  final endDate = startDate.add(const Duration(days: 1));

                                  logs = logs.where((log) {
                                    final timestamp = log['timestamp'] as Timestamp?;
                                    if (timestamp == null) return false;
                                    final date = timestamp.toDate();
                                    return date.isAfter(startDate) && date.isBefore(endDate);
                                  }).toList();
                                }

                                logs.sort((a, b) {
                                  final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                                  final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(0);
                                  return bTime.compareTo(aTime);
                                });

                                if (logs.isEmpty) {
                                  return _buildEmptyState(
                                    icon: Icons.medical_information_outlined,
                                    message: _selectedDate != null
                                        ? "No health logs for ${DateFormat('MMM d, y').format(_selectedDate!)}"
                                        : "No health logs found",
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: logs.length,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemBuilder: (context, index) {
                                    final log = logs[index];
                                    final data = log.data() as Map<String, dynamic>;

                                    final timestamp = data['timestamp'] as Timestamp?;
                                    final date = timestamp?.toDate() ?? DateTime.now();
                                    final formattedDate = DateFormat('MMM d, y • h:mm a').format(date);

                                    final symptoms = (data['symptoms'] as List<dynamic>?)
                                        ?.map((s) => s.toString())
                                        .toList() ?? [];

                                    final vitals = data['vitals'] as Map<String, dynamic>? ?? {};
                                    final bloodPressure = vitals['bloodPressure']?.toString();
                                    final heartRate = vitals['heartRate']?.toString();

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () => _loadLogForEdit(log),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    PopupMenuButton(
                                                      icon: const Icon(Icons.more_vert, size: 20),
                                                      itemBuilder: (context) => [
                                                        PopupMenuItem(
                                                          child: const Text('Edit'),
                                                          onTap: () => Future.delayed(
                                                            Duration.zero,
                                                                () => _loadLogForEdit(log),
                                                          ),
                                                        ),
                                                        PopupMenuItem(
                                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                          onTap: () => Future.delayed(
                                                            Duration.zero,
                                                                () => _deleteHealthLog(log.id),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                if (symptoms.isNotEmpty)
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: symptoms.map((symptom) {
                                                      return Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF2D6D66).withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(30),
                                                        ),
                                                        child: Text(
                                                          symptom,
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            color: Color(0xFF2D6D66),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                const SizedBox(height: 12),
                                                Row(
                                                  children: [
                                                    if (bloodPressure != null && bloodPressure.isNotEmpty)
                                                      _buildVitalItem(
                                                        icon: Icons.bloodtype,
                                                        value: bloodPressure,
                                                        label: 'BP',
                                                      ),
                                                    if (heartRate != null && heartRate.isNotEmpty)
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 16),
                                                        child: _buildVitalItem(
                                                          icon: Icons.favorite,
                                                          value: heartRate,
                                                          label: 'HR',
                                                          iconColor: Colors.redAccent,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                if (data['notes'] != null && (data['notes'] as String).isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 12),
                                                    child: Text(
                                                      data['notes'] as String,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onHomePressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        onCalendarPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        onRecordPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );
        },
        onChatPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChatListScreen()),
          );
        },
        onAddPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HealthLogTrackerScreen()),
          );
        },
      ),
    );
  }

  Widget _buildVitalItem({
    required IconData icon,
    required String value,
    required String label,
    Color iconColor = const Color(0xFF2D6D66),
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          '$value $label',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: const Color(0xFF2D6D66).withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}