import 'package:flutter/material.dart';

class Splash1curve extends StatefulWidget {
  const Splash1curve({super.key});

  @override
  State<Splash1curve> createState() => _Splash1curveState();
}

class _Splash1curveState extends State<Splash1curve> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Background curved container
              Positioned(
                width: 700,
                height:550,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color:
                        Color.fromARGB(255, 31, 172, 150), // Teal green color
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(800),
                      bottomRight: Radius.circular(800),
                    ),
                  ),
                ),
              ),
              // Centered image
              Image.asset(
                'assets/logos/trans.png',
              ),
            ],
          ),

          SizedBox(height: 200),
          // Fade-in animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(seconds: 5),
            builder: (_, double opacity, __) {
              return Opacity(
                opacity: opacity,
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'FAM',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A78E),
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'CARE',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5AB4F1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 100),
                    Text(
                      'FAMILY CAREGIVERS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF00A78E),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 50),
          //loading indicator
          Center(
            child: CircularProgressIndicator(
              color: const Color.fromARGB(255, 12, 172, 132),
            ),
          ),
        ],
      ),
    );
  }
}
