import 'package:flutter/material.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record Screen')),
      body: const Center(child: Text('This is Record Screen')),
    );
  }
}