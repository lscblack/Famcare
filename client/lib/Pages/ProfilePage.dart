import 'package:client/Widgets/bottom_bar.dart';
import 'package:client/Widgets/profile_card.dart';
import 'package:client/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: Color(0xFF1648CE),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              const Image(image: AssetImage("assets/logos/logo_name.png")),
              const Spacer(),
            ],
          ),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Image(image: AssetImage("assets/icon.png")),
                    Container(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "Karekezi",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "01.01.2022",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF342B33),
                            ),
                          ),
                          Text(
                            "+250781213141",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF342B33),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    SvgPicture.asset("assets/fluent_pen-20-filled.svg")
                  ],
                ),
              ),
            ),
          ),
          const ProfileCard(
            iconPath: "assets/fluent_book-exclamation-mark-20-filled.svg",
            title: 'Health History',
            description: "Check your All Medical History",
          ),
          const ProfileCard(
            iconPath: "assets/mdi_account-child.svg",
            title: "Karekezi's History",
            description: "Receive and save up. Points to receive gifts",
          ),
        ],
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}
