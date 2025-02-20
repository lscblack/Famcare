import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/Pages/HomePage.dart';
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

  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/first_screen.png',
      'title': 'Storage your medical record',
      'description': 'Manage medications, track health, and stay connected with loved ones.'
    },
    {
      'image': 'assets/images/second_screen.png',
      'title': 'Storage your medical record',
      'description': 'Empower your family to care with confidence.'
    },
    {
      'image': 'assets/images/Third_screen.png',
      'title': 'Caregiver Network Support',
      'description': 'FamCare brings everything together.'
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
    // Update the app state using Riverpod
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
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _onboardingData.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) => OnboardingPageContent(
                image: _onboardingData[index]['image']!,
                title: _onboardingData[index]['title']!,
                description: _onboardingData[index]['description']!,
                isLast: index == _onboardingData.length - 1,
                onGetStarted: index == _onboardingData.length - 1 ? () {
                  _markOnboardingSeen();
                  _navigateToHome();
                } : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    _markOnboardingSeen();
                    _navigateToHome();
                  },
                  child: Text("Skip"),
                ),
                Row(
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _markOnboardingSeen();
                      _navigateToHome();
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(_currentPage == _onboardingData.length - 1 ? "Get Started" : "Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Renamed to avoid conflict with your fancier OnboardingPage class
class OnboardingPageContent extends StatelessWidget {
  final String image, title, description;
  final bool isLast;
  final VoidCallback? onGetStarted;

  const OnboardingPageContent({
    required this.image,
    required this.title,
    required this.description,
    this.isLast = false,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 300),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 177, 216, 197)),
            textAlign: TextAlign.center,
          ),
          if (isLast && onGetStarted != null) ...[
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Main function for checking first run and deciding navigation path
class AppInitializer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        final prefs = snapshot.data!;
        final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
        
        if (seenOnboarding) {
          // User has seen onboarding, go to splash then home
          return Splashscreen1();
        } else {
          // First time user, go to onboarding
          return OnboardingScreen();
        }
      },
    );
  }
}