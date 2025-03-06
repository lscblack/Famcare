import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;
  final Color backgroundColor;
  final bool isLast;
  final VoidCallback? onGetStarted;

  const OnboardingPage({
    Key? key,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.backgroundColor,
    this.isLast = false,
    this.onGetStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Column(
      children: [
        // Top section with curved bottom
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Background color
            Container(
              width: double.infinity,
              height: screenSize.height * 0.5,
              color: backgroundColor,
              child: Column(
                children: [
                  SizedBox(height: screenSize.height * 0.06),
                  // FAM CARE logo at top
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'FAM CARE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom curved section
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: BottomCurveClipper(),
                child: Container(
                  height: 100,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Image positioned above curve
            Positioned(
              bottom: 20, // Adjust to sit on the curve
              child: Image.asset(
                imageAsset,
                height: screenSize.height * 0.35, // Slightly larger for better visibility
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        
        // Bottom section with description and actions
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(height: screenSize.height * 0.05),
                // Description text
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                
                if (isLast) ...[
                  Spacer(),
                  // Icons row for the last screen
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_information_outlined, 
                        color: backgroundColor,
                        size: 28,
                      ),
                      SizedBox(width: screenSize.width * 0.2),
                      Icon(
                        Icons.local_hospital_outlined,
                        color: backgroundColor,
                        size: 28,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Get Started button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: onGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00A88E),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Improved bottom curve clipper to match the screenshots
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from the top-left corner
    path.moveTo(0, 0);
    path.lineTo(0, size.height * 0.5);
    
    // Create the curve that matches the screenshot
    path.quadraticBezierTo(
      size.width * 0.5, // Control point x - middle of screen
      size.height * 1.5, // Control point y - deeper curve
      size.width, // End point x - right side
      size.height * 0.5, // End point y - same height as start
    );
    
    // Complete the path
    path.lineTo(size.width, 0);
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}