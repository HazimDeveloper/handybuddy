// lib/screens/provider/provider_main_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/screens/provider/bookings/bookings_screen.dart';
import 'package:handy_buddy/screens/provider/earnings/earnings_screen.dart';
import 'package:handy_buddy/screens/provider/home/provider_home_screen.dart';
import 'package:handy_buddy/screens/provider/profile/provider_profile_screen.dart';
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({Key? key}) : super(key: key);

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // List of screens to navigate between
  final List<Widget> _screens = [
    const ProviderHomeScreen(),
    const BookingsScreen(),
    const EarningsScreen(),
    const ProviderProfileScreen(),
  ];
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Handle navigation bar item taps
  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Handle page changes from PageView
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  // Handle back button press
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      // If not on the home tab, go to home tab
      _onNavItemTapped(0);
      return false;
    } else {
      // If on home tab, ask for confirmation to exit
      final shouldExit = await ConfirmDialog.show(
        context: context,
        title: 'Exit App',
        message: 'Are you sure you want to exit the app?',
        confirmButtonText: 'Exit',
        cancelButtonText: 'Cancel',
      );
      return shouldExit ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swiping between pages
          onPageChanged: _onPageChanged,
          children: _screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}