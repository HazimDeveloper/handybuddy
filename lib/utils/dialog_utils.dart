import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../constants/app_texts.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/buttons/outlined_button.dart' as custom_outlined;

class DialogUtils {
  // Prevent instantiation
  DialogUtils._();
  
  // Standard alert dialog
  static Future<bool?> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmButtonText,
    String? cancelButtonText,
    bool showCancelButton = true,
    bool barrierDismissible = true,
    Color? confirmButtonColor,
    IconData? icon,
    Color? iconColor,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: iconColor ?? AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            if (showCancelButton)
              custom_outlined.OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                text: cancelButtonText ?? AppTexts.cancel,
              ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: confirmButtonText ?? AppTexts.confirm,
              backgroundColor: confirmButtonColor ?? AppColors.primary,
            ),
          ],
        );
      },
    );
  }
  
  // Loading dialog
  static Future<void> showLoadingDialog({
    required BuildContext context,
    String message = 'Please wait...',
    bool barrierDismissible = false,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppStyles.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Success dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) {
                  onDismiss();
                }
              },
              text: buttonText,
              backgroundColor: AppColors.success,
            ),
          ],
        );
      },
    );
  }
  
  // Error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.error,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: buttonText,
              backgroundColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
  
  // Confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmButtonText = 'Yes',
    String cancelButtonText = 'No',
    Color confirmButtonColor = AppColors.primary,
    bool isDestructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isDestructive ? Icons.warning : Icons.help,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            custom_outlined.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              text: cancelButtonText,
            ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: confirmButtonText,
              backgroundColor: isDestructive ? AppColors.error : confirmButtonColor,
            ),
          ],
        );
      },
    );
  }
  
  // Logout confirmation dialog
  static Future<bool?> showLogoutConfirmationDialog({
    required BuildContext context,
  }) async {
    return showConfirmationDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to log out of your account?',
      confirmButtonText: 'Logout',
      cancelButtonText: 'Cancel',
      confirmButtonColor: AppColors.primary,
      isDestructive: false,
    );
  }
  
  // Delete account confirmation dialog
  static Future<bool?> showDeleteAccountConfirmationDialog({
    required BuildContext context,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.error,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: const Text(
            'This action is permanent and cannot be undone. All your data, including bookings and services, will be permanently deleted.\n\nAre you sure you want to delete your account?',
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            custom_outlined.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              text: 'Cancel',
            ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              text: 'Delete Account',
              backgroundColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
  
  // Booking cancellation dialog
  static Future<String?> showBookingCancellationDialog({
    required BuildContext context,
  }) async {
    final TextEditingController _reasonController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.cancel,
                color: AppColors.error,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cancel Booking',
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide a reason for cancellation:',
                style: AppStyles.bodyTextStyle,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  hintText: 'Enter reason',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            custom_outlined.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              text: 'Cancel',
            ),
            CustomButton(
              onPressed: () {
                if (_reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please provide a reason for cancellation.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(_reasonController.text.trim());
              },
              text: 'Confirm Cancellation',
              backgroundColor: AppColors.error,
            ),
          ],
        );
      },
    );
  }
  
  // Rating dialog
  static Future<Map<String, dynamic>?> showRatingDialog({
    required BuildContext context,
    required String providerName,
  }) async {
    double _rating = 5.0;
    final TextEditingController _reviewController = TextEditingController();
    
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rate Service',
                      style: AppStyles.headingStyle,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How would you rate the service provided by $providerName?',
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating.floor()
                                ? Icons.star
                                : (index < _rating ? Icons.star_half : Icons.star_border),
                            color: AppColors.warning,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _rating.toString(),
                      style: AppStyles.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Share your experience (optional):',
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      hintText: 'Write your review here',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: <Widget>[
                custom_outlined.OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  text: 'Cancel',
                ),
                CustomButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'rating': _rating,
                      'review': _reviewController.text.trim(),
                    });
                  },
                  text: 'Submit Rating',
                  backgroundColor: AppColors.primary,
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Bottom sheet for selecting options
  static Future<T?> showOptionsBottomSheet<T>({
    required BuildContext context,
    required String title,
    required List<Map<String, dynamic>> options,
  }) async {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppStyles.headingStyle,
              ),
              const SizedBox(height: 16),
              ...options.map((option) => ListTile(
                leading: Icon(
                  option['icon'] as IconData,
                  color: option['color'] as Color? ?? AppColors.primary,
                ),
                title: Text(
                  option['title'] as String,
                  style: AppStyles.subheadingStyle,
                ),
                onTap: () {
                  Navigator.of(context).pop(option['value'] as T);
                },
              )),
            ],
          ),
        );
      },
    );
  }
  
  // Date picker dialog
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? now,
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
  }
  
  // Time picker dialog
  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
  }
  
  // Full screen dialog
  static Future<T?> showFullScreenDialog<T>({
    required BuildContext context,
    required Widget child,
    String title = '',
    bool showAppBar = true,
  }) async {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          appBar: showAppBar
              ? AppBar(
                  title: Text(title),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                )
              : null,
          body: child,
        ),
      ),
    );
  }
  
  // Custom content dialog
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget content,
    bool barrierDismissible = true,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: content,
        );
      },
    );
  }
  
  // Booking successful dialog
  static Future<void> showBookingSuccessDialog({
    required BuildContext context,
    required String bookingId,
    required VoidCallback onViewBooking,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Booking Successful',
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your booking has been successfully created!',
                style: AppStyles.bodyTextStyle,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Booking ID: ',
                    style: AppStyles.labelStyle,
                  ),
                  Text(
                    bookingId,
                    style: AppStyles.bodyTextStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'You will be notified when the service provider accepts your booking.',
                style: AppStyles.bodyTextStyle,
              ),
            ],
          ),
          actions: <Widget>[
            custom_outlined.OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Close',
            ),
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
                onViewBooking();
              },
              text: 'View Booking',
              backgroundColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
  
  // Service provider registration success dialog
  static Future<void> showProviderRegistrationSuccessDialog({
    required BuildContext context,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Registration Successful',
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Congratulations! You are now registered as a service provider.',
                style: AppStyles.bodyTextStyle,
              ),
              SizedBox(height: 16),
              Text(
                'Your account is being verified by our team. You will be notified once the verification is complete.',
                style: AppStyles.bodyTextStyle,
              ),
              SizedBox(height: 16),
              Text(
                'In the meantime, you can set up your profile and add your services.',
                style: AppStyles.bodyTextStyle,
              ),
            ],
          ),
          actions: <Widget>[
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Get Started',
              backgroundColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
  
  // Profile updated success dialog
  static Future<void> showProfileUpdatedDialog({
    required BuildContext context,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 28,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Profile Updated',
                  style: AppStyles.headingStyle,
                ),
              ),
            ],
          ),
          content: const Text(
            'Your profile has been successfully updated.',
            style: AppStyles.bodyTextStyle,
          ),
          actions: <Widget>[
            CustomButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'OK',
              backgroundColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
  
  // Image preview dialog
  static Future<void> showImagePreviewDialog({
    required BuildContext context,
    required String imageUrl,
    String title = 'Image Preview',
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AppStyles.subheadingStyle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Failed to load image'),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}