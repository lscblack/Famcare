import 'package:client/Pages/LoginScreen.dart';
import 'package:client/Pages/ProfilePage.dart';
import 'package:client/Pages/RegisterScreen.dart';
import 'package:client/screens/ChatScreen.dart';
import 'package:client/screens/calendar_screen.dart';
import 'package:client/screens/dashboard_screen.dart';
import 'package:client/screens/record_screen.dart';
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
          initialRoute: '/dashboard',
          routes: {
            '/': (context) => Homepage(),
            '/home': (context) =>
                appState.isNewUser ? Splashscreen1() : Homepage(),
            '/profile': (context) => ProfilePage(),
            // '/reset': (context) => reset_screen(),
            '/signup': (context) => RegisterScreen(),
            '/login': (context) => LoginScreen(),
            '/calendar': (context) => CalendarScreen(),
            '/chat': (context) => ChatScreen(),
            '/dashboard': (context) => DashboardScreen(),
            '/record': (context) => RecordScreen(),
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
