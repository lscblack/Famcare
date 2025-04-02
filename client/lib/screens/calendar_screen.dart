import 'package:client/Widgets/bottom_nav_bar.dart';
import 'package:client/screens/record_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:client/screens/dashboard_screen.dart';

class CalendarGrid extends StatefulWidget {
  final DateTime focusedDate;
  final Function(DateTime) onDateSelected;

  const CalendarGrid({
    Key? key,
    required this.focusedDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late DateTime _selectedDate;
  late List<DateTime> _calendarDays;
  Map<DateTime, int> _taskCountByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.focusedDate;
    _generateCalendarDays();
    _fetchTaskCounts();
  }

  @override
  void didUpdateWidget(CalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDate != widget.focusedDate) {
      setState(() {
        _generateCalendarDays();
        _fetchTaskCounts();
      });
    }
  }

  void _generateCalendarDays() {
    final DateTime firstDayOfMonth =
        DateTime(widget.focusedDate.year, widget.focusedDate.month, 1);
    final int daysInMonth =
        DateTime(widget.focusedDate.year, widget.focusedDate.month + 1, 0).day;

    // Get the weekday of the first day (0 = Monday, 6 = Sunday in DateTime)
    int firstWeekdayOfMonth = firstDayOfMonth.weekday;
    // Adjust to make Sunday = 0, Saturday = 6
    firstWeekdayOfMonth = firstWeekdayOfMonth % 7;

    // Calculate days from previous month to show
    List<DateTime> days = [];
    for (int i = 0; i < firstWeekdayOfMonth; i++) {
      days.add(
          firstDayOfMonth.subtract(Duration(days: firstWeekdayOfMonth - i)));
    }

    // Add days of current month
    for (int i = 0; i < daysInMonth; i++) {
      days.add(
          DateTime(widget.focusedDate.year, widget.focusedDate.month, i + 1));
    }

    // Add days from next month to complete the grid (6 rows x 7 days = 42 cells)
    int remainingDays = 42 - days.length;
    DateTime lastDayOfMonth = DateTime(
        widget.focusedDate.year, widget.focusedDate.month, daysInMonth);
    for (int i = 1; i <= remainingDays; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }

    _calendarDays = days;
  }

  Future<void> _fetchTaskCounts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Get user's family ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final families = List<String>.from(userDoc['families'] ?? []);
      if (families.isEmpty) return;

      Map<DateTime, int> taskCounts = {};

      // Get the first and last day shown on the calendar
      DateTime firstDay = _calendarDays.first;
      DateTime lastDay = _calendarDays.last.add(const Duration(days: 1));

      // Query tasks for the visible date range
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('familyId', isEqualTo: families.first)
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
          .where('dueDate', isLessThan: Timestamp.fromDate(lastDay))
          .get();

      // Group tasks by day
      for (var doc in tasksSnapshot.docs) {
        final task = doc.data();
        final dueDate = (task['dueDate'] as Timestamp).toDate();
        final dayStart = DateTime(dueDate.year, dueDate.month, dueDate.day);

        taskCounts[dayStart] = (taskCounts[dayStart] ?? 0) + 1;
      }

      setState(() {
        _taskCountByDay = taskCounts;
      });
    } catch (e) {
      print('Error fetching task counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekdayHeader(),
        _buildCalendarGrid(),
        const SizedBox(height: 16),
        _buildTaskList(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              day,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: _calendarDays.length,
      itemBuilder: (context, index) {
        final day = _calendarDays[index];
        final isCurrentMonth = day.month == widget.focusedDate.month;
        final isSelected = day.year == _selectedDate.year &&
            day.month == _selectedDate.month &&
            day.day == _selectedDate.day;
        final isToday = day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;

        final dayStart = DateTime(day.year, day.month, day.day);
        final taskCount = _taskCountByDay[dayStart] ?? 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = day;
            });
            widget.onDateSelected(day);
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF37B5B6)
                  : isToday
                      ? const Color(0xFFE3F9F9)
                      : null,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF37B5B6))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isCurrentMonth
                            ? Colors.black
                            : Colors.grey,
                    fontWeight: isToday || isSelected ? FontWeight.bold : null,
                  ),
                ),
                if (taskCount > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.white : const Color(0xFF37B5B6),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color? _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green[600];
      case 'cancelled':
        return Colors.grey[600];
      case 'overdue':
        return Colors.red[600];
      default:
        return Colors.yellow[600];
    }
  }

  Future<String> _checkOverdue(Map<String, dynamic> task) async {
    final dueDate = (task['dueDate'] as Timestamp).toDate();
    final status = task['status'] as String;

    if (status == 'pending' && dueDate.isBefore(DateTime.now())) {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task['id'])
          .update({'status': 'overdue'});
      return 'overdue';
    }
    return status;
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(taskId)
          .update({'status': newStatus});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: ${e.toString()}')),
      );
    }
  }

  void _showEditStatusDialog(
      BuildContext context, String taskId, String currentStatus) {
    String? selectedStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Task Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Pending'),
                value: 'pending',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
              RadioListTile<String>(
                title: const Text('Completed'),
                value: 'completed',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
              RadioListTile<String>(
                title: const Text('Cancelled'),
                value: 'cancelled',
                groupValue: selectedStatus,
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedStatus != null) {
                _updateTaskStatus(taskId, selectedStatus!);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF37B5B6),
            ),
            child: const Text('Update Status'),
          ),
        ],
      ),
    );
  }

Widget _buildTaskList() {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return const Center(child: Text('Please login to view tasks'));
  }

  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots(),
    builder: (context, userSnapshot) {
      if (userSnapshot.hasError) {
        return _buildErrorWidget('Failed to load user data');
      }

      if (userSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
        return const Center(child: Text('User data not found'));
      }

      final families = List<String>.from(userSnapshot.data!['families'] ?? []);
      if (families.isEmpty) {
        return const Center(child: Text('No family assigned'));
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('familyId', isEqualTo: families.first)
            .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(
              DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
            ))
            .where('dueDate', isLessThan: Timestamp.fromDate(
              DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day + 1),
            ))
            .snapshots(),
        builder: (context, taskSnapshot) {
          if (taskSnapshot.hasError) {
            return _buildErrorWidget('Failed to load tasks');
          }

          if (taskSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskSnapshot.data?.docs ?? [];

          if (tasks.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              ...tasks.map((doc) => _buildTaskItem(doc)).toList(),
              const SizedBox(height: 16),
              _buildAddTaskButton(context),
            ],
          );
        },
      );
    },
  );
}

// Add these missing components
Widget _buildErrorWidget(String message) {
  return Column(
    children: [
      Icon(Icons.error, color: Colors.red, size: 40),
      Text(message, style: TextStyle(color: Colors.red)),
    ],
  );
}


Widget _buildTaskItem(DocumentSnapshot doc) {
  final task = doc.data() as Map<String, dynamic>;
  final dueDate = (task['dueDate'] as Timestamp).toDate();

  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      onTap: () => _showEditStatusDialog(context, doc.id, task['status']),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getStatusColor(task['status'])?.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.task,
          color: _getStatusColor(task['status']),
        ),
      ),
      title: Text(
        task['title'],
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        DateFormat('hh:mm a').format(dueDate),
        style: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
      trailing: Chip(
        label: Text(task['status']),
        backgroundColor: _getStatusColor(task['status'])?.withOpacity(0.1),
        labelStyle: TextStyle(
          color: _getStatusColor(task['status']),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

Widget _buildEmptyState(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 24),
      Text(
        'No tasks for ${DateFormat('MMM dd').format(_selectedDate)}',
        style: GoogleFonts.poppins(color: Colors.grey),
      ),
      const SizedBox(height: 16),
      _buildAddTaskButton(context),
    ],
  );
}

Widget _buildAddTaskButton(BuildContext context) {
  return ElevatedButton.icon(
    onPressed: () => _showAddTaskDialog(context),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF37B5B6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    icon: const Icon(Icons.add, color: Colors.white),
    label: Text(
      'Add Task',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime selectedDate = _selectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();
    String repeatOption = 'none';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Task'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) setState(() => selectedTime = time);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedTime.format(context)),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  RadioListTile(
                    title: const Text('None'),
                    value: 'none',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Daily'),
                    value: 'daily',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Weekly'),
                    value: 'weekly',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Monthly'),
                    value: 'monthly',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  _createTask(
                    context,
                    titleController.text,
                    selectedDate,
                    selectedTime,
                    repeatOption,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37B5B6),
              ),
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTask(BuildContext context, String title, DateTime date,
      TimeOfDay time, String repeatOption) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get user's family ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final families = List<String>.from(userDoc['families'] ?? []);
      if (families.isEmpty) {
        throw Exception('User not part of any family');
      }

      final dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      // Store task in Firestore
      final taskData = {
        'title': title,
        'dueDate': dueDate,
        'status': 'pending',
        'familyId': families.first,
        'assignedTo': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'repeatOption': repeatOption,
      };

      final taskRef =
          await FirebaseFirestore.instance.collection('tasks').add(taskData);

      // Create recurring tasks if needed
      if (repeatOption != 'none') {
        await _createRecurringTasks(taskRef.id, taskData, repeatOption);
      }

      // Schedule notification
      await _scheduleNotification(title, dueDate, taskRef.id);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );

      // Refresh task counts
      _fetchTaskCounts();
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating task: ${e.toString()}')),
      );
      print("Error creating task: ${e.toString()}");
    }
  }

  Future<void> _createRecurringTasks(String originalTaskId,
      Map<String, dynamic> taskData, String repeatOption) async {
    try {
      final batchSize = 10; // Limit number of recurring tasks to create at once
      final batch = FirebaseFirestore.instance.batch();

      DateTime originalDate = taskData['dueDate'];
      DateTime nextDate;

      for (int i = 1; i <= batchSize; i++) {
        switch (repeatOption) {
          case 'daily':
            nextDate = originalDate.add(Duration(days: i));
            break;
          case 'weekly':
            nextDate = originalDate.add(Duration(days: 7 * i));
            break;
          case 'monthly':
            nextDate = DateTime(
              originalDate.year + ((originalDate.month + i - 1) ~/ 12),
              ((originalDate.month + i - 1) % 12) + 1,
              originalDate.day,
              originalDate.hour,
              originalDate.minute,
            );
            break;
          default:
            continue;
        }

        final newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();
        final newTaskData = Map<String, dynamic>.from(taskData);
        newTaskData['dueDate'] = nextDate;
        newTaskData['parentTaskId'] = originalTaskId;

        batch.set(newTaskRef, newTaskData);
      }

      await batch.commit();
    } catch (e) {
      print('Error creating recurring tasks: $e');
    }
  }

  Future<void> _scheduleNotification(
    String title,
    DateTime dueDate,
    String taskId,
  ) async {
    try {
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      // Get the local timezone
      final location = tz.getLocation('Africa/Johannesburg');

      // Convert the dueDate to the local timezone
      final scheduledDate = tz.TZDateTime.from(dueDate, location);

      // Set up the Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      // Create the NotificationDetails object
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      // Schedule the notification
      await notifications.zonedSchedule(
        taskId.hashCode, // Unique notification ID (taskId.hashCode)
        'Task Reminder', // Notification title
        title, // Notification content (title of the task)
        scheduledDate, // The time to schedule the notification
        notificationDetails, // Notification details for Android
        matchDateTimeComponents: DateTimeComponents
            .time, // Match based on time components (hour, minute)
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Exact schedule even when idle
      );
      print("Scheduled Date: $scheduledDate");
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}

// Main Calendar Screen Component
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDate;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (date.month != _focusedDate.month) {
        _focusedDate = DateTime(date.year, date.month, 1);
      }
    });
  }

  void _onMonthChanged(DateTime date) {
    setState(() {
      _focusedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Color(0xFF37B5B6),
            fontSize: 24,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                            _focusedDate.year,
                            _focusedDate.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37B5B6),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () {
                        setState(() {
                          _focusedDate = DateTime(
                            _focusedDate.year,
                            _focusedDate.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: CalendarGrid(
                  focusedDate: _focusedDate,
                  onDateSelected: _onDateSelected,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: const Color(0xFF37B5B6),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        onHomePressed: () {
          Navigator.pushNamed(context, '/home');
        },
        onCalendarPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        },
        onRecordPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );
        },
        onChatPressed: () {
          Navigator.pushNamed(context, '/chat');
        },
        onAddPressed: () {
          print('FAB Clicked');
        },
        currentIndex: 0,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime selectedDate = _selectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();
    String repeatOption = 'none';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Task'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required field' : null,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) setState(() => selectedTime = time);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(selectedTime.format(context)),
                          const Icon(Icons.access_time),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Repeat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  RadioListTile(
                    title: const Text('None'),
                    value: 'none',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Daily'),
                    value: 'daily',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Weekly'),
                    value: 'weekly',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                  RadioListTile(
                    title: const Text('Monthly'),
                    value: 'monthly',
                    groupValue: repeatOption,
                    onChanged: (value) =>
                        setState(() => repeatOption = value.toString()),
                    activeColor: const Color(0xFF37B5B6),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // Call the task creation method from CalendarScreen
                  Navigator.pop(context);
                  _createTask(
                    titleController.text,
                    selectedDate,
                    selectedTime,
                    repeatOption,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF37B5B6),
              ),
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createRecurringTasks(String originalTaskId,
      Map<String, dynamic> taskData, String repeatOption) async {
    try {
      final batchSize = 10; // Limit number of recurring tasks to create at once
      final batch = FirebaseFirestore.instance.batch();

      DateTime originalDate = taskData['dueDate'];
      DateTime nextDate;

      for (int i = 1; i <= batchSize; i++) {
        switch (repeatOption) {
          case 'daily':
            nextDate = originalDate.add(Duration(days: i));
            break;
          case 'weekly':
            nextDate = originalDate.add(Duration(days: 7 * i));
            break;
          case 'monthly':
            nextDate = DateTime(
              originalDate.year + ((originalDate.month + i - 1) ~/ 12),
              ((originalDate.month + i - 1) % 12) + 1,
              originalDate.day,
              originalDate.hour,
              originalDate.minute,
            );
            break;
          default:
            continue;
        }

        final newTaskRef = FirebaseFirestore.instance.collection('tasks').doc();
        final newTaskData = Map<String, dynamic>.from(taskData);
        newTaskData['dueDate'] = nextDate;
        newTaskData['parentTaskId'] = originalTaskId;

        batch.set(newTaskRef, newTaskData);
      }

      await batch.commit();
    } catch (e) {
      print('Error creating recurring tasks: $e');
    }
  }

  Future<void> _scheduleNotification(
    String title,
    DateTime dueDate,
    String taskId,
  ) async {
    try {
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      // Get the local timezone
      final location = tz.getLocation('Africa/Johannesburg');
      ;

      // Convert the dueDate to the local timezone
      final scheduledDate = tz.TZDateTime.from(dueDate, location);

      // Set up the Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      // Create the NotificationDetails object
      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      // Schedule the notification
      await notifications.zonedSchedule(
        taskId.hashCode, // Unique notification ID (taskId.hashCode)
        'Task Reminder', // Notification title
        title, // Notification content (title of the task)
        scheduledDate, // The time to schedule the notification
        notificationDetails, // Notification details for Android
        matchDateTimeComponents: DateTimeComponents
            .time, // Match based on time components (hour, minute)
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Exact schedule even when idle
      );
      print("Scheduled Date: $scheduledDate");
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> _createTask(
      String title, DateTime date, TimeOfDay time, String repeatOption) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Get user's family ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final families = List<String>.from(userDoc['families'] ?? []);
      if (families.isEmpty) {
        throw Exception('User not part of any family');
      }

      final dueDate =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);

      // Store task in Firestore
      final taskData = {
        'title': title,
        'dueDate': dueDate,
        'status': 'pending',
        'familyId': families.first,
        'assignedTo': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'repeatOption': repeatOption,
      };

      final taskRef =
          await FirebaseFirestore.instance.collection('tasks').add(taskData);

      // Create recurring tasks if needed
      if (repeatOption != 'none') {
        await _createRecurringTasks(taskRef.id, taskData, repeatOption);
      }

      // Schedule notification
      await _scheduleNotification(title, dueDate, taskRef.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );

      // Force refresh by changing state
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating task: ${e.toString()}')),
      );
      print("Error creating task: ${e.toString()}");
    }
  }
}
