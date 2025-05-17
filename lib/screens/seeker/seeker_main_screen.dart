// lib/screens/seeker/seeker_main_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/screens/seeker/bookings/seeker_booking_screen.dart';
import 'package:handy_buddy/screens/seeker/home/seeker_home_screen.dart';
import 'package:handy_buddy/screens/seeker/profile/seeker_profile_screen.dart';

class SeekerMainScreen extends StatefulWidget {
  const SeekerMainScreen({Key? key}) : super(key: key);

  @override
  State<SeekerMainScreen> createState() => _SeekerMainScreenState();
}

class _SeekerMainScreenState extends State<SeekerMainScreen> {
  int _currentIndex = 0;
  
  // List of screens to display
  final List<Widget> _screens = [
    const SeekerHomeScreen(),
    const SeekerBookingScreen(),
    const SeekerProfileScreen(),
  ];
  
  // List of bottom navigation items
  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.calendar_today_outlined),
      activeIcon: Icon(Icons.calendar_today),
      label: 'Bookings',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _bottomNavItems,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}