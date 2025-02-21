import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/Widgets/Splash1Curve.dart';
import 'package:client/Pages/HomePage.dart';
import 'package:client/screens/auth/login_screen.dart';
import 'package:client/screens/auth/register_screen.dart';
import 'package:client/Splash/SplashScreen1.dart';
import 'state_provider.dart';

void main() {
  runApp(const ProviderScope(child: FamCare()));
}

class FamCare extends ConsumerWidget {
  const FamCare({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateFutureProvider);

    return appStateAsync.when(
      data: (appState) {
        if (appState == null) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error: App state is null')),
            ),
          );
        }
        return MaterialApp(
          initialRoute: '/login',
          routes: {
            '/home': (context) => (appState.isNewUser ?? false) ? Splashscreen1() : Homepage(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stackTrace) {
        debugPrint("Error: $error\nStackTrace: $stackTrace");
        return MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Error: $error')),
          ),
        );
      },
    );
  }
}
