// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is already logged in
    if (authProvider.isLoggedIn) {
      if (authProvider.isProvider) {
        Navigator.pushReplacementNamed(context, Routes.providerMain);
      } else {
        Navigator.pushReplacementNamed(context, Routes.seekerMain);
      }
    } else {
      // Check if we have a stored user type preference
      final prefs = await SharedPreferences.getInstance();
      final String userType = prefs.getString('userType') ?? '';
      
      if (userType == 'provider') {
        Navigator.pushReplacementNamed(context, Routes.providerWelcome);
      } else {
        Navigator.pushReplacementNamed(context, Routes.seekerLogin);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Light blue: AAE0FF
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            const Text(
              'Handy Buddy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF78C02), // Using the appbar color for text
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Service Partner',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFFF78C02), // Using the appbar color for text
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF78C02)), // Primary color
            ),
          ],
        ),
      ),
    );
  }
}