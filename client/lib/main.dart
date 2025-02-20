import 'package:client/Splash/Onboardingscreen.dart';
import 'package:client/Widgets/Splash1Curve.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/Pages/HomePage.dart';
import 'package:client/Splash/SplashScreen1.dart';
import 'state_provider.dart'; // Import Riverpod state



void main() {
  runApp(const ProviderScope(child: FamCare())); // Wrap in ProviderScope
}

class FamCare extends ConsumerWidget {
  const FamCare({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the FutureProvider to load the app state
    final appStateAsync = ref.watch(appStateFutureProvider);

    return appStateAsync.when(
      data: (appState) {
        // Once the state is loaded, navigate accordingly
        return MaterialApp(
          initialRoute: '/home',
          routes: {
          '/home': (context) => appState.isNewUser == true
              ? Splashscreen1()
             : Homepage(),
            
          },
        );
      },
      loading: () => const Center(
          child:
              CircularProgressIndicator()), // Show loading while waiting for data
      error: (error, stackTrace) =>
          Center(child: Text('Error: $error')), // Handle error case
    );
  }
}
