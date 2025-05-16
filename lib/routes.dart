// routes.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/screens/common/about_us_screen.dart';
import 'package:handy_buddy/screens/common/contact_us_screen.dart';
import 'package:handy_buddy/screens/common/language_settings_screen.dart';
import 'package:handy_buddy/screens/common/settings_screen.dart';

// Provider screens
import 'package:handy_buddy/screens/provider/auth/login_screen.dart';
import 'package:handy_buddy/screens/provider/auth/signup_screen.dart';
import 'package:handy_buddy/screens/provider/auth/welcome_screen.dart';
import 'package:handy_buddy/screens/provider/bookings/booking_detail_screen.dart';
import 'package:handy_buddy/screens/provider/bookings/bookings_screen.dart';
import 'package:handy_buddy/screens/provider/earnings/earnings_screen.dart';
import 'package:handy_buddy/screens/provider/home/manage_service_screen.dart';
import 'package:handy_buddy/screens/provider/home/provider_home_screen.dart';
import 'package:handy_buddy/screens/provider/profile/provider_profile_screen.dart';
import 'package:handy_buddy/screens/provider/profile/edit_profile_screen.dart';
import 'package:handy_buddy/screens/provider/profile/edit_profile_name_screen.dart';
import 'package:handy_buddy/screens/provider/profile/change_password_screen.dart';
import 'package:handy_buddy/screens/provider/provider_main_screen.dart';

// Seeker screens
import 'package:handy_buddy/screens/seeker/auth/login_screen.dart';
import 'package:handy_buddy/screens/seeker/auth/signup_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/booking_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/booking_confirmation_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/payment_screen.dart';
import 'package:handy_buddy/screens/seeker/booking/rebook_screen.dart';
import 'package:handy_buddy/screens/seeker/bookings/seeker_booking_screen.dart';
import 'package:handy_buddy/screens/seeker/bookings/booking_detail_screen.dart';
import 'package:handy_buddy/screens/seeker/chat/chat_screen.dart';
import 'package:handy_buddy/screens/seeker/home/seeker_home_screen.dart';
import 'package:handy_buddy/screens/seeker/profile/seeker_profile_screen.dart';
import 'package:handy_buddy/screens/seeker/profile/edit_profile_screen.dart';
import 'package:handy_buddy/screens/seeker/rate/rate_screen.dart';
import 'package:handy_buddy/screens/seeker/seeker_main_screen.dart';
import 'package:handy_buddy/screens/seeker/services/service_category_screen.dart';
import 'package:handy_buddy/screens/seeker/services/service_detail_screen.dart';

// Splash screen
import 'package:handy_buddy/screens/splash_screen.dart';

class Routes {
  // Common routes
  static const String splash = '/';
  static const String settings = '/settings';
  static const String languageSettings = '/settings/language';
  static const String contactUs = '/contact-us';
  static const String aboutUs = '/about-us';
  
  // Provider routes
  static const String providerWelcome = '/provider/welcome';
  static const String providerLogin = '/provider/login';
  static const String providerSignup = '/provider/signup';
  static const String providerSignupDetails = '/provider/signup/details';
  static const String providerMain = '/provider/main';
  static const String providerHome = '/provider/home';
  static const String providerBookings = '/provider/bookings';
  static const String providerBookingDetail = '/provider/bookings/detail';
  static const String providerEarnings = '/provider/earnings';
  static const String providerProfile = '/provider/profile';
  static const String providerEditProfile = '/provider/profile/edit';
  static const String providerEditProfileName = '/provider/profile/edit/name';
  static const String providerChangePassword = '/provider/profile/password';
  static const String manageService = '/provider/services/manage';
  static const String addService = '/provider/services/add';
  static const String editService = '/provider/services/edit';
  
  // Seeker routes
  static const String seekerLogin = '/seeker/login';
  static const String seekerSignup = '/seeker/signup';
  static const String seekerMain = '/seeker/main';
  static const String seekerHome = '/seeker/home';
  static const String serviceCategory = '/seeker/services/category';
  static const String serviceDetail = '/seeker/services/detail';
  static const String booking = '/seeker/booking';
  static const String bookingConfirmation = '/seeker/booking/confirmation';
  static const String payment = '/seeker/booking/payment';
  static const String seekerBookings = '/seeker/bookings';
  static const String seekerBookingDetail = '/seeker/bookings/detail';
  static const String rebook = '/seeker/booking/rebook';
  static const String rateService = '/seeker/rate';
  static const String chat = '/seeker/chat';
  static const String seekerProfile = '/seeker/profile';
  static const String seekerEditProfile = '/seeker/profile/edit';

  // Define all app routes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Common routes
      splash: (context) => const SplashScreen(),
      settings: (context) => const SettingsScreen(),
      languageSettings: (context) => const LanguageSettingsScreen(),
      contactUs: (context) => const ContactUsScreen(),
      aboutUs: (context) => const AboutUsScreen(),
      
      // Provider routes
      providerWelcome: (context) => const ProviderWelcomeScreen(),
      providerLogin: (context) => const ProviderLoginScreen(),
      providerSignup: (context) => const ProviderSignupScreen(),
      providerMain: (context) => const ProviderMainScreen(),
      providerBookingDetail: (context) => const ProviderBookingDetailScreen(),
      providerEditProfile: (context) => const ProviderEditProfileScreen(),
      providerEditProfileName: (context) => const EditProfileNameScreen(),
      providerChangePassword: (context) => const ChangePasswordScreen(),
      manageService: (context) => const ManageServiceScreen(),
      
      // Seeker routes
      seekerLogin: (context) => const SeekerLoginScreen(),
      seekerSignup: (context) => const SeekerSignupScreen(),
      seekerMain: (context) => const SeekerMainScreen(),
      serviceCategory: (context) => const ServiceCategoryScreen(),
      serviceDetail: (context) => const ServiceDetailScreen(),
      booking: (context) => const BookingScreen(),
      bookingConfirmation: (context) => const BookingConfirmationScreen(),
      payment: (context) => const PaymentScreen(),
      seekerBookingDetail: (context) => const SeekerBookingDetailScreen(),
      rebook: (context) => const RebookScreen(),
      rateService: (context) => const RateScreen(),
      chat: (context) => const ChatScreen(),
      seekerEditProfile: (context) => const SeekerEditProfileScreen(),
    };
  }

  // Handle route generation for dynamic routes or routes with parameters
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract route arguments
    final args = settings.arguments;

    switch (settings.name) {
      // Dynamic routes with parameters
      case providerBookingDetail:
        final bookingId = args as String;
        return MaterialPageRoute(
          builder: (_) => ProviderBookingDetailScreen(bookingId: bookingId),
        );
        
      case seekerBookingDetail:
        final bookingId = args as String;
        return MaterialPageRoute(
          builder: (_) => SeekerBookingDetailScreen(bookingId: bookingId),
        );
        
      case serviceCategory:
        final category = args as String;
        return MaterialPageRoute(
          builder: (_) => ServiceCategoryScreen(category: category),
        );
        
      case serviceDetail:
        final serviceId = args as String;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(serviceId: serviceId),
        );
        
      case chat:
        final Map<String, dynamic> chatArgs = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            otherUserId: chatArgs['otherUserId'],
            chatId: chatArgs['chatId'],
          ),
        );
        
      case rateService:
        final Map<String, dynamic> rateArgs = args as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RateScreen(
            bookingId: rateArgs['bookingId'],
            providerId: rateArgs['providerId'],
          ),
        );
        
      case rebook:
        final bookingId = args as String;
        return MaterialPageRoute(
          builder: (_) => RebookScreen(previousBookingId: bookingId),
        );
        
      case editService:
        final serviceId = args as String;
        return MaterialPageRoute(
          builder: (_) => ManageServiceScreen(serviceId: serviceId),
        );
        
      // Default fallback for undefined routes
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helpers
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateToReplacement<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, Object?>(context, routeName, arguments: arguments);
  }

  static Future<T?> navigateAndRemoveUntil<T>(BuildContext context, String routeName, {Object? arguments, String? untilRouteName}) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      routeName, 
      untilRouteName == null 
          ? (route) => false 
          : ModalRoute.withName(untilRouteName),
      arguments: arguments,
    );
  }
  
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
  
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
}