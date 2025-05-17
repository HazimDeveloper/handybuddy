// lib/screens/provider/profile/provider_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  bool _isLoading = false;
  UserModel? _provider;
  bool _availableForWork = true;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _provider = authProvider.user;
      
      if (_provider != null) {
        _availableForWork = _provider!.availableForWork ?? true;
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to load profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAvailability() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Use the updateProfile method to toggle availableForWork
    final success = await authProvider.updateProfile(
      availableForWork: !_availableForWork,
    );

    if (success) {
      setState(() {
        _availableForWork = !_availableForWork;
      });
      
      ToastUtils.showSuccessToast(
        _availableForWork 
            ? 'You are now available for work' 
            : 'You are now unavailable for work'
      );
      
      // Reload provider data
      await _loadProviderData();
    } else {
      ToastUtils.showErrorToast('Failed to update availability');
    }
  } catch (e) {
    ToastUtils.showErrorToast('Error updating availability: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _logout() async {
    final confirmed = await ConfirmDialog.showLogoutConfirmation(context);
    
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      // Navigate to welcome screen
      if (mounted) {
        Routes.navigateAndRemoveUntil(context, Routes.providerWelcome);
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error logging out: ${e.toString()}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToEditProfile() {
    Routes.navigateTo(context, Routes.providerEditProfile);
  }

  void _navigateToEditProfileName() {
    Routes.navigateTo(context, Routes.providerEditProfileName);
  }

  void _navigateToChangePassword() {
    Routes.navigateTo(context, Routes.providerChangePassword);
  }

  void _navigateToSettings() {
    Routes.navigateTo(context, Routes.settings);
  }

  void _navigateToContactUs() {
    Routes.navigateTo(context, Routes.contactUs);
  }

  void _navigateToAboutUs() {
    Routes.navigateTo(context, Routes.aboutUs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProviderData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(),
                    
                    // Profile Actions
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Account Section
                          _buildSectionHeader('Account'),
                          _buildListItem(
                            icon: Icons.person,
                            title: 'Edit Profile Name',
                            onTap: _navigateToEditProfileName,
                          ),
                          _buildListItem(
                            icon: Icons.edit,
                            title: 'Edit Profile',
                            onTap: _navigateToEditProfile,
                          ),
                          _buildListItem(
                            icon: Icons.lock,
                            title: 'Change Password',
                            onTap: _navigateToChangePassword,
                          ),
                          _buildListItem(
                            icon: Icons.work,
                            title: 'Availability',
                            onTap: _toggleAvailability,
                            trailing: Switch(
                              value: _availableForWork,
                              onChanged: (_) => _toggleAvailability(),
                              activeColor: AppColors.primary,
                            ),
                          ),
                          const Divider(),
                          
                          // Preferences Section
                          _buildSectionHeader('Preferences'),
                          _buildListItem(
                            icon: Icons.settings,
                            title: 'Settings',
                            onTap: _navigateToSettings,
                          ),
                          _buildListItem(
                            icon: Icons.language,
                            title: 'Language',
                            subtitle: 'English',
                            onTap: () => Routes.navigateTo(context, Routes.languageSettings),
                          ),
                          const Divider(),
                          
                          // Support Section
                          _buildSectionHeader('Support'),
                          _buildListItem(
                            icon: Icons.contact_support,
                            title: 'Contact Us',
                            onTap: _navigateToContactUs,
                          ),
                          _buildListItem(
                            icon: Icons.info,
                            title: 'About Us',
                            onTap: _navigateToAboutUs,
                          ),
                          const Divider(),
                          
                          // Logout
                          const SizedBox(height: 24),
                          custom_outlined.OutlinedButton(
                            text: AppTexts.logout,
                            onPressed: _logout,
                            borderColor: AppColors.error,
                            textColor: AppColors.error,
                            prefixIcon: Icons.logout,
                            isFullWidth: true,
                          ),
                          
                          // App Version
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              AppTexts.appVersion,
                              style: AppStyles.captionStyle.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              image: _provider?.profileImageUrl != null && 
                      _provider!.profileImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_provider!.profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _provider?.profileImageUrl == null || 
                    _provider!.profileImageUrl!.isEmpty
                ? Center(
                    child: Text(
                      _provider?.initials ?? 'HB',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          
          // Provider Name
          Text(
            _provider?.fullName ?? 'Service Provider',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Provider Email
          Text(
            _provider?.email ?? 'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          
          // Provider Category
          if (_provider?.category != null && _provider!.category!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _provider!.formattedCategory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          const SizedBox(height: 16),
          
          // Provider Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Rating
              _buildStatItem(
                value: _provider?.formattedRating ?? 'New',
                label: 'Rating',
              ),
              
              // Verification Status
              _buildStatItem(
                value: _provider?.verificationStatus ?? 'Pending',
                label: 'Status',
              ),
              
              // Experience Level
              _buildStatItem(
                value: _provider?.experienceLevel ?? 'New',
                label: 'Experience',
              ),
              
              // Success Rate
              _buildStatItem(
                value: _provider?.successRate ?? 'New',
                label: 'Success Rate',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Edit Profile Button
          CustomButton(
            text: 'Edit Profile',
            onPressed: _navigateToEditProfile,
            backgroundColor: Colors.white,
            textColor: AppColors.primary,
            prefixIcon: Icons.edit,
            borderRadius: 30,
            height: 45,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: AppStyles.subheadingStyle.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: AppStyles.bodyTextStyle,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppStyles.captionStyle,
            )
          : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}