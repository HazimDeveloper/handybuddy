// lib/screens/seeker/auth/signup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/form_validators.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class SeekerSignupScreen extends StatefulWidget {
  const SeekerSignupScreen({Key? key}) : super(key: key);

  @override
  State<SeekerSignupScreen> createState() => _SeekerSignupScreenState();
}

class _SeekerSignupScreenState extends State<SeekerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  bool _acceptTerms = false;
  String? _errorMessage;
  File? _profileImage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _signUp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check terms acceptance
    if (!_acceptTerms) {
      ToastUtils.showErrorToast('Please accept the terms and conditions');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpSeeker(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profileImage: _profileImage,
      );

      if (success) {
        // Navigate to seeker main screen
        if (mounted) {
          ToastUtils.showSuccessToast('Account created successfully');
          Routes.navigateAndRemoveUntil(context, Routes.seekerMain);
        }
      } else {
        // Show error message
        setState(() {
          _errorMessage = authProvider.error ?? 'Signup failed. Please try again.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        title: Text(
          AppTexts.seekerSignupTitle,
          style: AppStyles.headingMediumStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppTexts.seekerSignupSubtitle,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile Image Picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.backgroundLight,
                            backgroundImage: _profileImage != null 
                                ? FileImage(_profileImage!) 
                                : null,
                            child: _profileImage == null
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                      child: Text(
                        _errorMessage!,
                        style: AppStyles.bodyTextStyle.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Personal Information Section
                  Text(
                    AppTexts.personalInformation,
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // First Name
                  TextInput(
                    label: AppTexts.firstName,
                    controller: _firstNameController,
                    validator: FormValidators.validateFirstName,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    prefix: const Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextInput(
                    label: AppTexts.lastName,
                    controller: _lastNameController,
                    validator: FormValidators.validateLastName,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    prefix: const Icon(
                      Icons.person_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Number
                  PhoneInput(
                    controller: _phoneController,
                    validator: FormValidators.validatePhoneNumber,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  
                  // Account Information Section
                  Text(
                    AppTexts.accountInformation,
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  EmailInput(
                    controller: _emailController,
                    validator: FormValidators.validateEmail,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password
                  PasswordInput(
                    controller: _passwordController,
                    validator: FormValidators.validatePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password
                  TextInput(
                    label: AppTexts.confirmPassword,
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) => FormValidators.validatePasswordConfirmation(
                      value, 
                      _passwordController.text
                    ),
                    textInputAction: TextInputAction.done,
                    prefix: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Text(
                              AppTexts.termsAndConditionsAgree,
                              style: AppStyles.bodyTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign Up Button
                  CustomButton(
                    text: AppTexts.signup,
                    onPressed: _signUp,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTexts.alreadyHaveAccount,
                        style: AppStyles.bodyTextStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Routes.navigateTo(context, Routes.seekerLogin);
                        },
                        child: Text(
                          AppTexts.login,
                          style: AppStyles.bodyTextBoldStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Already have account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppTexts.alreadyHaveAccount,
                        style: AppStyles.bodyTextStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Routes.navigateTo(context, Routes.seekerLogin);
                        },
                        child: Text(
                          AppTexts.login,
                          style: AppStyles.bodyTextBoldStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Become provider info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.becomeProvider,
                          style: AppStyles.subheadingStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTexts.becomeProviderSubtitle,
                          style: AppStyles.bodyTextStyle,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: AppTexts.becomeProviderButton,
                          onPressed: () {
                            Routes.navigateTo(context, Routes.providerWelcome);
                          },
                          backgroundColor: AppColors.primary,
                          isFullWidth: true,
                        ),
                      ],
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