// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Firebase configuration
import 'firebase_options.dart';

// App Providers
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/service_provider.dart';

// App Constants
import 'constants/app_colors.dart';
import 'constants/app_styles.dart';

// Navigation
import 'routes.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers for state management
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ServiceProvider>(
          create: (_) => ServiceProvider(),
          update: (_, authProvider, serviceProvider) => 
              serviceProvider!..update(authProvider.user),
        ),
        // Add more providers as needed
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Handy Buddy',
            theme: ThemeData(
              primarySwatch: AppColors.primarySwatch,
              scaffoldBackgroundColor: AppColors.background,
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  textStyle: AppStyles.buttonTextStyle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              textTheme: Theme.of(context).textTheme.apply(
                fontFamily: 'Poppins',
                bodyColor: AppColors.textPrimary,
                displayColor: AppColors.textPrimary,
              ),
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: AppColors.primarySwatch,
              ).copyWith(
                secondary: AppColors.secondary,
                error: AppColors.error,
              ),
              inputDecorationTheme: AppStyles.inputDecoration,
            ),
            // Set dark theme if needed
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: AppColors.primarySwatch,
              scaffoldBackgroundColor: const Color(0xFF121212),
              // Add more dark theme settings as needed
            ),
            // Use system theme preference
            themeMode: ThemeMode.system,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ms', ''), // Malay
              Locale('zh', ''), // Chinese
              Locale('ta', ''), // Tamil
            ],
            
            // Routing configuration
            initialRoute: Routes.splash,
            routes: Routes.getRoutes(),
            onGenerateRoute: Routes.generateRoute,
            
            // Disable debug banner
            debugShowCheckedModeBanner: false,
            
            // Error handling for routing
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
              );
            },
            
            // Scroll behavior configuration
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              physics: const BouncingScrollPhysics(),
              overscroll: false,
            ),
          );
        },
      ),
    );
  }
}

// Used for UI debugging - wraps widgets with borders to visualize layout
class DebugWidgetBorder extends StatelessWidget {
  final Widget child;
  final Color color;

  const DebugWidgetBorder({
    Key? key,
    required this.child,
    this.color = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
      ),
      child: child,
    );
  }
}