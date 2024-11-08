import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import your splash screen
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import 'patient_details_screen.dart'; // Import the PatientDetailsScreen
import 'user_info_update_screen.dart'; // Update to the correct user info update screen
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitiGo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito',
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Set the splash screen as the home
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/patient-details': (context) => const PatientDetailsScreen(), // Add the PatientDetailsScreen route
        '/update-user-info': (context) => UserInfoUpdateScreen(
          onUpdate: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      },
    );
  }
}
