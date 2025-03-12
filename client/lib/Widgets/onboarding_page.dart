import 'package:flutter/material.dart';

/// A single onboarding page widget for the FamCare app with improved stacking
class OnboardingPage extends StatelessWidget {
  final String logo;
  final String title;
  final String subtitle;
  final String image;
  final String description;
  final bool hasConnectionDiagram;
  final bool hasGetStartedButton;
  final Color backgroundColor;
  final VoidCallback? onGetStarted;

  const OnboardingPage({
    super.key,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.description,
    this.hasConnectionDiagram = false,
    this.hasGetStartedButton = false,
    required this.backgroundColor,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: screenWidth,
      height: screenHeight,
      color: Colors.white,
      child: Column(
        children: [
          // Top section with overflowing background
          SizedBox(
            height: 350,
            width: screenWidth,
            child: Stack(
              clipBehavior: Clip.none, // Allow overflow
              alignment: Alignment.center,
              children: [
                // Background curved container
                Positioned(
                  top: 0,
                  left: screenWidth * -0.25, // Center the element
                  child: Container(
                    width: screenWidth * 1.5, // Make it 150% of the screen width to overflow
                    height: 450,
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(1.0), // Use the provided backgroundColor
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(800),
                        bottomRight: Radius.circular(800),
                      ),
                    ),
                  ),
                ),
                
                // Content on top of the background
                Positioned(
                  top: 40,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo and title row
                      Image.asset("assets/logos/logo_white.png", height: 100),
                      const SizedBox(height: 10),
  
                      // Subtitle
                      const SizedBox(height: 10),
                      SizedBox(
                        width: screenWidth * 0.8, // Constrain width for better text appearance
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      
                      // Main image
                      // const SizedBox(height: 10),
                      SizedBox(
                        height: 400,
                        width: screenWidth * 0.8, // Constrain width for better image appearance
                        child: Image.asset(
                          image, 
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Spacer to push content down
          const SizedBox(height: 150),
          if (!hasConnectionDiagram)
          const SizedBox(height: 150),

          // Description section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SizedBox(
              width: screenWidth * 0.85, // Constrain width for better reading
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF00A78E)),
              ),
            ),
          ),

          // Expanded space to push button to bottom if present
          const Spacer(),

          // Optional connection diagram
          if (hasConnectionDiagram)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 200,
                child: Center(
                  child: 
                   Image.asset(
                    'assets/images/connec.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

          // Optional "Get Started" button
          if (hasGetStartedButton)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
              child: ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          
          // Bottom spacer if no button
          if (!hasGetStartedButton) const SizedBox(height: 40),
        ],
      ),
    );
  }
}