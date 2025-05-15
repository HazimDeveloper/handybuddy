import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Prevent instantiation
  AppStyles._();
  
  //-------------------------------------------------------------------------
  // Typography Styles
  //-------------------------------------------------------------------------
  
  // Headings
  static const TextStyle headingStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingLargeStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingMediumStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headingSmallStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  // Subheadings
  static const TextStyle subheadingStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle subheadingLightStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  // Body Text
  static const TextStyle bodyTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyTextBoldStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyTextMediumStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyTextLightStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.w300,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmallStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodySmallBoldStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Caption Text
  static const TextStyle captionStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle captionBoldStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Label Text
  static const TextStyle labelStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle labelLargeStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  // Button Text
  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.4,
  );
  
  static const TextStyle buttonSmallTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.4,
  );
  
  // Link Text
  static const TextStyle linkStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.5,
    decoration: TextDecoration.underline,
  );
  
  static const TextStyle linkSmallStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.4,
    decoration: TextDecoration.underline,
  );

  //-------------------------------------------------------------------------
  // Component Styles
  //-------------------------------------------------------------------------
  
  // Card Styles
  static final BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8.0,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static final BoxDecoration cardDecorationLight = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4.0,
        offset: const Offset(0, 1),
      ),
    ],
  );
  
  // Service Card
  static final BoxDecoration serviceCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Provider Card
  static final BoxDecoration providerCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(
      color: AppColors.borderLight,
      width: 1.0,
    ),
  );
  
  // Booking Card
  static final BoxDecoration bookingCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 6.0,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  // Input Decoration
  static const InputDecoration inputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 14.0,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: AppColors.borderLight,
        width: 1.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: AppColors.borderLight,
        width: 1.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 2.0,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: AppColors.error,
        width: 1.0,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      borderSide: BorderSide(
        color: AppColors.error,
        width: 2.0,
      ),
    ),
  );
  
  // Search Input Decoration
  static const InputDecoration searchInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 12.0,
    ),
    hintText: 'Search...',
    prefixIcon: Icon(
      Icons.search,
      color: AppColors.textSecondary,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30.0)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30.0)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(30.0)),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 1.0,
      ),
    ),
  );
  
  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 12.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 2.0,
    textStyle: buttonTextStyle,
  );
  
  static final ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 1.5),
    padding: const EdgeInsets.symmetric(
      horizontal: 24.0,
      vertical: 12.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    textStyle: buttonTextStyle.copyWith(color: AppColors.primary),
  );
  
  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 8.0,
    ),
    textStyle: buttonTextStyle.copyWith(color: AppColors.primary),
  );
  
  // Category Style
  static final BoxDecoration categoryDecoration = BoxDecoration(
    color: AppColors.backgroundLight,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(
      color: AppColors.borderLight,
      width: 1.0,
    ),
  );
  
  static final BoxDecoration categorySelectedDecoration = BoxDecoration(
    color: AppColors.primaryLight,
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(
      color: AppColors.primary,
      width: 1.0,
    ),
  );
  
  // Tag Style
  static final BoxDecoration tagDecoration = BoxDecoration(
    color: AppColors.backgroundLight,
    borderRadius: BorderRadius.circular(16.0),
  );
  
  static final BoxDecoration tagSelectedDecoration = BoxDecoration(
    color: AppColors.primaryLight,
    borderRadius: BorderRadius.circular(16.0),
  );
  
  // Avatar Style
  static const BoxDecoration avatarDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColors.primaryLight,
  );
  
  // Rating Style
  static const TextStyle ratingTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
    color: AppColors.warning,
  );

  //-------------------------------------------------------------------------
  // Layout Dimensions
  //-------------------------------------------------------------------------
  
  // Padding
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingRegular = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;
  
  // Margins
  static const double marginSmall = 4.0;
  static const double marginMedium = 8.0;
  static const double marginRegular = 16.0;
  static const double marginLarge = 24.0;
  static const double marginExtraLarge = 32.0;
  
  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusExtraLarge = 16.0;
  static const double borderRadiusRound = 30.0;
  
  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 48.0;
  
  // Button Sizes
  static const double buttonHeight = 48.0;
  static const double buttonSmallHeight = 36.0;
  static const double buttonLargeHeight = 56.0;
  
  // Avatar Sizes
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeExtraLarge = 96.0;
  
  // Card Sizes
  static const double cardBorderRadius = 12.0;
  static const double cardPadding = 16.0;
  static const double cardElevation = 2.0;
  
  // Image Sizes
  static const double serviceImageHeight = 160.0;
  static const double providerImageSize = 80.0;
  static const double categoryImageSize = 48.0;
  
  // Bottom Navigation
  static const double bottomNavHeight = 60.0;
  static const double bottomNavIconSize = 24.0;
  
  // App Bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  //-------------------------------------------------------------------------
  // ThemeData
  //-------------------------------------------------------------------------
  
  // App Theme
  static ThemeData getThemeData() {
    return ThemeData(
      primaryColor: AppColors.primary,
      primaryColorLight: AppColors.primaryLight,
      primaryColorDark: AppColors.primaryDark,
      
      scaffoldBackgroundColor: AppColors.background,
      
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
      ),
      
      fontFamily: 'Poppins',
      
      textTheme: const TextTheme(
        displayLarge: headingLargeStyle,
        displayMedium: headingStyle,
        displaySmall: headingMediumStyle,
        headlineMedium: subheadingStyle,
        titleLarge: subheadingStyle,
        titleMedium: bodyTextMediumStyle,
        titleSmall: bodyTextStyle,
        bodyLarge: bodyTextStyle,
        bodyMedium: bodySmallStyle,
        bodySmall: captionStyle,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: appBarElevation,
        titleTextStyle: headingSmallStyle,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButtonStyle,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: secondaryButtonStyle,
      ),
      textButtonTheme: TextButtonThemeData(
        style: textButtonStyle,
      ),
      
      // Input Theme
      inputDecorationTheme: const InputDecorationTheme(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 14.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(
      color: AppColors.borderLight,
      width: 1.0,
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(
      color: AppColors.borderLight,
      width: 1.0,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(
      color: AppColors.primary,
      width: 2.0,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(
      color: AppColors.error,
      width: 1.0,
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)),
    borderSide: BorderSide(
      color: AppColors.error,
      width: 2.0,
    ),
  ),
),

      // TabBar Theme
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: bodyTextBoldStyle,
        unselectedLabelStyle: bodyTextStyle,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: marginMedium,
          horizontal: marginMedium,
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: headingMediumStyle,
        contentTextStyle: bodyTextStyle,
      ),
      
      // BottomSheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusLarge),
          ),
        ),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primaryLight;
          }
          return Colors.grey.shade300;
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryLight,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1.0,
        space: 1.0,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primaryLight,
      ),
    );
  }
}