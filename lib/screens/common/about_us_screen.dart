// lib/screens/common/about_us_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.aboutUsTitle),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo and App Name
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppTexts.appName,
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTexts.appTagline,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppTexts.appVersion,
                    style: AppStyles.captionStyle,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Our Mission Section
            _buildInfoSection(
              title: AppTexts.ourMission,
              content: AppTexts.ourMissionText,
              icon: Icons.flag,
            ),
            
            const SizedBox(height: 24),
            
            // Who We Are Section
            _buildInfoSection(
              title: AppTexts.whoWeAre,
              content: AppTexts.whoWeAreText,
              icon: Icons.people,
            ),
            
            const SizedBox(height: 24),
            
            // How It Works Section
            _buildInfoSection(
              title: AppTexts.howItWorks,
              content: AppTexts.howItWorksText,
              icon: Icons.work,
            ),
            
            const SizedBox(height: 24),
            
            // Our Values Section
            _buildInfoSection(
              title: AppTexts.ourValues,
              content: AppTexts.ourValuesText,
              icon: Icons.star,
              isValuesList: true,
            ),
            
            const SizedBox(height: 32),
            
            // Contact Info
            Center(
              child: Column(
                children: [
                  const Text(
                    'Connect with us',
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        icon: Icons.language,
                        onTap: () {
                          // Open website
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.email,
                        onTap: () {
                          // Open email
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.facebook,
                        onTap: () {
                          // Open Facebook
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildSocialButton(
                        icon: Icons.install_mobile,
                        onTap: () {
                          // Open Instagram
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Copyright Info
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '© ${DateTime.now().year} Handy Buddy. All rights reserved.',
                  style: AppStyles.captionStyle,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    bool isValuesList = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppStyles.subheadingStyle,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isValuesList) ...[
            // Parse values list from text
            ...content.split('\n').map((value) {
              if (value.trim().isEmpty) return const SizedBox.shrink();
              
              final parts = value.split(':');
              if (parts.length > 1) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${parts[0]}:',
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          parts[1].trim(),
                          style: AppStyles.bodyTextStyle,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                      Expanded(
                        child: Text(
                          value.trim(),
                          style: AppStyles.bodyTextStyle,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }).toList(),
          ] else ...[
            Text(
              content,
              style: AppStyles.bodyTextStyle,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}