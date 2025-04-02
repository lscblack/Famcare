import 'package:client/Splash/SplashScreen1.dart';
import 'package:client/screens/auth/register_screen.dart';
import 'package:client/screens/chat_screen.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;

// Initialize the notifications plugin when the app starts
Future<void> initNotifications() async {
  tz_data.initializeTimeZones();

  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await notifications.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification taps by navigating to calendar
      if (response.payload != null) {
        navigatorKey.currentState?.pushNamed('/calendar');
      }
    },
  );

  // Request permissions (add for iOS)
  await notifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // Request notification permissions
  final NotificationAppLaunchDetails? launchDetails =
      await notifications.getNotificationAppLaunchDetails();

  print(
      'App launched from notification: ${launchDetails?.didNotificationLaunchApp}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initNotifications();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppCubit>(create: (context) => AppCubit()),
      ],
      child: const FamCare(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FamCare extends StatelessWidget {
  const FamCare({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            // '/': (context) => RwandaPhoneAuth(),
            '/': (context) => Splashscreen1(),
            '/home': (context) => DashboardScreen(),
            '/profile': (context) => ProfilePage(),
            '/register': (context) => RegisterScreen(),
            '/login': (context) => LoginScreen(),
            '/calendar': (context) => CalendarScreen(),
            '/chat': (context) => ChatListScreen(),
            '/chat-detail': (context) => ChatScreen(),
            '/record': (context) => RecordScreen(),
          },
        );
      },
    );
  }
}
