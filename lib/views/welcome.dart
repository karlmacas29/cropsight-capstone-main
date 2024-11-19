import 'package:cropsight/views/navigation/nav_page.dart';
import 'package:flutter/material.dart';

class WelcomePageOne extends StatefulWidget {
  const WelcomePageOne({super.key});

  @override
  State<WelcomePageOne> createState() => _WelcomePageOneState();
}

class _WelcomePageOneState extends State<WelcomePageOne> {
  double getResponsiveFontSize(BuildContext context, double fontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Adjust the scaling factor as needed
    return fontSize *
        (screenWidth / 375.0); // 375 is a standard width (e.g., iPhone 11)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Image.asset(
          'assets/background/welcome_screen_cs.jpg', // Change to your image path
          fit: BoxFit.cover,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CropSight',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: getResponsiveFontSize(context, 40),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Center(
                child: Text(
                  'A mobile app for rice crop pest detection system using mobile camera.',
                  style: TextStyle(
                      color: const Color.fromRGBO(196, 196, 196, 1),
                      fontFamily: 'Inter',
                      fontSize: getResponsiveFontSize(context, 20),
                      fontWeight: FontWeight.w100),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const HomePageNav()));
                },
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8))),
                  fixedSize: const WidgetStatePropertyAll(Size(200, 55)),
                  backgroundColor: const WidgetStatePropertyAll(
                      Color.fromRGBO(86, 144, 51, 1)),
                ),
                child: const Text(
                  'Let\'s Get Started',
                  style: TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
                )),
            const SizedBox(
              height: 70,
            ),
            // ClickButton(
            //   backgroundColor: const Color.fromRGBO(2, 101, 0, 1),
            //   borderColor: const Color.fromRGBO(2, 101, 0, 1),
            //   text: 'Lets get started',
            //   textColor: Colors.white,
            //   function: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => const HomePageNav()));
            //   },
            // ),
          ],
        ),
      ]),
    );
  }
}
