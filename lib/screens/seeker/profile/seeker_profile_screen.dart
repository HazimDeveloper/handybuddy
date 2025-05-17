// lib/screens/seeker/profile/seeker_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/dialog_utils.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;

class SeekerProfileScreen extends StatefulWidget {
  const SeekerProfileScreen({Key? key}) : super(key: key);

  @override
  State<SeekerProfileScreen> createState() => _SeekerProfileScreenState();
}

class _SeekerProfileScreenState extends State<SeekerProfileScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _refreshUserData();
  }
  
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await Provider.of<AuthProvider>(context, listen: false).refreshUserData();
    } catch (e) {
      ToastUtils.showErrorToast('Error refreshing user data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _navigateToEditProfile() {
    Routes.navigateTo(context, Routes.seekerEditProfile);
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
  
  void _showLogoutConfirmation() {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Logout',
      message: AppTexts.logoutConfirm,
      confirmButtonText: AppTexts.logout,
      isDestructive: false,
    ).then((confirmed) {
      if (confirmed == true) {
        _logout();
      }
    });
  }
  
  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.logout();
      
      if (success && mounted) {
        // Navigate to login screen
        Routes.navigateAndRemoveUntil(context, Routes.seekerLogin);
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error logging out: ${e.toString()}');
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
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (user == null) {
      // User not logged in
      return _buildNotLoggedInView();
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.myProfile),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              
              // Profile Info Section
              _buildInfoSection(
                title: 'Personal Information',
                items: [
                  {
                    'icon': Icons.email_outlined,
                    'title': 'Email',
                    'value': user.email,
                  },
                  if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                    {
                      'icon': Icons.phone_outlined,
                      'title': 'Phone Number',
                      'value': user.phoneNumber!,
                    },
                  {
                    'icon': Icons.calendar_today_outlined,
                    'title': 'Joined',
                    'value': user.joinedDate,
                  },
                ],
              ),
              const SizedBox(height: 16),
              
              // Account Options Section
              _buildOptionsSection(
                title: 'Account',
                options: [
                  {
                    'icon': Icons.edit_outlined,
                    'title': AppTexts.editProfile,
                    'onTap': _navigateToEditProfile,
                  },
                  {
                    'icon': Icons.settings_outlined,
                    'title': AppTexts.settings,
                    'onTap': _navigateToSettings,
                  },
                  {
                    'icon': Icons.favorite_border_outlined,
                    'title': 'My Favorites',
                    'onTap': () {},
                  },
                  {
                    'icon': Icons.home_repair_service_outlined,
                    'title': 'My Bookings',
                    'onTap': () {
                      Routes.navigateTo(context, Routes.seekerBookings);
                    },
                  },
                ],
              ),
              const SizedBox(height: 16),
              
              // General Options Section
              _buildOptionsSection(
                title: 'General',
                options: [
                  {
                    'icon': Icons.info_outline,
                    'title': AppTexts.aboutUs,
                    'onTap': _navigateToAboutUs,
                  },
                  {
                    'icon': Icons.contact_support_outlined,
                    'title': AppTexts.contactUs,
                    'onTap': _navigateToContactUs,
                  },
                  {
                    'icon': Icons.language_outlined,
                    'title': AppTexts.language,
                    'onTap': () {
                      Routes.navigateTo(context, Routes.languageSettings);
                    },
                  },
                ],
              ),
              const SizedBox(height: 32),
              
              // Logout Button
              custom_outlined.OutlinedButton(
                text: AppTexts.logout,
                onPressed: _showLogoutConfirmation,
                prefixIcon: Icons.logout,
                borderColor: AppColors.error,
                textColor: AppColors.error,
                isFullWidth: true,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(UserModel user) {
    return Container(
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
        children: [
          // Profile Image
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: user.profileImageUrl != null 
                    ? NetworkImage(user.profileImageUrl!) 
                    : null,
                child: user.profileImageUrl == null
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
              GestureDetector(
                onTap: _navigateToEditProfile,
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
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // User Name
          Text(
            user.fullName,
            style: AppStyles.headingMediumStyle,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // User Type
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Service Seeker',
              style: AppStyles.captionStyle.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
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
          Text(
            title,
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildInfoItem(
            icon: item['icon'],
            title: item['title'],
            value: item['value'],
          )),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.captionStyle,
              ),
              Text(
                value,
                style: AppStyles.bodyTextStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptionsSection({
    required String title,
    required List<Map<String, dynamic>> options,
  }) {
    return Container(
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
          Text(
            title,
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          ...options.map((option) => _buildOptionItem(
            icon: option['icon'],
            title: option['title'],
            onTap: option['onTap'],
          )),
        ],
      ),
    );
  }
  
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
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
    );
  }
  
  Widget _buildNotLoggedInView() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                Icons.account_circle,
                size: 100,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'Login to Access Your Profile',
                style: AppStyles.headingMediumStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Create an account or log in to view your profile, track bookings, and manage your preferences.',
                style: AppStyles.bodyTextStyle.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Login Button
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Routes.navigateTo(context, Routes.seekerLogin);
                },
                isFullWidth: true,
              ),
              const SizedBox(height: 16),
              
              // Sign Up Button
              custom_outlined.OutlinedButton(
                text: 'Sign Up',
                onPressed: () {
                  Routes.navigateTo(context, Routes.seekerSignup);
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}