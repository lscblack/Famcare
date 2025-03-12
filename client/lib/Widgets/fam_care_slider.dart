import 'package:flutter/material.dart';

/// A professional, customizable slider widget for onboarding or presentation screens
/// Features:
/// - Smooth page transitions with PageView
/// - Navigation buttons (Next/Skip)
/// - Page indicator dots
/// - Swipe gestures for navigation
class FamCareSlider extends StatefulWidget {
  /// List of pages/screens to display in the slider
  final List<Widget> pages;
  
  /// Text for the "Next" button
  final String nextButtonText;
  
  /// Text for the "Skip" button
  final String skipButtonText;
  
  /// Color for the active dot indicator
  final Color activeDotColor;
  
  /// Color for inactive dot indicators
  final Color inactiveDotColor;
  
  /// Action to perform when the slider is completed
  final VoidCallback? onComplete;
  
  /// Color for the navigation buttons
  final Color buttonColor;

  const FamCareSlider({
    super.key,
    required this.pages,
    this.nextButtonText = 'NEXT',
    this.skipButtonText = 'Previous',
    this.activeDotColor = const Color(0xFF00A78E),
    this.inactiveDotColor = Colors.grey,
    this.onComplete,
    this.buttonColor = const Color(0xFF00A78E),
  });

  @override
  State<FamCareSlider> createState() => _FamCareSliderState();
}

class _FamCareSliderState extends State<FamCareSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < widget.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete?.call();
    }
  }

  void _skipToEnd() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main content area
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: widget.pages,
          ),
        ),
        
        // Navigation controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Skip button
              TextButton(
                onPressed: _skipToEnd,
                child: Text(
                  widget.skipButtonText,
                  style: TextStyle(color: widget.buttonColor),
                ),
              ),
              
              // Dot indicators
              Row(
                children: List.generate(
                  widget.pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? widget.activeDotColor
                          : widget.inactiveDotColor,
                    ),
                  ),
                ),
              ),
              
              // Next button
              TextButton(
                onPressed: _goToNextPage,
                child: Text(
                  widget.nextButtonText,
                  style: TextStyle(color: widget.buttonColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}