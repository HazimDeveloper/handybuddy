// lib/screens/seeker/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/form_validators.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class SeekerLoginScreen extends StatefulWidget {
  const SeekerLoginScreen({Key? key}) : super(key: key);

  @override
  State<SeekerLoginScreen> createState() => _SeekerLoginScreenState();
}

class _SeekerLoginScreenState extends State<SeekerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: 'seeker',
      );

      if (success) {
        // Navigate to seeker main screen
        if (mounted) {
          Routes.navigateAndRemoveUntil(context, Routes.seekerMain);
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = authProvider.error ?? 'Login failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _forgotPassword() {
    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ToastUtils.showErrorToast('Please enter your email address');
      return;
    }

    final emailError = FormValidators.validateEmail(email);
    if (emailError != null) {
      ToastUtils.showErrorToast(emailError);
      return;
    }

    // Request password reset
    Provider.of<AuthProvider>(context, listen: false)
        .resetPassword(email)
        .then((success) {
      if (success) {
        ToastUtils.showSuccessToast(
            'Password reset link sent to your email');
      } else {
        ToastUtils.showErrorToast(
            Provider.of<AuthProvider>(context, listen: false).error ??
                'Failed to send reset link');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo and Title
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    AppTexts.seekerLoginTitle,
                    style: AppStyles.headingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    AppTexts.seekerLoginSubtitle,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Error message (if any)
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email Input
                  EmailInput(
                    controller: _emailController,
                    validator: FormValidators.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Input
                  PasswordInput(
                    controller: _passwordController,
                    validator: FormValidators.validateLoginPassword,
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 8),
                  
                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          Text(
                            'Remember Me',
                            style: AppStyles.bodySmallStyle,
                          ),
                        ],
                      ),
                      
                      // Forgot Password
                      TextButton(
                        onPressed: _forgotPassword,
                        child: Text(
                          AppTexts.forgotPassword,
                          style: AppStyles.bodySmallStyle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Login Button
                  CustomButton(
                    text: AppTexts.login,
                    onPressed: _login,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Don't have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTexts.dontHaveAccount,
                        style: AppStyles.bodyTextStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Routes.navigateTo(context, Routes.seekerSignup);
                        },
                        child: Text(
                          AppTexts.signup,
                          style: AppStyles.bodyTextBoldStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Become a provider
                  TextButton(
                    onPressed: () {
                      Routes.navigateTo(context, Routes.providerWelcome);
                    },
                    child: Text(
                      AppTexts.becomeProvider,
                      style: AppStyles.bodyTextStyle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}