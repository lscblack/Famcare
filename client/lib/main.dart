import 'package:client/Splash/SplashScreen1.dart';
import 'package:client/screens/dashboard_screen.dart';
import 'package:client/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:client/providers/state_provider.dart';
import 'package:client/screens/profile_page.dart';
import 'package:client/screens/RegisterScreen.dart';
import 'package:client/screens/LoginScreen.dart';
import 'package:client/screens/calendar_screen.dart';
import 'package:client/screens/chat_list_screen.dart';
import 'package:client/screens/record_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context) => AppCubit()),
      ],
      child: const FamCare(),
    ),
  );
}

class FamCare extends StatelessWidget {
  const FamCare({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            // '/': (context) => Test(),
            '/': (context) => Splashscreen1(),
            '/home': (context) => DashboardScreen(),
            '/profile': (context) => ProfilePage(),
            '/register': (context) => RegisterScreen(),
            '/login': (context) => LoginScreen(),
            '/calendar': (context) => CalendarScreen(),
            '/chat': (context) => ChatListScreen(),
            '/record': (context) => RecordScreen(),
          },
        );
      },
    );
  }
}
