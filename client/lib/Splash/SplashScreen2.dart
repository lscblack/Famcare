import 'package:flutter/material.dart';
import '../Widgets/fam_care_slider.dart';
import '../Widgets/onboarding_page.dart';

class Splashscreen2 extends StatefulWidget {
  const Splashscreen2({super.key});

  @override
  State<Splashscreen2> createState() => _Splashscreen2State();
}

class _Splashscreen2State extends State<Splashscreen2> {
  // Define the teal color used throughout the app
  final Color tealColor = const Color(0xFF00A78E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FamCareSlider(
          pages: [
            // First screen with illustrated doctors
            OnboardingPage(
              logo: 'assets/logos/trans.png',
              title: 'FAM CARE',
              subtitle: 'Storage your medical record',
              image: 'assets/images/doctor1.png',
              description: 'Manage medications, track health,\nand stay connected with\nloved ones',
              hasConnectionDiagram: true,
              backgroundColor: tealColor,
            ),
            
            // Second screen with doctor photo
            OnboardingPage(
              logo: 'assets/logos/trans.png',
              title: 'FAM CARE',
              subtitle: 'Storage your medical record',
              image: 'assets/images/doctor2.png',
              description: 'Empower your family to care\nwith confidence',
              backgroundColor: tealColor,
            ),
            
            // Third screen with healthcare professionals
            OnboardingPage(
              logo: 'assets/logos/trans.png',
              title: 'FAM CARE',
              subtitle: 'Caregiver Network Support',
              image: 'assets/images/doctor3.png',
              description: 'FamCare brings\neverything together',
              hasGetStartedButton: true,
              backgroundColor: tealColor,
              onGetStarted: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
          activeDotColor: tealColor,
          inactiveDotColor: tealColor.withOpacity(0.3),
          onComplete: () {
            // For example:
            Navigator.pushNamed(context, '/login');
          },
        ),
      );
  }
}
