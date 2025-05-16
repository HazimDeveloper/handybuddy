import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:intl/intl.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String userType; // 'provider' or 'seeker'
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;
  final VoidCallback? onRebook;
  final bool showActions;
  final bool isCompact;

  const BookingCard({
    Key? key,
    required this.booking,
    required this.userType,
    required this.onViewDetails,
    this.onCancel,
    this.onComplete,
    this.onRebook,
    this.showActions = true,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format date for display
    final DateTime scheduledDate = booking.scheduledDate.toDate();
    final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(scheduledDate);
    
    // Determine status color
    final Color statusColor = AppColors.getStatusColor(booking.status);
    
    // Determine if booking is today
    final bool isToday = DateTime.now().year == scheduledDate.year &&
                         DateTime.now().month == scheduledDate.month &&
                         DateTime.now().day == scheduledDate.day;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: AppStyles.marginMedium,
        horizontal: isCompact ? 0 : AppStyles.marginMedium,
      ),
      decoration: AppStyles.bookingCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking ID
                          Text(
                            'Booking #${booking.bookingId.substring(0, 8)}',
                            style: AppStyles.bodyTextBoldStyle,
                          ),
                          const SizedBox(height: 4),
                          
                          // Scheduled Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedDate,
                                style: AppStyles.bodyTextStyle.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              if (isToday)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentExtraLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'TODAY',
                                    style: AppStyles.captionBoldStyle.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        booking.formattedStatus.toUpperCase(),
                        style: AppStyles.captionBoldStyle.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                // Service and Location Info
                if (!isCompact) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service
                            Text(
                              'Service',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.serviceId,
                              style: AppStyles.bodyTextMediumStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location
                            Text(
                              'Location',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.address,
                              style: AppStyles.bodyTextStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                ],
                
                // User Info Row
                Row(
                  children: [
                    // User Image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        userType == 'provider' ? Icons.person : Icons.handyman,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userType == 'provider' 
                                ? 'Client' 
                                : 'Service Provider',
                            style: AppStyles.labelStyle,
                          ),
                          Text(
                            userType == 'provider'
                                ? booking.seekerId
                                : booking.providerId,
                            style: AppStyles.bodyTextMediumStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Price',
                          style: AppStyles.labelStyle,
                        ),
                        Text(
                          'RM ${booking.totalAmount.toStringAsFixed(2)}',
                          style: AppStyles.bodyTextBoldStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Action Buttons
                if (showActions && !isCompact) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
                
                // Progress Indicator
                if (!isCompact && !booking.isCancelled) ...[
                  const SizedBox(height: 16),
                  _buildProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build action buttons based on booking status and user type
  Widget _buildActionButtons() {
    if (booking.isCompleted) {
      // Completed booking actions
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onViewDetails,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          if (userType == 'seeker' && onRebook != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Rebook',
                onPressed: onRebook!,
                backgroundColor: AppColors.primary,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else if (booking.isCancelled) {
      // Cancelled booking actions
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onViewDetails,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          if (userType == 'seeker' && onRebook != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Rebook',
                onPressed: onRebook!,
                backgroundColor: AppColors.primary,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else if (booking.isInProgress) {
      // In progress booking actions
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onViewDetails,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          if (userType == 'provider' && onComplete != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Complete',
                onPressed: onComplete!,
                backgroundColor: AppColors.success,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else if (booking.isConfirmed) {
      // Confirmed booking actions
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onViewDetails,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          const SizedBox(width: 12),
          if (onCancel != null) ...[
            Expanded(
              child: custom_outlined.OutlinedButton(
                text: 'Cancel',
                onPressed: onCancel!,
                borderColor: AppColors.error,
                textColor: AppColors.error,
                height: 40,
              ),
            ),
          ],
          if (userType == 'provider') ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Start',
                onPressed: onComplete ?? (){},
                backgroundColor: AppColors.success,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else if (booking.isPending) {
      // Pending booking actions
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'View Details',
              onPressed: onViewDetails,
              borderColor: AppColors.primary,
              textColor: AppColors.primary,
              height: 40,
            ),
          ),
          const SizedBox(width: 12),
          if (onCancel != null) ...[
            Expanded(
              child: custom_outlined.OutlinedButton(
                text: 'Cancel',
                onPressed: onCancel!,
                borderColor: AppColors.error,
                textColor: AppColors.error,
                height: 40,
              ),
            ),
          ],
          if (userType == 'provider') ...[
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Accept',
                onPressed: onComplete ?? (){},
                backgroundColor: AppColors.success,
                height: 40,
              ),
            ),
          ],
        ],
      );
    } else {
      // Default actions
      return custom_outlined.OutlinedButton(
        text: 'View Details',
        onPressed: onViewDetails,
        isFullWidth: true,
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        height: 40,
      );
    }
  }
  
  // Build progress indicator for booking status
  Widget _buildProgressIndicator() {
    double progress = 0.0;
    
    if (booking.isPending) {
      progress = 0.25;
    } else if (booking.isConfirmed) {
      progress = 0.5;
    } else if (booking.isInProgress) {
      progress = 0.75;
    } else if (booking.isCompleted) {
      progress = 1.0;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Booking Progress',
              style: AppStyles.labelStyle,
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppStyles.bodyTextBoldStyle.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.backgroundLight,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}