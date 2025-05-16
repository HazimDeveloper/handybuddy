import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
class ProviderCard extends StatelessWidget {
  final UserModel provider;
  final VoidCallback onViewProfile;
  final VoidCallback? onBookNow;
  final VoidCallback? onViewServices;
  final bool isCompact;
  final bool showActions;
  final bool showRating;
  final bool isSelected;
  
  const ProviderCard({
    Key? key,
    required this.provider,
    required this.onViewProfile,
    this.onBookNow,
    this.onViewServices,
    this.isCompact = false,
    this.showActions = true,
    this.showRating = true,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure we're dealing with a provider
    if (!provider.isProvider) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppStyles.marginMedium,
        horizontal: isCompact ? 0 : AppStyles.marginMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2) 
            : Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewProfile,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider Info Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Provider Image
                    _buildProviderAvatar(),
                    
                    const SizedBox(width: 12),
                    
                    // Provider Basic Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Verification Badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provider.fullName,
                                  style: AppStyles.subheadingStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (provider.isVerified ?? false)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  child: const Icon(
                                    Icons.verified,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 2),
                          
                          // Category
                          Text(
                            provider.formattedCategory,
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Show Rating
                          if (showRating) ...[
                            const SizedBox(height: 4),
                            _buildRatingIndicator(),
                          ],
                          
                          // Provider Status
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (provider.availableForWork ?? false)
                                      ? AppColors.success
                                      : AppColors.textLight,
                                ),
                              ),
                              Text(
                                (provider.availableForWork ?? false)
                                    ? 'Available'
                                    : 'Unavailable',
                                style: AppStyles.captionStyle.copyWith(
                                  color: (provider.availableForWork ?? false)
                                      ? AppColors.success
                                      : AppColors.textLight,
                                ),
                              ),
                              if (provider.isNew) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.infoBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: AppStyles.captionBoldStyle.copyWith(
                                      color: AppColors.info,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Additional Info
                if (!isCompact) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // Provider Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Experience Level
                      _buildStatItem(
                        icon: Icons.workspace_premium,
                        label: 'Experience',
                        value: provider.experienceLevel,
                        color: AppColors.primary,
                      ),
                      
                      // Success Rate
                      _buildStatItem(
                        icon: Icons.check_circle,
                        label: 'Success Rate',
                        value: provider.successRate,
                        color: AppColors.success,
                      ),
                      
                      // Total Services
                      _buildStatItem(
                        icon: Icons.home_repair_service,
                        label: 'Services',
                        value: '${provider.totalServices ?? 0}',
                        color: AppColors.info,
                      ),
                    ],
                  ),
                  
                  // Bio (if available)
                  if (provider.bio != null && provider.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'About',
                      style: AppStyles.labelLargeStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.bio!,
                      style: AppStyles.bodyTextStyle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Skills (if available)
                  if (provider.hasSkills) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Skills',
                      style: AppStyles.labelLargeStyle,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.skills!.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            skill,
                            style: AppStyles.captionStyle,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
                
                // Action Buttons
                if (showActions) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build provider avatar
  Widget _buildProviderAvatar() {
    if (provider.profileImageUrl != null && provider.profileImageUrl!.isNotEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(provider.profileImageUrl!),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      );
    } else {
      // Default avatar with initials
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryLight,
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            provider.initials,
            style: AppStyles.headingStyle.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }
  }

  // Build star rating indicator
  Widget _buildRatingIndicator() {
    double rating = provider.rating ?? 0;
    
    return Row(
      children: [
        // Stars
        ...List.generate(5, (index) {
          IconData iconData;
          if (index < rating.floor()) {
            iconData = Icons.star;
          } else if (index < rating) {
            iconData = Icons.star_half;
          } else {
            iconData = Icons.star_border;
          }
          
          return Icon(
            iconData,
            color: AppColors.warning,
            size: 16,
          );
        }),
        
        const SizedBox(width: 4),
        
        // Rating value
        Text(
          provider.formattedRating,
          style: AppStyles.captionBoldStyle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Build stat item with icon, label, and value
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.bodyTextBoldStyle,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.captionStyle,
        ),
      ],
    );
  }

  // Build action buttons
  Widget _buildActionButtons() {
    if (isCompact) {
      // Single action for compact view
      return CustomButton(
        text: 'View Profile',
        onPressed: onViewProfile,
        isFullWidth: true,
        backgroundColor: AppColors.primary,
        height: 40,
      );
    } else {
      // Multiple actions for full view
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Profile',
              onPressed: onViewProfile,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          if (onViewServices != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: custom_outlined.OutlinedButton(
                text: 'Services',
                onPressed: onViewServices!,
                borderColor: AppColors.secondary,
                textColor: AppColors.secondary,
                height: 40,
              ),
            ),
          ],
          if (onBookNow != null && (provider.availableForWork ?? false)) ...[
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                text: 'Book Now',
                onPressed: onBookNow!,
                backgroundColor: AppColors.primary,
                height: 40,
              ),
            ),
          ],
        ],
      );
    }
  }
}