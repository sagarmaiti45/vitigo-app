import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds:3),
      vsync: this,
    );

    // Logo fade-in animation
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward(); // Start the animation
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Delay for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // Get the token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');

    // Navigate to the appropriate screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => token != null ? DashboardScreen() : LoginScreen(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Background color for splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: _logoAnimation.value,
              child: Image.asset(
                'assets/logo_trans.png', // Your logo image
                width: 100, // Set the width of the logo
                height: 100, // Set the height of the logo
              ),
            ),
            SizedBox(height: 20),
            // Typewriter animation for text
            TyperAnimatedTextKit(
              text: ['VitiGo'],
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              speed: Duration(milliseconds: 150), // Typing speed
              isRepeatingAnimation: false, // Do not repeat animation
            ),
          ],
        ),
      ),
    );
  }
}
