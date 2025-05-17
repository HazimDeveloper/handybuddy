// lib/routes.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/screens/common/about_us_screen.dart';
import 'package:handy_buddy/screens/common/contact_us_screen.dart';
import 'package:handy_buddy/screens/common/language_settings_screen.dart';
import 'package:handy_buddy/screens/common/settings_screen.dart';
import 'package:handy_buddy/screens/provider/auth/login_screen.dart';
import 'package:handy_buddy/screens/provider/auth/signup_screen.dart';
import 'package:handy_buddy/screens/provider/auth/welcome_screen.dart';
import 'package:handy_buddy/screens/provider/bookings/booking_detail_screen.dart';
import 'package:handy_buddy/screens/provider/bookings/bookings_screen.dart';
import 'package:handy_buddy/screens/provider/earnings/earnings_screen.dart';
import 'package:handy_buddy/screens/provider/home/manage_service_screen.dart';
import 'package:handy_buddy/screens/provider/home/provider_home_screen.dart';
import 'package:handy_buddy/screens/provider/profile/change_password_screen.dart';
import 'package:handy_buddy/screens/provider/profile/edit_profile_screen.dart';
import 'package:handy_buddy/screens/provider/profile/provider_profile_screen.dart';
import 'package:handy_buddy/screens/provider/provider_main_screen.dart';
import 'package:handy_buddy/screens/seeker/auth/login_screen.dart';
import 'package:handy_buddy/screens/seeker/auth/signup_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/booking_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/booking_confirmation_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/payment_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/rebook_screen.dart';
import 'package:handy_buddy/screens/seeker/bookings/seeker_booking_screen.dart';
import 'package:handy_buddy/screens/seeker/chat/chat_screen.dart';
import 'package:handy_buddy/screens/seeker/home/seeker_home_screen.dart';
import 'package:handy_buddy/screens/seeker/profile/seeker_profile_screen.dart';
import 'package:handy_buddy/screens/seeker/rate/rate_screen.dart';
import 'package:handy_buddy/screens/seeker/seeker_main_screen.dart';
import 'package:handy_buddy/screens/seeker/services/service_category_screen.dart';
import 'package:handy_buddy/screens/seeker/services/service_detail_screen.dart';
import 'package:handy_buddy/screens/splash_screen.dart';

class Routes {
  // Splash and welcome
  static const String splash = '/';
  static const String providerWelcome = '/provider/welcome';
  
  // Provider auth routes
  static const String providerLogin = '/provider/login';
  static const String providerSignup = '/provider/signup';
  
  // Seeker auth routes
  static const String seekerLogin = '/seeker/login';
  static const String seekerSignup = '/seeker/signup';
  
  // Provider main screens
  static const String providerMain = '/provider/main';
  static const String providerHome = '/provider/home';
  static const String providerProfile = '/provider/profile';
  static const String providerBookings = '/provider/bookings';
  static const String providerEarnings = '/provider/earnings';
  
  // Provider profile screens
  static const String providerEditProfile = '/provider/profile/edit';
  static const String providerEditName = '/provider/profile/edit/name';
  static const String providerChangePassword = '/provider/profile/change_password';
  
  // Provider service management
  static const String manageService = '/provider/service/manage';
  static const String addService = '/provider/service/add';
  static const String editService = '/provider/service/edit';
  
  // Provider booking screens
  static const String providerBookingDetail = '/provider/booking/detail';
  
  // Seeker main screens
  static const String seekerMain = '/seeker/main';
  static const String seekerHome = '/seeker/home';
  static const String seekerProfile = '/seeker/profile';
  static const String seekerBookings = '/seeker/bookings';
  
  // Seeker profile screens
  static const String seekerEditProfile = '/seeker/profile/edit';
  static const String seekerChangePassword = '/seeker/profile/change_password';
  
  // Seeker service screens
  static const String serviceCategory = '/seeker/services/category';
  static const String serviceDetail = '/seeker/services/detail';
  
  // Seeker booking screens
  static const String booking = '/seeker/booking';
  static const String bookService = '/seeker/book';
  static const String bookingConfirmation = '/seeker/book/confirm';
  static const String payment = '/seeker/book/payment';
  static const String rebook = '/seeker/book/rebook';
  static const String seekerBookingDetail = '/seeker/booking/detail';
  static const String rateService = '/seeker/rate';
  static const String emergencyRequest = '/seeker/emergency-request';
  
  // Chat
  static const String chat = '/chat';
  
  // Common screens
  static const String settings = '/settings';
  static const String languageSettings = '/settings/language';
  static const String aboutUs = '/about';
  static const String contactUs = '/contact';
  
  // For backward compatibility
  static get providerEditProfileName => providerEditName;
  
  // Method to navigate to a route
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  
  // Method to navigate and remove previous routes
  static void navigateAndRemoveUntil(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      routeName, 
      (Route<dynamic> route) => false,
      arguments: arguments
    );
  }
  
  // Method to replace current route
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  // Method to go back
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
  
  // Define all routes for MaterialApp
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Splash and welcome
      splash: (context) => const SplashScreen(),
      providerWelcome: (context) => const ProviderWelcomeScreen(),
      
      // Provider auth routes
      providerLogin: (context) => const ProviderLoginScreen(),
      providerSignup: (context) => const ProviderSignupScreen(),
      
      // Seeker auth routes
      seekerLogin: (context) => const SeekerLoginScreen(),
      seekerSignup: (context) => const SeekerSignupScreen(),
      
      // Provider main screens
      providerMain: (context) => const ProviderMainScreen(),
      providerHome: (context) => const ProviderHomeScreen(),
      providerProfile: (context) => const ProviderProfileScreen(),
      providerBookings: (context) => const BookingsScreen(),
      providerEarnings: (context) => const EarningsScreen(),
      
      // Provider profile screens
      providerEditProfile: (context) => const EditProfileScreen(),
      providerEditName: (context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Profile Name')),
        body: const Center(child: Text('Edit Profile Name Screen')),
      ),
      providerChangePassword: (context) => const ChangePasswordScreen(),
      
      // Provider service management
      manageService: (context) => const ManageServiceScreen(),
      addService: (context) => Scaffold(
        appBar: AppBar(title: const Text('Add Service')),
        body: const Center(child: Text('Add Service Screen')),
      ),
      editService: (context) {
        final String serviceId = ModalRoute.of(context)!.settings.arguments as String;
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Service')),
          body: Center(child: Text('Edit Service: $serviceId')),
        );
      },
      
      // Provider booking screens
      providerBookingDetail: (context) {
        final String bookingId = ModalRoute.of(context)!.settings.arguments as String;
        return ProviderBookingDetailScreen(bookingId: bookingId);
      },
      
      // Seeker main screens
      seekerMain: (context) => const SeekerMainScreen(),
      seekerHome: (context) => const SeekerHomeScreen(),
      seekerProfile: (context) => const SeekerProfileScreen(),
      seekerBookings: (context) => const SeekerBookingScreen(),
      
      // Seeker profile screens
      seekerEditProfile: (context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: Text('Edit Profile Screen')),
      ),
      seekerChangePassword: (context) => Scaffold(
        appBar: AppBar(title: const Text('Change Password')),
        body: const Center(child: Text('Change Password Screen')),
      ),
      
      // Seeker service screens
      serviceCategory: (context) {
        final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return ServiceCategoryScreen(
          categoryId: args['categoryId'] ?? '',
          categoryName: args['categoryName'] ?? '',
        );
      },
      serviceDetail: (context) {
        final String serviceId = ModalRoute.of(context)!.settings.arguments as String;
        return ServiceDetailScreen(
          serviceId: serviceId,
        );
      },
      
      // Seeker booking screens
      booking: (context) => Scaffold(
        appBar: AppBar(title: const Text('Book a Service')),
        body: const Center(child: Text('Booking Selection Screen')),
      ),
      bookService: (context) {
        // Let's implement a placeholder for now
        return Scaffold(
          appBar: AppBar(title: const Text('Book Service')),
          body: const Center(child: Text('Booking Screen')),
        );
      },
      bookingConfirmation: (context) {
        // Using a Scaffold as a placeholder for now
        final String bookingId = ModalRoute.of(context)!.settings.arguments as String;
        return Scaffold(
          appBar: AppBar(title: const Text('Booking Confirmation')),
          body: Center(child: Text('Booking ID: $bookingId')),
        );
      },
      payment: (context) {
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return PaymentScreen(
          amount: args['amount'],
          bookingId: args['bookingId'],
        );
      },
      rebook: (context) {
        final String previousBookingId = ModalRoute.of(context)!.settings.arguments as String;
        return RebookScreen(previousBookingId: previousBookingId);
      },
      // Seeker booking screens detail and rate
      seekerBookingDetail: (context) {
        final String bookingId = ModalRoute.of(context)!.settings.arguments as String;
        // Use a more generic approach with a Scaffold until you can confirm the actual implementation
        return Scaffold(
          appBar: AppBar(title: const Text('Booking Details')),
          body: Center(child: Text('Booking ID: $bookingId')),
        );
      },
      rateService: (context) {
        final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
        return RateScreen(
          bookingId: args['bookingId'] ?? '', 
          providerId: args['providerId'] ?? '',
        );
      },
      emergencyRequest: (context) {
        final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return Scaffold(
          appBar: AppBar(title: const Text('Emergency Service Request')),
          body: Center(
            child: Text('Emergency Request Screen: ${args != null ? 'Category: ${args['category']}' : 'No category specified'}'),
          ),
        );
      },
      
      // Chat
      chat: (context) {
        final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatScreen(
          otherUserId: args['otherUserId'],
          chatId: args['chatId'],
        );
      },
      
      // Common screens
      settings: (context) => const SettingsScreen(),
      languageSettings: (context) => const LanguageSettingsScreen(),
      aboutUs: (context) => const AboutUsScreen(),
      contactUs: (context) => const ContactUsScreen(),
    };
  }
  
  // onUnknownRoute handler for when a named route is not found
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}