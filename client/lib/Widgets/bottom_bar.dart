import 'package:client/Widgets/inked_button.dart';
import 'package:client/globals.dart';
import 'package:flutter/material.dart';

class BottomBarItem {
  final IconData icon;
  final String route;
  final double? size;

  BottomBarItem({required this.icon, required this.route, this.size});
}

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    // List of Bottom Bar items (icons and routes)
    final bottomBarItems = [
      BottomBarItem(icon: Icons.home, route: '/home'),
      BottomBarItem(icon: Icons.search, route: '/search'),
      BottomBarItem(icon: Icons.add_box_rounded, route: '/notifications', size: 56),
      BottomBarItem(icon: Icons.calendar_month_rounded, route: '/schedule'),
      BottomBarItem(icon: Icons.account_circle, route: '/profile'),
    ];

    return Container(
      color: Colors.white, // Set your desired background color here
      child: Stack(
        clipBehavior: Clip.none, // Prevent the stack from clipping children
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: bottomBarItems.map((item) {
              // Apply opacity of 0 to the "add box" icon to make it invisible
              return InkedButton(
                route: item.route,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Visibility(
                    visible: item.icon != Icons.add_box_rounded, // Make "add box" icon invisible
                    child: Icon(
                      item.icon,
                      color: primaryGreen,
                      size: item.size ?? 28,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // Positioned widget to make the "add box" icon above the others
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 60 / 2, // Centering the icon horizontally
            bottom: 30, // Adjust how far above the row you want the icon
            child: InkedButton(
              route: bottomBarItems[2].route, // The route for the "add box" icon
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50), // Make it circular
                ),
                child: Icon(
                  bottomBarItems[2].icon,
                  color: primaryGreen,
                  size: bottomBarItems[2].size ?? 56,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
