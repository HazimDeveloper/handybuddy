// lib/screens/common/contact_us_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Simulate sending message
    await Future.delayed(const Duration(seconds: 2));
    
    // Show success message
    if (mounted) {
      ToastUtils.showSuccessToast(AppTexts.messageSent);
      
      // Reset form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
      _formKey.currentState!.reset();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.contactUsTitle),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  AppTexts.getInTouch,
                  style: AppStyles.headingStyle,
                ),
                const SizedBox(height: 10),
                Text(
                  AppTexts.contactUsSubtitle,
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Contact Form
                TextInput(
                  label: AppTexts.yourName,
                  controller: _nameController,
                  validator: (value) => value?.isEmpty ?? true 
                      ? 'Please enter your name' 
                      : null,
                  prefix: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                
                EmailInput(
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                
                TextAreaInput(
                  label: AppTexts.message,
                  controller: _messageController,
                  validator: (value) => value?.isEmpty ?? true 
                      ? 'Please enter your message' 
                      : null,
                  maxLines: 6,
                ),
                const SizedBox(height: 30),
                
                // Send Button
                CustomButton(
                  text: AppTexts.sendMessage,
                  onPressed: _sendMessage,
                  isFullWidth: true,
                  isLoading: _isLoading,
                ),
                
                const SizedBox(height: 40),
                
                // Contact Information
                const Text(
                  AppTexts.contactInformation,
                  style: AppStyles.subheadingStyle,
                ),
                const SizedBox(height: 16),
                
                // Address
                _buildContactItem(
                  icon: Icons.location_on,
                  title: 'Address',
                  text: '123 Service Street, Selangor, Malaysia',
                ),
                const SizedBox(height: 12),
                
                // Phone
                _buildContactItem(
                  icon: Icons.phone,
                  title: 'Phone',
                  text: '+60 12 345 6789',
                ),
                const SizedBox(height: 12),
                
                // Email
                _buildContactItem(
                  icon: Icons.email,
                  title: 'Email',
                  text: 'support@handybuddy.com',
                ),
                const SizedBox(height: 12),
                
                // Business Hours
                _buildContactItem(
                  icon: Icons.access_time,
                  title: 'Business Hours',
                  text: 'Monday to Friday: 9:00 AM - 6:00 PM\nSaturday: 9:00 AM - 1:00 PM',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.bodyTextBoldStyle,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}