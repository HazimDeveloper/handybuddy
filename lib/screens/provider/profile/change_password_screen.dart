// lib/screens/provider/profile/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/utils/form_validators.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Clear error message
    setState(() {
      _errorMessage = null;
    });
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success) {
        if (mounted) {
          // Reset form fields
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          
          // Show success dialog
          SuccessDialog.show(
            context: context,
            title: 'Password Changed',
            message: 'Your password has been changed successfully.',
            buttonText: 'OK',
            onButtonPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile screen
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = authProvider.error ?? 'Failed to change password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Information text
              const Text(
                'Change your password',
                style: AppStyles.headingStyle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your current password and a new password to change your password.',
                style: AppStyles.bodyTextStyle,
              ),
              const SizedBox(height: 24),
              
              // Error message (if any)
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppStyles.bodyTextStyle.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Current password field
              TextInput(
                label: 'Current Password',
                controller: _currentPasswordController,
                obscureText: !_passwordVisible,
                validator: FormValidators.validateCurrentPassword,
                textInputAction: TextInputAction.next,
                prefix: const Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              
              // New password field
              TextInput(
                label: 'New Password',
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                validator: FormValidators.validatePassword,
                textInputAction: TextInputAction.next,
                prefix: const Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _newPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              
              // Password requirements
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password requirements:',
                      style: AppStyles.captionBoldStyle,
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementRow(
                      'At least 8 characters',
                      _newPasswordController.text.length >= 8,
                    ),
                    _buildRequirementRow(
                      'At least one uppercase letter',
                      _newPasswordController.text.contains(RegExp(r'[A-Z]')),
                    ),
                    _buildRequirementRow(
                      'At least one number',
                      _newPasswordController.text.contains(RegExp(r'[0-9]')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Confirm password field
              TextInput(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                validator: (value) => FormValidators.validatePasswordConfirmation(
                  value, 
                  _newPasswordController.text,
                ),
                textInputAction: TextInputAction.done,
                prefix: const Icon(
                  Icons.lock_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: custom_outlined.OutlinedButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      borderColor: AppColors.textSecondary,
                      textColor: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Change Password',
                      onPressed: _changePassword,
                      isLoading: _isLoading,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppColors.success : AppColors.textLight,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppStyles.captionStyle.copyWith(
              color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}