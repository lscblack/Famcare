import 'package:client/Widgets/OnboardingPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state_provider.dart';
import 'SplashScreen1.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'image': 'assets/images/first_screen.png',
      'title': 'Storage your medical record',
      'description': 'Manage medications, track health, and stay connected with loved ones.',
      'backgroundColor': Color(0xFF25B1AB) // Teal color from screenshot
    },
    {
      'image': 'assets/images/second_screen.png',
      'title': 'Storage your medical record',
      'description': 'Empower your family to care with confidence.',
      'backgroundColor': Color(0xFF25B1AB) // Teal color from screenshot
    },
    {
      'image': 'assets/images/Third_screen.png',
      'title': 'Caregiver Network Support',
      'description': 'FamCare brings everything together.',
      'backgroundColor': Color(0xFF25B1AB) // Teal color from screenshot
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySeen();
  }

  void _checkIfAlreadySeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seen = prefs.getBool('seenOnboarding');
    if (seen == true) {
      _navigateToHome();
    }
  }

  void _markOnboardingSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    ref.read(appStateProvider.notifier).setNewUser(false);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Splashscreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for onboarding screens
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => OnboardingPage(
              imageAsset: _onboardingData[index]['image']!,
              title: _onboardingData[index]['title']!,
              description: _onboardingData[index]['description']!,
              backgroundColor: _onboardingData[index]['backgroundColor']!,
              isLast: index == _onboardingData.length - 1,
              onGetStarted: index == _onboardingData.length - 1 ? () {
                _markOnboardingSeen();
                _navigateToHome();
              } : null,
            ),
          ),
          
          // Navigation controls (Skip, dots, Next)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _currentPage == _onboardingData.length - 1 
                ? SizedBox.shrink() // Hide on the last screen (has Get Started button)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: () {
                          _markOnboardingSeen();
                          _navigateToHome();
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      // Page indicator dots
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index 
                                ? _onboardingData[_currentPage]['backgroundColor'] 
                                : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                      
                      // Next button
                      TextButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          "Next",
                          style: TextStyle(
                            color: _onboardingData[_currentPage]['backgroundColor'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}