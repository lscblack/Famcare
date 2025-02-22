import 'package:flutter/material.dart';

class InkedButton extends StatelessWidget {
  final Widget child;
  final String route;

  const InkedButton({Key? key, required this.child, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      
      child: child,
      
    );
  }
}
