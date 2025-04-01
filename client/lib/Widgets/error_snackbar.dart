import 'package:flutter/material.dart';

class ErrorSnackbar extends StatelessWidget {
  final String message;

  // Constructor to accept the message
  const ErrorSnackbar({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Show the snackbar when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Return an empty container as this is a utility widget
    return Container();
  }
}
