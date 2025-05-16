import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color confirmButtonColor;
  final IconData? icon;
  final bool isDestructive;
  final bool showCancelButton;
  final Widget? customContent;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmButtonText = AppTexts.confirm,
    this.cancelButtonText = AppTexts.cancel,
    required this.onConfirm,
    required this.onCancel,
    this.confirmButtonColor = AppColors.primary,
    this.icon,
    this.isDestructive = false,
    this.showCancelButton = true,
    this.customContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine icon and color based on destructive action
    final IconData effectiveIcon = icon ?? (isDestructive ? Icons.warning : Icons.help_outline);
    final Color effectiveColor = isDestructive ? AppColors.error : confirmButtonColor;
    final Color iconColor = isDestructive ? AppColors.error : AppColors.primary;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context, effectiveIcon, iconColor, effectiveColor),
    );
  }

  Widget _buildDialogContent(BuildContext context, IconData effectiveIcon, Color iconColor, Color effectiveColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Dialog Header with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  effectiveIcon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppStyles.headingMediumStyle,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Dialog Message
          customContent ?? Text(
            message,
            style: AppStyles.bodyTextStyle,
            textAlign: TextAlign.left,
          ),
          
          const SizedBox(height: 24),
          
          // Dialog Actions
          Row(
            children: [
              // Cancel Button
              if (showCancelButton)
                Expanded(
                  child: custom_outlined.OutlinedButton(
                    text: cancelButtonText,
                    onPressed: onCancel,
                    isFullWidth: true,
                    height: 48,
                  ),
                ),
              
              // Spacing between buttons
              if (showCancelButton)
                const SizedBox(width: 12),
              
              // Confirm Button
              Expanded(
                child: CustomButton(
                  text: confirmButtonText,
                  onPressed: onConfirm,
                  backgroundColor: effectiveColor,
                  isFullWidth: true,
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Static method to show a standard confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmButtonText = AppTexts.confirm,
    String cancelButtonText = AppTexts.cancel,
    Color confirmButtonColor = AppColors.primary,
    IconData? icon,
    bool isDestructive = false,
    bool showCancelButton = true,
    Widget? customContent,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConfirmDialog(
          title: title,
          message: message,
          confirmButtonText: confirmButtonText,
          cancelButtonText: cancelButtonText,
          onConfirm: () {
            Navigator.of(context).pop(true);
          },
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          confirmButtonColor: confirmButtonColor,
          icon: icon,
          isDestructive: isDestructive,
          showCancelButton: showCancelButton,
          customContent: customContent,
        );
      },
    );
  }

  // Static methods for common confirmation dialogs

  // Logout confirmation
  static Future<bool?> showLogoutConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Logout',
      message: AppTexts.logoutConfirm,
      confirmButtonText: AppTexts.logout,
      icon: Icons.exit_to_app,
    );
  }

  // Delete account confirmation
  static Future<bool?> showDeleteAccountConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Delete Account',
      message: AppTexts.deleteAccountConfirm,
      confirmButtonText: AppTexts.deleteAccount,
      confirmButtonColor: AppColors.error,
      icon: Icons.delete_forever,
      isDestructive: true,
    );
  }

  // Cancel booking confirmation
  static Future<bool?> showCancelBookingConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Cancel Booking',
      message: AppTexts.cancelBookingConfirm,
      confirmButtonText: AppTexts.cancelBooking,
      confirmButtonColor: AppColors.error,
      icon: Icons.cancel,
      isDestructive: true,
    );
  }

  // Complete booking confirmation
  static Future<bool?> showCompleteBookingConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Complete Booking',
      message: AppTexts.completeBookingConfirm,
      confirmButtonText: AppTexts.completeBooking,
      confirmButtonColor: AppColors.success,
      icon: Icons.check_circle,
    );
  }

  // Delete service confirmation
  static Future<bool?> showDeleteServiceConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Delete Service',
      message: AppTexts.deleteServiceConfirm,
      confirmButtonText: AppTexts.delete,
      confirmButtonColor: AppColors.error,
      icon: Icons.delete,
      isDestructive: true,
    );
  }

  // Custom confirmation with text input
  static Future<String?> showInputConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    required String hintText,
    String confirmButtonText = AppTexts.confirm,
    String cancelButtonText = AppTexts.cancel,
    bool isDestructive = false,
    required String Function(String?) validator,
  }) {
    TextEditingController textController = TextEditingController();
    String? errorText;
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmDialog(
              title: title,
              message: message,
              confirmButtonText: confirmButtonText,
              cancelButtonText: cancelButtonText,
              onConfirm: () {
                final validationResult = validator(textController.text);
                if (validationResult == null) {
                  Navigator.of(context).pop(textController.text);
                } else {
                  setState(() {
                    errorText = validationResult;
                  });
                }
              },
              onCancel: () {
                Navigator.of(context).pop(null);
              },
              confirmButtonColor: isDestructive ? AppColors.error : AppColors.primary,
              icon: isDestructive ? Icons.warning : null,
              isDestructive: isDestructive,
              customContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: hintText,
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setState(() {
                          errorText = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}