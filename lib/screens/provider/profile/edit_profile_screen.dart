// lib/screens/provider/profile/edit_profile_screen.dart
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
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
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
  final _bioController = TextEditingController();
  
  UserModel? _provider;
  bool _isLoading = false;
  String? _selectedCategory;
  List<String> _selectedSkills = [];
  File? _profileImage;
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'home_repairs', 'name': 'Home Repairs'},
    {'id': 'cleaning', 'name': 'Cleaning Service'},
    {'id': 'tutoring', 'name': 'Tutoring'},
    {'id': 'plumbing', 'name': 'Plumbing Services'},
    {'id': 'electrical', 'name': 'Electrical Services'},
    {'id': 'transport', 'name': 'Transport Helper'},
  ];
  
  final List<String> _skillsList = [
    'Plumbing', 'Electrical', 'Carpentry', 'Painting', 'Flooring',
    'Cleaning', 'Tutoring', 'Mathematics', 'Science', 'English',
    'Driving', 'Moving', 'Assembly', 'Installation', 'Repair',
    'Gardening', 'Landscaping', 'Pet Care', 'Childcare', 'Cooking',
    'Delivery', 'Computer Repair', 'Phone Repair', 'Web Design', 'App Development',
  ];

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }
  
  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProviderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _provider = authProvider.user;
      
      if (_provider != null) {
        // Initialize fields with current user data
        _phoneController.text = _provider!.phoneNumber ?? '';
        _bioController.text = _provider!.bio ?? '';
        _selectedCategory = _provider!.category;
        
        if (_provider!.skills != null) {
          _selectedSkills = List<String>.from(_provider!.skills!);
        }
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to load profile data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
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

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ToastUtils.showErrorToast('Please select a service category');
      return;
    }
    
    if (_selectedSkills.isEmpty) {
      ToastUtils.showErrorToast('Please select at least one skill');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateProfile(
        phoneNumber: _phoneController.text,
        bio: _bioController.text,
        category: _selectedCategory,
        skills: _selectedSkills,
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
        ToastUtils.showErrorToast(authProvider.error ?? 'Failed to update profile');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error updating profile: ${e.toString()}');
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
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image
                    Center(
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.backgroundLight,
                              backgroundImage: _profileImage != null 
                                  ? FileImage(_profileImage!) 
                                  : (_provider?.profileImageUrl != null && 
                                     _provider!.profileImageUrl!.isNotEmpty)
                                      ? NetworkImage(_provider!.profileImageUrl!)
                                      : null,
                              child: _profileImage == null && 
                                    (_provider?.profileImageUrl == null || 
                                     _provider!.profileImageUrl!.isEmpty)
                                  ? Text(
                                      _provider?.initials ?? 'HB',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
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
                    
                    // Personal Information
                    const Text(
                      'Personal Information',
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Provider Name (Read-only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Name',
                                  style: AppStyles.labelStyle,
                                ),
                                Text(
                                  _provider?.fullName ?? 'Provider Name',
                                  style: AppStyles.bodyTextStyle,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/provider/edit-profile-name');
                            },
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Number
                    PhoneInput(
                      controller: _phoneController,
                      validator: FormValidators.validatePhoneNumber,
                    ),
                    const SizedBox(height: 24),
                    
                    // Professional Information
                    const Text(
                      'Professional Information',
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Service Category
                    Text(
                      'Service Category',
                      style: AppStyles.labelStyle,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((category) {
                        final bool isSelected = _selectedCategory == category['id'];
                        
                        return FilterChip(
                          label: Text(category['name']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category['id'] : null;
                            });
                          },
                          backgroundColor: AppColors.backgroundLight,
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Skills
                    Text(
                      'Skills (Select all that apply)',
                      style: AppStyles.labelStyle,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skillsList.map((skill) {
                        final bool isSelected = _selectedSkills.contains(skill);
                        
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (_) => _toggleSkill(skill),
                          backgroundColor: AppColors.backgroundLight,
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Bio
                    TextAreaInput(
                      label: 'Bio',
                      controller: _bioController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        }
                        
                        if (value.length < 50) {
                          return 'Bio should be at least 50 characters';
                        }
                        
                        return null;
                      },
                      hint: 'Tell clients about yourself, your experience, and the services you offer',
                      maxLength: 500,
                    ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
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
                            text: 'Save',
                            onPressed: _saveProfile,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}