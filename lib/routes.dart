// routes.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/screens/common/about_us_screen.dart';
import 'package:handy_buddy/screens/common/contact_us_screen.dart';
import 'package:handy_buddy/screens/common/language_settings_screen.dart';
import 'package:handy_buddy/screens/common/settings_screen.dart';
import 'package:handy_buddy/screens/provider/auth/login_screen.dart';
import 'package:handy_buddy/screens/provider/auth/signup_screen.dart';
import 'package:handy_buddy/screens/provider/provider_main_screen.dart';
import 'package:handy_buddy/screens/seeker/auth/login_screen.dart';
import 'package:handy_buddy/screens/seeker/auth/signup_screen.dart';
import 'package:handy_buddy/screens/seeker/seeker_main_screen.dart';
import 'package:handy_buddy/screens/splash_screen.dart';

class Routes {
  static const splash = '/splash';
  static const providerWelcome = '/provider/welcome';
  static const providerLogin = '/provider/login';
  static const providerSignup = '/provider/signup';
  static const providerMain = '/provider/main';
  static const seekerLogin = '/seeker/login';
  static const seekerSignup = '/seeker/signup';
  static const seekerMain = '/seeker/main';
  static const settings = '/settings';
  static const language = '/language';
  static const contactUs = '/contact-us';
  static const aboutUs = '/about-us';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    providerLogin: (context) => const ProviderLoginScreen(),
    providerSignup: (context) => const ProviderSignupScreen(),
    providerMain: (context) => const ProviderMainScreen(),
    seekerLogin: (context) => const SeekerLoginScreen(),
    seekerSignup: (context) => const SeekerSignupScreen(),
    seekerMain: (context) => const SeekerMainScreen(),
    settings: (context) => const SettingsScreen(),
    language: (context) => const LanguageSettingsScreen(),
    contactUs: (context) => const ContactUsScreen(),
    aboutUs: (context) => const AboutUsScreen(),
  };
}