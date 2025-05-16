// lib/screens/provider/auth/signup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';
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
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/inputs/text_input.dart';
class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({Key? key}) : super(key: key);

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  
  String _selectedCategory = '';
  File? _icImage;
  File? _resumeFile;
  File? _profileImage;
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'home_repairs', 'name': 'Home Repairs'},
    {'id': 'cleaning', 'name': 'Cleaning Service'},
    {'id': 'tutoring', 'name': 'Tutoring'},
    {'id': 'plumbing', 'name': 'Plumbing Services'},
    {'id': 'electrical', 'name': 'Electrical Services'},
    {'id': 'transport', 'name': 'Transport Helper'},
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickIC() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _icImage = File(image.path);
      });
    }
  }
  
  Future<void> _pickResume() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    
    if (file != null) {
      setState(() {
        _resumeFile = File(file.path);
      });
    }
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
  
  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    }
  }

  Future<void> _signUp() async {
    // Validate second step form
    if (!_formKey2.currentState!.validate()) {
      return;
    }
    
    // Validate required files
    if (_icImage == null) {
      ToastUtils.showErrorToast('Please upload your IC');
      return;
    }
    
    if (_resumeFile == null) {
      ToastUtils.showErrorToast('Please upload your Resume');
      return;
    }
    
    if (_selectedCategory.isEmpty) {
      ToastUtils.showErrorToast('Please select a service category');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUpProvider(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        category: _selectedCategory,
        icImage: _icImage!,
        resumeFile: _resumeFile!,
        profileImage: _profileImage,
      );

      if (success) {
        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
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
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: AppTexts.providerSignupSuccess,
        message: AppTexts.providerSignupSuccessMessage,
        buttonText: 'Get Started',
        onButtonPressed: () {
          Routes.navigateAndRemoveUntil(context, Routes.providerMain);
        },
      ),
    );
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
          _currentStep == 0 
              ? AppTexts.providerSignupTitle 
              : AppTexts.providerProfileSetup,
          style: AppStyles.headingMediumStyle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _currentStep == 0 
                ? _buildFirstStep() 
                : _buildSecondStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppTexts.providerSignupSubtitle,
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
          const SizedBox(height: 32),
          
          // Next Button
          CustomButton(
            text: AppTexts.next,
            onPressed: _nextStep,
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
                  Routes.navigateTo(context, Routes.providerLogin);
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
        ],
      ),
    );
  }

  Widget _buildSecondStep() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppTexts.providerProfileSetupSubtitle,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
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
          
          // Service Category Selection
          Text(
            AppTexts.selectServiceCategory,
            style: AppStyles.labelLargeStyle,
          ),
          const SizedBox(height: 12),
          
          // Categories Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final bool isSelected = _selectedCategory == category['id'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['id'];
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryLight 
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.borderLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(category['id']),
                        color: isSelected 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'],
                        style: AppStyles.captionStyle.copyWith(
                          color: isSelected 
                              ? AppColors.primary 
                              : AppColors.textPrimary,
                          fontWeight: isSelected 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Upload IC
          Text(
            AppTexts.uploadIC,
            style: AppStyles.labelLargeStyle,
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: _pickIC,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
                image: _icImage != null
                    ? DecorationImage(
                        image: FileImage(_icImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _icImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTexts.clickToUploadIC,
                          style: AppStyles.bodyTextStyle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          
          // Upload Resume
          Text(
            AppTexts.uploadResume,
            style: AppStyles.labelLargeStyle,
          ),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: _pickResume,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
                image: _resumeFile != null
                    ? DecorationImage(
                        image: FileImage(_resumeFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _resumeFile == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.upload_file,
                          color: AppColors.textSecondary,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppTexts.clickToUploadResume,
                          style: AppStyles.bodyTextStyle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: custom_outlined.OutlinedButton(
                  text: AppTexts.back,
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: AppTexts.signup,
                  onPressed: _signUp,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'home_repairs':
        return Icons.home_repair_service;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'tutoring':
        return Icons.school;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'transport':
        return Icons.local_shipping;
      default:
        return Icons.miscellaneous_services;
    }
  }
}