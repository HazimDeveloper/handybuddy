import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final String viewType; // 'provider' or 'seeker'
  final VoidCallback onTap;
  final VoidCallback? onBook;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleActive;
  final bool isCompact;
  final bool showActions;
  final bool showProviderInfo;
  final Map<String, dynamic>? providerInfo; // Optional provider details

  const ServiceCard({
    Key? key,
    required this.service,
    required this.viewType,
    required this.onTap,
    this.onBook,
    this.onEdit,
    this.onToggleActive,
    this.isCompact = false,
    this.showActions = true,
    this.showProviderInfo = false,
    this.providerInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isProviderView = viewType == 'provider';
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppStyles.marginMedium,
        horizontal: isCompact ? 0 : AppStyles.marginMedium,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              _buildServiceImage(),
              
              // Service Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.getCategoryColor(service.category).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            service.formattedCategory,
                            style: AppStyles.captionBoldStyle.copyWith(
                              color: AppColors.getCategoryColor(service.category),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // New Service Badge
                        if (service.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NEW',
                              style: AppStyles.captionBoldStyle.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                          
                        // Emergency Service Badge
                        if (service.hasEmergencyService && !isCompact)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'EMERGENCY',
                              style: AppStyles.captionBoldStyle.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          
                        const Spacer(),
                        
                        // Active Status (for provider view)
                        if (isProviderView)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive 
                                  ? AppColors.successBackground 
                                  : AppColors.errorBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              service.isActive ? 'ACTIVE' : 'INACTIVE',
                              style: AppStyles.captionBoldStyle.copyWith(
                                color: service.isActive 
                                    ? AppColors.success 
                                    : AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Service Title
                    Text(
                      service.title,
                      style: AppStyles.subheadingStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Service Provider Info (for seeker view)
                    if (showProviderInfo && providerInfo != null && !isProviderView) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Provider Avatar
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryLight,
                            ),
                            child: providerInfo!['profileImageUrl'] != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      providerInfo!['profileImageUrl'],
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      '${providerInfo!['firstName'][0]}${providerInfo!['lastName'][0]}',
                                      style: AppStyles.captionBoldStyle.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Provider Name
                          Expanded(
                            child: Text(
                              '${providerInfo!['firstName']} ${providerInfo!['lastName']}',
                              style: AppStyles.bodySmallStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          // Provider Rating
                          if (providerInfo!.containsKey('rating')) ...[
                            Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${(providerInfo!['rating'] as num? ?? 0).toStringAsFixed(1)}',
                              style: AppStyles.bodySmallBoldStyle,
                            ),
                          ],
                        ],
                      ),
                    ],
                    
                    // Service Description
                    if (!isCompact) ...[
                      const SizedBox(height: 8),
                      Text(
                        service.description,
                        style: AppStyles.bodySmallStyle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Service Details Row
                    Row(
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: AppStyles.labelStyle,
                            ),
                            Text(
                              service.formattedPrice,
                              style: AppStyles.bodyTextBoldStyle.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        
                        const Spacer(),
                        
                        // Duration (if available)
                        if (service.estimatedDuration != null && !isCompact) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Duration',
                                style: AppStyles.labelStyle,
                              ),
                              Text(
                                service.formattedDuration,
                                style: AppStyles.bodyTextStyle,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    
                    // Emergency Price (if available)
                    if (service.hasEmergencyService && !isCompact) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Emergency Price: ',
                            style: AppStyles.bodySmallStyle,
                          ),
                          Text(
                            service.formattedEmergencyPrice ?? '',
                            style: AppStyles.bodySmallBoldStyle.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    // Action Buttons
                    if (showActions) ...[
                      const SizedBox(height: 16),
                      _buildActionButtons(isProviderView),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build service image section
  Widget _buildServiceImage() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        image: service.imageUrl != null && service.imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(service.imageUrl!),
                fit: BoxFit.cover,
              )
            : const DecorationImage(
                image: AssetImage('assets/images/default_service.png'),
                fit: BoxFit.cover,
              ),
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          
          // Tags overlay
          if (service.tags != null && service.tags!.isNotEmpty && !isCompact)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: service.tags!.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        tag,
                        style: AppStyles.captionStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
          // Rating/Booking Counter (for seeker view)
          if (!isCompact && viewType == 'seeker' && service.averageRating != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${service.averageRating!.toStringAsFixed(1)}',
                      style: AppStyles.captionBoldStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${service.totalBookings ?? 0})',
                      style: AppStyles.captionStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Build action buttons
  Widget _buildActionButtons(bool isProviderView) {
    if (isProviderView) {
      // Provider view buttons
      return Row(
        children: [
          // Edit Button
          if (onEdit != null)
            Expanded(
              child: custom_outlined.OutlinedButton(
                text: 'Edit',
                onPressed: onEdit!,
                prefixIcon: Icons.edit,
                borderColor: AppColors.secondary,
                textColor: AppColors.secondary,
                height: 40,
              ),
            ),
            
          // Toggle Active Button
          if (onToggleActive != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                text: service.isActive ? 'Deactivate' : 'Activate',
                onPressed: onToggleActive!,
                prefixIcon: service.isActive 
                    ? Icons.visibility_off 
                    : Icons.visibility,
                backgroundColor: service.isActive 
                    ? AppColors.warning 
                    : AppColors.success,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else {
      // Seeker view buttons
      return Row(
        children: [
          // View Details
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onTap,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          
          // Book Now
          if (onBook != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                text: 'Book Now',
                onPressed: onBook!,
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