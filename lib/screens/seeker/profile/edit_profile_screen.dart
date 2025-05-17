// lib/screens/seeker/profile/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/utils/form_validators.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  
  bool _isLoading = false;
  File? _profileImage;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
  
  void _initializeUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _phoneController.text = user.phoneNumber ?? '';
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
  
  Future<void> _updateProfile() async {
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
      final success = await authProvider.updateProfile(
        phoneNumber: _phoneController.text.trim(),
        profileImage: _profileImage,
      );
      
      if (success) {
        if (mounted) {
          // Show success dialog
          SuccessDialog.showProfileUpdated(
            context: context,
            onButtonPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile screen
            },
          );
        }
      } else {
        setState(() {
          _errorMessage = authProvider.error ?? 'Failed to update profile';
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
    // Get user data from provider
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;
    
    if (user == null) {
      // User not logged in, redirect to login
      return const Scaffold(
        body: Center(
          child: Text('Please login to edit your profile'),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.editProfile),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image selector
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _profileImage != null 
                            ? FileImage(_profileImage!) 
                            : (user.profileImageUrl != null 
                                ? NetworkImage(user.profileImageUrl!) 
                                : null) as ImageProvider<Object>?,
                        child: (_profileImage == null && user.profileImageUrl == null)
                            ? Text(
                                user.initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 36,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
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
              
              // Personal Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Display Name (Read-only)
                    TextInput(
                      label: 'Name',
                      initialValue: user.fullName,
                      readOnly: true,
                      enabled: false,
                      prefix: const Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffix: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, 'edit_profile_name');
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email Address (Read-only)
                    TextInput(
                      label: 'Email',
                      initialValue: user.email,
                      readOnly: true,
                      enabled: false,
                      prefix: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Number
                    PhoneInput(
                      controller: _phoneController,
                      validator: FormValidators.validatePhoneNumber,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Additional Settings Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Settings',
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Change Password Option
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'change_password');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Change Password',
                                style: AppStyles.bodyTextStyle,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Divider(),
                    
                    // Delete Account Option
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'delete_account');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Delete Account',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _updateProfile,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}