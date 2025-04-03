import 'package:client/Splash/SplashScreen2.dart';
import 'package:client/Widgets/Splash1Curve.dart';
import 'package:client/screens/LoginScreen.dart';
import 'package:client/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as bloc_lib;
import 'package:flutter_animated_splash/flutter_animated_splash.dart';
import '../providers/state_provider.dart';

class Splashscreen1 extends StatelessWidget {
  const Splashscreen1({super.key});

  @override
  Widget build(BuildContext context) {
    // Mark the user as not new after the widget is built
    Future.microtask(() {
      context.read<AppCubit>().markUserAsNotNew();
    });

    return bloc_lib.BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        // Determine the next screen based on authentication state
        Widget nextScreen;

        if (state is AppInitial || state is AppLoading) {
          return const Center(child: CircularProgressIndicator());

        }
        else if (state is AppAuthenticated) {
          nextScreen = const DashboardScreen();
        }
        else {
          nextScreen = const Splashscreen2();
        }

        return AnimatedSplash(
          type: Transition.size, // Uses flutter_animated_splash's Transition
          curve: Curves.easeOutCirc,
          navigator: nextScreen,
          durationInSeconds: 5,
          child: const Splash1curve(),
        );
      },
    );
  }
}
