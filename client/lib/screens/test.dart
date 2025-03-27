import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _isLoading = false;
  String _statusMessage = "Initializing...";

  @override
  void initState() {
    super.initState();
    _addUser();
  }

  Future<void> _addUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Adding user...";
    });

    final user = <String, dynamic>{
      "first": "Ada",
      "last": "Lovelace",
      "born": 1815,
    };

    try {
      DocumentReference docRef = await db.collection("users").add(user);
      setState(() {
        _statusMessage = 'User added with ID: ${docRef.id}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firestore Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) const CircularProgressIndicator(),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
