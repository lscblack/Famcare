import 'package:client/Splash/SplashScreen2.dart';
import 'package:client/Widgets/Splash1Curve.dart';
import 'package:client/screens/LoginScreen.dart';
import 'package:client/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc;
import 'package:flutter_animated_splash/flutter_animated_splash.dart';
import '../providers/state_provider.dart'; // Import AppBloc

class Splashscreen1 extends StatelessWidget {
  const Splashscreen1({super.key});

  @override
  Widget build(BuildContext context) {
    // Mark the user as not new after the widget is built
    Future.microtask(() {
      context.read<AppBloc>().add(MarkUserAsNotNew());
    });

    return bloc.BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        // Check if the user's email and name are not empty
        final user = state.users.isNotEmpty ? state.users.first : null;
        final isUserValid = user != null && user.email.isNotEmpty && user.name.isNotEmpty;

        // Determine the next screen based on isNewUser and user data
        final nextScreen = state.isNewUser
            ? Splashscreen2() // Show Splashscreen2 if the user is new
            : isUserValid
            ? DashboardScreen() // Show DashboardScreen if user data is valid
            : LoginScreen(); // Show LoginScreen if user data is invalid

        return AnimatedSplash(
          type: Transition.size, // No conflict now
          curve: Curves.easeOutCirc,
          navigator: nextScreen, // Use the determined next screen
          durationInSeconds: 5,
          child: Splash1curve(),
        );
      },
    );
  }
}