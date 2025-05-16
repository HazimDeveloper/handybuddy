// lib/widgets/dialogs/success_dialog.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final bool barrierDismissible;
  final Widget? customContent;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.barrierDismissible = false,
    this.customContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => barrierDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.successBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                title,
                style: AppStyles.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Message
              Text(
                message,
                style: AppStyles.bodyTextStyle,
                textAlign: TextAlign.center,
              ),
              
              // Custom content (if provided)
              if (customContent != null) ...[
                const SizedBox(height: 16),
                customContent!,
              ],
              
              const SizedBox(height: 24),
              
              // Primary Button
              CustomButton(
                text: buttonText,
                onPressed: onButtonPressed,
                backgroundColor: AppColors.success,
                isFullWidth: true,
              ),
              
              // Secondary Button (if provided)
              if (secondaryButtonText != null && onSecondaryButtonPressed != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onSecondaryButtonPressed,
                  child: Text(
                    secondaryButtonText!,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onButtonPressed,
    String? secondaryButtonText,
    VoidCallback? onSecondaryButtonPressed,
    bool barrierDismissible = false,
    Widget? customContent,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onButtonPressed: onButtonPressed,
          secondaryButtonText: secondaryButtonText,
          onSecondaryButtonPressed: onSecondaryButtonPressed,
          barrierDismissible: barrierDismissible,
          customContent: customContent,
        );
      },
    );
  }

  // Common success dialog for account creation
  static Future<void> showAccountCreated({
    required BuildContext context,
    required VoidCallback onButtonPressed,
  }) {
    return show(
      context: context,
      title: 'Account Created',
      message: 'Your account has been created successfully.',
      buttonText: 'Get Started',
      onButtonPressed: onButtonPressed,
    );
  }

  // Common success dialog for profile updates
  static Future<void> showProfileUpdated({
    required BuildContext context,
    VoidCallback? onButtonPressed,
  }) {
    return show(
      context: context,
      title: 'Profile Updated',
      message: 'Your profile has been updated successfully.',
      buttonText: 'OK',
      onButtonPressed: onButtonPressed ?? () => Navigator.of(context).pop(),
    );
  }

  // Common success dialog for booking confirmation
  static Future<void> showBookingConfirmed({
    required BuildContext context,
    required String bookingId,
    required VoidCallback onViewBooking,
  }) {
    return show(
      context: context,
      title: 'Booking Confirmed',
      message: 'Your booking has been confirmed successfully.',
      buttonText: 'View Booking',
      onButtonPressed: onViewBooking,
      secondaryButtonText: 'Close',
      onSecondaryButtonPressed: () => Navigator.of(context).pop(),
      customContent: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Text(
              'Booking ID: ',
              style: AppStyles.labelStyle,
            ),
            Text(
              bookingId,
              style: AppStyles.bodyTextBoldStyle,
            ),
          ],
        ),
      ),
    );
  }

  // Common success dialog for payment completed
  static Future<void> showPaymentCompleted({
    required BuildContext context,
    required VoidCallback onViewBooking,
  }) {
    return show(
      context: context,
      title: 'Payment Successful',
      message: 'Your payment has been processed successfully.',
      buttonText: 'View Booking',
      onButtonPressed: onViewBooking,
      secondaryButtonText: 'Back to Home',
      onSecondaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }

  // Common success dialog for service completed
  static Future<void> showServiceCompleted({
    required BuildContext context,
    required VoidCallback onRateService,
  }) {
    return show(
      context: context,
      title: 'Service Completed',
      message: 'The service has been marked as completed.',
      buttonText: 'Rate Service',
      onButtonPressed: onRateService,
      secondaryButtonText: 'Later',
      onSecondaryButtonPressed: () => Navigator.of(context).pop(),
    );
  }
}