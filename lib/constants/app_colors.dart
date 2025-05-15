import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  //-------------------------------------------------------------------------
  // Brand Colors
  //-------------------------------------------------------------------------
  
  // Primary brand color and variations
  static const Color primary = Color(0xFFF78C02);      // Main brand color (Orange)
  static const Color primaryLight = Color(0xFFFFAD42); // Lighter variation of primary
  static const Color primaryDark = Color(0xFFD76E00);  // Darker variation of primary
  static const Color primaryExtraLight = Color(0xFFFFEEDD); // Very light variation of primary

  // Secondary brand color and variations
  static const Color secondary = Color(0xFF4B9EF8);       // Secondary brand color (Blue)
  static const Color secondaryLight = Color(0xFF7ABAFF);  // Lighter variation of secondary
  static const Color secondaryDark = Color(0xFF1B7BE1);   // Darker variation of secondary
  static const Color secondaryExtraLight = Color(0xFFE6F2FF); // Very light variation of secondary
  
  // Accent color for highlights and accents
  static const Color accent = Color(0xFF21D393);      // Accent color (Green)
  static const Color accentLight = Color(0xFF5FEBB6); // Lighter variation of accent
  static const Color accentDark = Color(0xFF09AF73);  // Darker variation of accent
  static const Color accentExtraLight = Color(0xFFE0FFF5); // Very light variation of accent

  //-------------------------------------------------------------------------
  // Background Colors
  //-------------------------------------------------------------------------
  
  static const Color background = Color(0xFFAAE0FF);         // Main background color - Light Blue from your spec
  static const Color backgroundLight = Color(0xFFF8FAFC);    // Lighter background for cards
  static const Color backgroundMedium = Color(0xFFEDF2F7);   // Medium background for sections
  static const Color backgroundDark = Color(0xFFE2E8F0);     // Darker background for emphasis
  static const Color backgroundElevated = Colors.white;      // Background for elevated content

  //-------------------------------------------------------------------------
  // Text Colors
  //-------------------------------------------------------------------------
  
  static const Color textPrimary = Color(0xFF1A202C);    // Primary text color
  static const Color textSecondary = Color(0xFF4A5568);  // Secondary text color
  static const Color textTertiary = Color(0xFF718096);   // Tertiary text color
  static const Color textLight = Color(0xFFA0AEC0);      // Light text color
  static const Color textWhite = Colors.white;           // White text color
  static const Color textPrimaryInverse = Colors.white;  // Primary inverse text color

  //-------------------------------------------------------------------------
  // Border Colors
  //-------------------------------------------------------------------------
  
  static const Color border = Color(0xFFCBD5E0);       // Standard border color
  static const Color borderLight = Color(0xFFE2E8F0);  // Light border color
  static const Color borderMedium = Color(0xFFA0AEC0); // Medium border color
  static const Color borderDark = Color(0xFF718096);   // Dark border color

  //-------------------------------------------------------------------------
  // Status Colors
  //-------------------------------------------------------------------------
  
  // Success colors
  static const Color success = Color(0xFF2ECC71);         // Success color
  static const Color successLight = Color(0xFF7AEDB1);    // Light success color
  static const Color successDark = Color(0xFF1AAD5B);     // Dark success color
  static const Color successBackground = Color(0xFFE6F9EF); // Success background color
  
  // Warning colors
  static const Color warning = Color(0xFFF59E0B);         // Warning color
  static const Color warningLight = Color(0xFFFBD38D);    // Light warning color
  static const Color warningDark = Color(0xFFD97706);     // Dark warning color
  static const Color warningBackground = Color(0xFFFFF9E6); // Warning background color
  
  // Error colors
  static const Color error = Color(0xFFE53E3E);           // Error color
  static const Color errorLight = Color(0xFFFCA5A5);      // Light error color
  static const Color errorDark = Color(0xFFB91C1C);       // Dark error color
  static const Color errorBackground = Color(0xFFFEE2E2); // Error background color
  
  // Info colors
  static const Color info = Color(0xFF3B82F6);            // Info color
  static const Color infoLight = Color(0xFF93C5FD);       // Light info color
  static const Color infoDark = Color(0xFF1D4ED8);        // Dark info color
  static const Color infoBackground = Color(0xFFEFF6FF);  // Info background color

  //-------------------------------------------------------------------------
  // Category Colors (for service categories)
  //-------------------------------------------------------------------------
  
  static const Color categoryHome = Color(0xFF6366F1);      // Home repairs
  static const Color categoryPlumbing = Color(0xFF4C85E2);  // Plumbing
  static const Color categoryElectrical = Color(0xFFF59E0B); // Electrical
  static const Color categoryCleaning = Color(0xFF22C55E);  // Cleaning
  static const Color categoryTutoring = Color(0xFFEC4899);  // Tutoring
  static const Color categoryTransport = Color(0xFF0EA5E9); // Transport
  static const Color categoryEmergency = Color(0xFFEF4444); // Emergency services
  static const Color categoryOther = Color(0xFF8B5CF6);     // Other services

  //-------------------------------------------------------------------------
  // Booking Status Colors
  //-------------------------------------------------------------------------
  
  static const Color statusPending = Color(0xFFF59E0B);     // Pending status
  static const Color statusConfirmed = Color(0xFF3B82F6);   // Confirmed status
  static const Color statusInProgress = Color(0xFF8B5CF6);  // In progress status
  static const Color statusCompleted = Color(0xFF10B981);   // Completed status
  static const Color statusCancelled = Color(0xFFEF4444);   // Cancelled status

  //-------------------------------------------------------------------------
  // Rating Colors
  //-------------------------------------------------------------------------
  
  static const Color ratingActive = Color(0xFFF59E0B);      // Active rating star
  static const Color ratingInactive = Color(0xFFE2E8F0);    // Inactive rating star

  //-------------------------------------------------------------------------
  // Gradient Colors
  //-------------------------------------------------------------------------
  
  // Primary gradient
  static const List<Color> primaryGradient = [
    Color(0xFFF78C02),
    Color(0xFFFF9E2C),
  ];
  
  // Secondary gradient
  static const List<Color> secondaryGradient = [
    Color(0xFF4B9EF8),
    Color(0xFF70B5FF),
  ];
  
  // Success gradient
  static const List<Color> successGradient = [
    Color(0xFF2ECC71),
    Color(0xFF4AE288),
  ];
  
  // Error gradient
  static const List<Color> errorGradient = [
    Color(0xFFE53E3E),
    Color(0xFFFF6B6B),
  ];

  //-------------------------------------------------------------------------
  // Shadow Colors
  //-------------------------------------------------------------------------
  
  static const Color shadowLight = Color(0x1A000000);   // Light shadow color (10% opacity)
  static const Color shadowMedium = Color(0x26000000);  // Medium shadow color (15% opacity)
  static const Color shadowDark = Color(0x33000000);    // Dark shadow color (20% opacity)

  //-------------------------------------------------------------------------
  // UI Component Colors
  //-------------------------------------------------------------------------
  
  // App bar colors
  static const Color appBarBackground = primary;        // App bar background
  static const Color appBarText = Colors.white;         // App bar text
  
  // Bottom navigation colors
  static const Color bottomNavBackground = Colors.white;  // Bottom nav background
  static const Color bottomNavActive = primary;           // Bottom nav active item
  static const Color bottomNavInactive = textSecondary;   // Bottom nav inactive item
  
  // Button colors
  static const Color buttonPrimary = primary;             // Primary button color
  static const Color buttonSecondary = secondary;         // Secondary button color
  static const Color buttonDisabled = Color(0xFFCBD5E0);  // Disabled button color
  static const Color buttonText = Colors.white;           // Button text color
  
  // Input field colors
  static const Color inputBackground = Colors.white;      // Input field background
  static const Color inputBorder = borderLight;           // Input field border
  static const Color inputFocused = primary;              // Input field focused
  static const Color inputText = textPrimary;             // Input field text
  static const Color inputHint = textLight;               // Input field hint
  
  // Card colors
  static const Color cardBackground = Colors.white;       // Card background
  static const Color cardShadow = shadowLight;            // Card shadow

  //-------------------------------------------------------------------------
  // Helper Methods
  //-------------------------------------------------------------------------
  
  // Get color for category by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'home_repairs':
      case 'home repairs':
      case 'homerepairs':
        return categoryHome;
      case 'plumbing':
        return categoryPlumbing;
      case 'electrical':
        return categoryElectrical;
      case 'cleaning':
        return categoryCleaning;
      case 'tutoring':
        return categoryTutoring;
      case 'transport':
        return categoryTransport;
      case 'emergency':
        return categoryEmergency;
      default:
        return categoryOther;
    }
  }
  
  // Get color for booking status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'confirmed':
        return statusConfirmed;
      case 'in_progress':
      case 'in progress':
      case 'inprogress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
      case 'canceled':
        return statusCancelled;
      default:
        return textSecondary;
    }
  }
  
  // Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Get Material color swatch from a color
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
  
  // Get a primary swatch for theme
  static MaterialColor get primarySwatch => createMaterialColor(primary);
  
  // Get a secondary swatch for theme
  static MaterialColor get secondarySwatch => createMaterialColor(secondary);
}