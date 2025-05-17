// lib/screens/common/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoggedIn = authProvider.isLoggedIn;
    final userType = authProvider.userType ?? 'seeker'; // Default to seeker if not specified
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppTexts.settings),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account settings
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Account',
                style: AppStyles.subheadingStyle,
              ),
            ),
            _buildSettingsCard(
              context,
              children: [
                if (isLoggedIn) ...[
                  _buildSettingsItem(
                    context,
                    icon: Icons.password,
                    title: AppTexts.changePassword,
                    onTap: () => _navigateToChangePassword(context, userType),
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.language,
                    title: AppTexts.language,
                    onTap: () => _navigateToLanguageSettings(context),
                  ),
                  const Divider(),
                  _buildSettingsItem(
                    context,
                    icon: Icons.delete_forever,
                    title: AppTexts.deleteAccount,
                    isDestructive: true,
                    onTap: () => _showDeleteAccountConfirmation(context, authProvider),
                  ),
                ] else ...[
                  _buildSettingsItem(
                    context,
                    icon: Icons.language,
                    title: AppTexts.language,
                    onTap: () => _navigateToLanguageSettings(context),
                  ),
                ],
              ],
            ),
            
            // App settings
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'App',
                style: AppStyles.subheadingStyle,
              ),
            ),
            _buildSettingsCard(
              context,
              children: [
                _buildSettingsItem(
                  context,
                  icon: Icons.notifications,
                  title: AppTexts.notification,
                  onTap: () {
                    ToastUtils.showInfoToast('Notifications settings coming soon');
                  },
                ),
                const Divider(),
                _buildSettingsItem(
                  context,
                  icon: Icons.info,
                  title: AppTexts.aboutUs,
                  onTap: () => _navigateToAboutUs(context),
                ),
                const Divider(),
                _buildSettingsItem(
                  context,
                  icon: Icons.contact_support,
                  title: AppTexts.contactUs,
                  onTap: () => _navigateToContactUs(context),
                ),
              ],
            ),
            
            // Version info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  AppTexts.appVersion,
                  style: AppStyles.captionStyle.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
            
            // Logout button (only if logged in)
            if (isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showLogoutConfirmation(context, authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(
                        AppTexts.logout,
                        style: AppStyles.bodyTextBoldStyle.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        children: children,
      ),
    );
  }
  
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppColors.errorBackground 
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppStyles.bodyTextStyle.copyWith(
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToChangePassword(BuildContext context, String userType) {
    final route = userType == 'provider' 
        ? Routes.providerChangePassword 
        : Routes.seekerChangePassword;
    Routes.navigateTo(context, route);
  }
  
  void _navigateToLanguageSettings(BuildContext context) {
    Routes.navigateTo(context, Routes.languageSettings);
  }
  
  void _navigateToAboutUs(BuildContext context) {
    Routes.navigateTo(context, Routes.aboutUs);
  }
  
  void _navigateToContactUs(BuildContext context) {
    Routes.navigateTo(context, Routes.contactUs);
  }
  
  Future<void> _showLogoutConfirmation(
    BuildContext context, 
    AuthProvider authProvider,
  ) async {
    final shouldLogout = await ConfirmDialog.showLogoutConfirmation(context);
    
    if (shouldLogout == true) {
      await authProvider.logout();
      ToastUtils.showSuccessToast('Successfully logged out');
      
      if (context.mounted) {
        Routes.navigateAndRemoveUntil(context, Routes.seekerLogin);
      }
    }
  }
  
  Future<void> _showDeleteAccountConfirmation(
    BuildContext context, 
    AuthProvider authProvider,
  ) async {
    final shouldDelete = await ConfirmDialog.showDeleteAccountConfirmation(context);
    
    if (shouldDelete == true) {
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleting account...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Delete account
      final success = await authProvider.deleteAccount(authProvider.userType ?? 'seeker');
      
      if (success) {
        ToastUtils.showSuccessToast('Account deleted successfully');
        
        if (context.mounted) {
          Routes.navigateAndRemoveUntil(context, Routes.seekerLogin);
        }
      } else {
        if (context.mounted) {
          ToastUtils.showErrorToast(
            authProvider.error ?? 'Failed to delete account',
          );
        }
      }
    }
  }
}