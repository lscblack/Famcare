// ignore: file_names
import 'package:client/Splash/SplashScreen2.dart';
import 'package:client/Widgets/Splash1Curve.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state_provider.dart'; // Import Riverpod provider
import 'package:flutter_animated_splash/flutter_animated_splash.dart';

class Splashscreen1 extends ConsumerWidget {
  const Splashscreen1({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use microtask to set state after build is complete
    Future.microtask(() {
      //use setstate to update the state using setState
      // setState(() {
        ref.read(appStateProvider.notifier).setNewUser(false); // Update state
      // });
    });

    return AnimatedSplash(
      type: Transition.size,
      curve: Curves.easeOutCirc,
      navigator: const Splashscreen2(), // Navigate to Homepage
      durationInSeconds: 5,
      child: Splash1curve(),
    );
  }
}
