// lib/screens/provider/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;

class ProviderWelcomeScreen extends StatelessWidget {
  const ProviderWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo and App Name
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 150,
                  height: 150,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                AppTexts.appName,
                style: AppStyles.headingLargeStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                AppTexts.appTagline,
                style: AppStyles.subheadingStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Welcome Provider Section
              Text(
                AppTexts.providerWelcomeTitle,
                style: AppStyles.headingStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              Text(
                AppTexts.providerWelcomeSubtitle,
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Login Button
              CustomButton(
                text: AppTexts.login,
                onPressed: () {
                  Routes.navigateTo(context, Routes.providerLogin);
                },
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
              
              // Sign Up Button
              custom_outlined.OutlinedButton(
                text: AppTexts.signup,
                onPressed: () {
                  Routes.navigateTo(context, Routes.providerSignup);
                },
                isFullWidth: true,
              ),
              const SizedBox(height: 32),
              
              // Switch to Seeker Mode
              TextButton(
                onPressed: () {
                  Routes.navigateTo(context, Routes.seekerLogin);
                },
                child: Text(
                  'Are you looking for services? Login as a Service Seeker',
                  style: AppStyles.bodyTextStyle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}