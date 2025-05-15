import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_colors.dart';

class ToastUtils {
  // Prevent instantiation
  ToastUtils._();
  
  // Default toast duration
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 4);
  
  // Default toast position
  static const ToastGravity _defaultGravity = ToastGravity.BOTTOM;
  
  // Default toast text style
  static const TextStyle _defaultTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  
  // Default padding
  static const EdgeInsets _defaultPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  
  // Default border radius
  static const double _defaultBorderRadius = 8.0;
  
  //-------------------------------------------------------------------------
  // Main Toast Methods
  //-------------------------------------------------------------------------
  
  /// Show a standard success toast message
  static Future<bool?> showSuccessToast(
    String message, {
    bool isLong = false,
    ToastGravity gravity = _defaultGravity,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: isLong ? 4 : 2,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// Show a standard error toast message
  static Future<bool?> showErrorToast(
    String message, {
    bool isLong = false,
    ToastGravity gravity = _defaultGravity,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: isLong ? 4 : 2,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// Show a standard info toast message
  static Future<bool?> showInfoToast(
    String message, {
    bool isLong = false,
    ToastGravity gravity = _defaultGravity,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: isLong ? 4 : 2,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// Show a standard warning toast message
  static Future<bool?> showWarningToast(
    String message, {
    bool isLong = false,
    ToastGravity gravity = _defaultGravity,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: isLong ? 4 : 2,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  
  /// Show a customized toast with specified parameters
  static Future<bool?> showCustomToast({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    bool isLong = false,
    ToastGravity gravity = _defaultGravity,
    double fontSize = 16.0,
  }) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: isLong ? 4 : 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
  
  /// Cancel any displayed toasts
  static void cancelToast() {
    Fluttertoast.cancel();
  }
  
  //-------------------------------------------------------------------------
  // Custom Context-Based Toasts (for SnackBar style)
  //-------------------------------------------------------------------------
  
  /// Show a custom toast-like SnackBar (for more control over appearance)
  static void showSnackToast(
    BuildContext context, {
    required String message,
    Color backgroundColor = AppColors.primary,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    double? width,
    ShapeBorder? shape,
    EdgeInsets margin = const EdgeInsets.all(8.0),
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      width: width,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: margin,
      padding: padding,
    );
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// Show a success toast using SnackBar style
  static void showSuccessSnackToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackToast(
      context,
      message: message,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
  
  /// Show an error toast using SnackBar style
  static void showErrorSnackToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackToast(
      context,
      message: message,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
  
  /// Show an info toast using SnackBar style
  static void showInfoSnackToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackToast(
      context,
      message: message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
  
  /// Show a warning toast using SnackBar style
  static void showWarningSnackToast(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    showSnackToast(
      context,
      message: message,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }
  
  //-------------------------------------------------------------------------
  // Custom Styled Toast Widgets
  //-------------------------------------------------------------------------
  
  /// Show a custom toast with Material design and icon
  static Future<bool?> showMaterialToast({
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    bool isLong = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Widget toast = Container(
      padding: _defaultPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              message,
              style: _defaultTextStyle.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
    
    final fToast = FToast().init(globalKey.currentContext!);
    fToast.showToast(
      child: toast,
      gravity: gravity,
      toastDuration: isLong ? _longDuration : _shortDuration,
    );
    return Future.value(true);
  }
  
  /// Show a success toast with checkmark icon
  static Future<bool?> showMaterialSuccessToast({
    required String message,
    bool isLong = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    return showMaterialToast(
      message: message,
      icon: Icons.check_circle,
      backgroundColor: AppColors.success,
      isLong: isLong,
      gravity: gravity,
    );
  }
  
  /// Show an error toast with error icon
  static Future<bool?> showMaterialErrorToast({
    required String message,
    bool isLong = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    return showMaterialToast(
      message: message,
      icon: Icons.error,
      backgroundColor: AppColors.error,
      isLong: isLong,
      gravity: gravity,
    );
  }
  
  /// Show an info toast with info icon
  static Future<bool?> showMaterialInfoToast({
    required String message,
    bool isLong = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    return showMaterialToast(
      message: message,
      icon: Icons.info,
      backgroundColor: AppColors.info,
      isLong: isLong,
      gravity: gravity,
    );
  }
  
  /// Show a warning toast with warning icon
  static Future<bool?> showMaterialWarningToast({
    required String message,
    bool isLong = false,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    return showMaterialToast(
      message: message,
      icon: Icons.warning,
      backgroundColor: AppColors.warning,
      isLong: isLong,
      gravity: gravity,
    );
  }
  
  //-------------------------------------------------------------------------
  // Loading Toast
  //-------------------------------------------------------------------------
  
  /// Show a loading toast with a spinner
  static FToast? _loadingToast;
  
  /// Show a loading indicator toast
  static void showLoadingToast({
    String message = 'Loading...',
    ToastGravity gravity = ToastGravity.CENTER,
    Color backgroundColor = AppColors.primary,
    Color textColor = Colors.white,
  }) {
    _loadingToast?.removeQueuedCustomToasts();
    
    Widget loadingToast = Container(
      padding: _defaultPadding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            message,
            style: _defaultTextStyle.copyWith(color: textColor),
          ),
        ],
      ),
    );
    
    _loadingToast = FToast().init(globalKey.currentContext!);
    _loadingToast!.showToast(
      child: loadingToast,
      gravity: gravity,
      toastDuration: const Duration(days: 1), // Effectively indefinite until dismissed
    );
  }
  
  /// Hide the loading toast
  static void hideLoadingToast() {
    _loadingToast?.removeQueuedCustomToasts();
    _loadingToast = null;
  }
  
  //-------------------------------------------------------------------------
  // App-Specific Toast Messages
  //-------------------------------------------------------------------------
  
  // Authentication messages
  static void showLoginSuccessToast() {
    showSuccessToast('Successfully logged in');
  }
  
  static void showLogoutSuccessToast() {
    showSuccessToast('Successfully logged out');
  }
  
  static void showSignUpSuccessToast() {
    showSuccessToast('Account created successfully');
  }
  
  static void showPasswordResetToast() {
    showSuccessToast('Password reset link sent to your email');
  }
  
  // Service-related messages
  static void showServiceCreatedToast() {
    showSuccessToast('Service created successfully');
  }
  
  static void showServiceUpdatedToast() {
    showSuccessToast('Service updated successfully');
  }
  
  static void showServiceDeletedToast() {
    showSuccessToast('Service deleted successfully');
  }
  
  // Booking-related messages
  static void showBookingCreatedToast() {
    showSuccessToast('Booking created successfully');
  }
  
  static void showBookingConfirmedToast() {
    showSuccessToast('Booking confirmed');
  }
  
  static void showBookingCancelledToast() {
    showInfoToast('Booking cancelled');
  }
  
  static void showBookingCompletedToast() {
    showSuccessToast('Service completed successfully');
  }
  
  // Profile-related messages
  static void showProfileUpdatedToast() {
    showSuccessToast('Profile updated successfully');
  }
  
  static void showPasswordChangedToast() {
    showSuccessToast('Password changed successfully');
  }
  
  // Rating-related messages
  static void showRatingSubmittedToast() {
    showSuccessToast('Rating submitted successfully');
  }
  
  // Network-related messages
  static void showNetworkErrorToast() {
    showErrorToast('Network error. Please check your connection');
  }
  
  static void showTimeoutErrorToast() {
    showErrorToast('Request timed out. Please try again');
  }
  
  // Generic messages
  static void showSavedToast() {
    showSuccessToast('Saved successfully');
  }
  
  static void showDeletedToast() {
    showSuccessToast('Deleted successfully');
  }
  
  static void showSomethingWentWrongToast() {
    showErrorToast('Something went wrong. Please try again');
  }
}

// Global key for accessing context for FToast
final GlobalKey globalKey = GlobalKey();