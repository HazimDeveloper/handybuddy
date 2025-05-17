// lib/screens/seeker/bookings/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/providers/service_provider.dart' as service_provider;
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';

class SeekerBookingDetailScreen extends StatefulWidget {
  final String bookingId;
  
  const SeekerBookingDetailScreen({
    Key? key, 
    this.bookingId = '',
  }) : super(key: key);

  @override
  State<SeekerBookingDetailScreen> createState() => _SeekerBookingDetailScreenState();
}

class _SeekerBookingDetailScreenState extends State<SeekerBookingDetailScreen> {
  BookingModel? _booking;
  ServiceModel? _service;
  UserModel? _provider;
  bool _isLoading = true;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }
  
  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch booking details
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _booking = await bookingProvider.fetchBookingById(widget.bookingId);
      
      if (_booking != null) {
        // Fetch service details
        final serviceProvider = Provider.of<service_provider.ServiceProvider>(context, listen: false);
        _service = await serviceProvider.fetchServiceById(_booking!.serviceId);
        
        // Fetch provider details
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _provider = await authProvider.getUserById(_booking!.providerId);
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error loading booking details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _cancelBooking() async {
    // Show confirmation dialog
    final confirm = await ConfirmDialog.showCancelBookingConfirmation(context);
    
    if (confirm != true) {
      return;
    }
    
    // Get cancellation reason
    final reason = await _showCancellationDialog();
    if (reason == null) {
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final result = await bookingProvider.updateBookingStatus(
        bookingId: _booking!.bookingId,
        status: 'cancelled',
        cancelReason: reason,
      );
      
      if (result == 'success') {
        ToastUtils.showInfoToast('Booking cancelled successfully');
        _loadBookingDetails();
      } else {
        ToastUtils.showErrorToast('Failed to cancel booking: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error cancelling booking: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  Future<String?> _showCancellationDialog() async {
    final TextEditingController reasonController = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for cancellation:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Enter reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ToastUtils.showErrorToast('Please enter a reason');
                return;
              }
              Navigator.pop(context, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
  
  void _rebookService() {
    // Navigate to rebook screen
    Routes.navigateTo(
      context, 
      Routes.rebook, 
      arguments: _booking!.bookingId,
    );
  }
  
  void _rateProvider() {
    // Navigate to rate screen
    Routes.navigateTo(
      context, 
      Routes.rateService,
      arguments: {
        'bookingId': _booking!.bookingId,
        'providerId': _booking!.providerId,
      },
    );
  }
  
  void _contactProvider() {
    if (_booking == null || _provider == null) return;
    
    // Navigate to chat screen
    Routes.navigateTo(
      context, 
      Routes.chat,
      arguments: {
        'otherUserId': _booking!.providerId,
        'chatId': null, // This will create a new chat if one doesn't exist
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _booking == null 
              ? _buildErrorView()
              : _buildBookingDetailsView(),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load booking details',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'The booking may have been deleted or you do not have permission to view it.',
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Go Back',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookingDetailsView() {
    // Format booking date
    final DateTime scheduledDate = _booking!.scheduledDate.toDate();
    final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(scheduledDate);
    
    // Status color
    final Color statusColor = AppColors.getStatusColor(_booking!.status);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking ID and Status Card
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Booking ID',
                              style: AppStyles.labelStyle,
                            ),
                            Text(
                              _booking!.bookingId.substring(0, 8),
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                      ),
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
                          _booking!.formattedStatus.toUpperCase(),
                          style: AppStyles.captionBoldStyle.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // Date and Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Scheduled Date & Time',
                        style: AppStyles.labelStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: AppStyles.bodyTextBoldStyle,
                  ),
                  
                  if (_booking!.createdAt != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Booking Created',
                          style: AppStyles.labelStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(_booking!.createdAt.toDate()),
                      style: AppStyles.bodyTextStyle,
                    ),
                  ],
                  
                  // Time Remaining or Completion Time
                  const SizedBox(height: 12),
                  _buildTimeInfo(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service Details Card
          if (_service != null) ...[
            _buildServiceCard(),
            const SizedBox(height: 16),
          ],
          
          // Provider Details Card
          if (_provider != null) ...[
            _buildProviderCard(),
            const SizedBox(height: 16),
          ],
          
          // Location Card
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Service Location',
                        style: AppStyles.subheadingStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _booking!.address,
                    style: AppStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Contact Number: ',
                        style: AppStyles.labelStyle,
                      ),
                      Text(
                        _booking!.contactNumber,
                        style: AppStyles.bodyTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Special Instructions
          if (_booking!.specialInstructions != null && 
              _booking!.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.note,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Special Instructions',
                          style: AppStyles.subheadingStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _booking!.specialInstructions!,
                      style: AppStyles.bodyTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Payment Details
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.payment,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment Details',
                        style: AppStyles.subheadingStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Method',
                        style: AppStyles.labelStyle,
                      ),
                      Text(
                        _booking!.formattedPaymentMethod,
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount',
                        style: AppStyles.labelStyle,
                      ),
                      Text(
                        'RM ${_booking!.totalAmount.toStringAsFixed(2)}',
                        style: AppStyles.bodyTextBoldStyle.copyWith(
                          color: AppColors.primary,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Before/After Service Images (if available)
          if (_booking!.beforeServiceImages != null && 
              _booking!.afterServiceImages != null &&
              _booking!.beforeServiceImages!.isNotEmpty &&
              _booking!.afterServiceImages!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildServiceEvidenceCard(),
          ],
          
          // Action Buttons
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildTimeInfo() {
    if (_booking!.isCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 8),
              Text(
                'Completed',
                style: AppStyles.labelStyle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _booking!.completedAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(_booking!.completedAt!.toDate())
                : 'N/A',
            style: AppStyles.bodyTextStyle,
          ),
        ],
      );
    } else if (_booking!.isCancelled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                'Cancelled',
                style: AppStyles.labelStyle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _booking!.cancelledAt != null
                ? DateFormat('dd MMM yyyy, hh:mm a').format(_booking!.cancelledAt!.toDate())
                : 'N/A',
            style: AppStyles.bodyTextStyle,
          ),
          if (_booking!.cancelReason != null && _booking!.cancelReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${_booking!.cancelReason}',
              style: AppStyles.bodyTextStyle.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      );
    } else {
      final String timeRemaining = _booking!.getTimeRemaining();
      final bool isOverdue = timeRemaining == 'Overdue';
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOverdue ? Icons.warning : Icons.timer,
                size: 16,
                color: isOverdue ? AppColors.error : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                isOverdue ? 'Overdue' : 'Time Remaining',
                style: AppStyles.labelStyle,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isOverdue ? 'This booking was scheduled for an earlier time' : timeRemaining,
            style: AppStyles.bodyTextStyle.copyWith(
              color: isOverdue ? AppColors.error : null,
              fontWeight: isOverdue ? FontWeight.bold : null,
            ),
          ),
        ],
      );
    }
  }
  
  Widget _buildServiceCard() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.home_repair_service,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Service Details',
                  style: AppStyles.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: _service!.imageUrl != null && _service!.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(_service!.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: AppColors.backgroundLight,
                  ),
                  child: _service!.imageUrl == null || _service!.imageUrl!.isEmpty
                      ? const Icon(
                          Icons.home_repair_service,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _service!.title,
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _service!.formattedCategory,
                        style: AppStyles.captionStyle.copyWith(
                          color: AppColors.getCategoryColor(_service!.category),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _service!.formattedPrice,
                        style: AppStyles.bodyTextBoldStyle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_service!.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Description',
                style: AppStyles.labelStyle,
              ),
              const SizedBox(height: 4),
              Text(
                _service!.description,
                style: AppStyles.bodyTextStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderCard() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Service Provider',
                  style: AppStyles.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.backgroundLight,
                  backgroundImage: _provider!.profileImageUrl != null && 
                                  _provider!.profileImageUrl!.isNotEmpty
                      ? NetworkImage(_provider!.profileImageUrl!)
                      : null,
                  child: _provider!.profileImageUrl == null || 
                          _provider!.profileImageUrl!.isEmpty
                      ? Text(
                          _provider!.initials,
                          style: AppStyles.subheadingStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _provider!.fullName,
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _provider!.formattedRating,
                            style: AppStyles.bodyTextStyle,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _provider!.experienceLevel,
                              style: AppStyles.captionStyle.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_provider!.category != null && _provider!.category!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _provider!.formattedCategory,
                          style: AppStyles.captionStyle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Contact Provider',
              onPressed: _contactProvider,
              prefixIcon: Icons.chat,
              height: 40,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceEvidenceCard() {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Service Evidence',
                  style: AppStyles.subheadingStyle,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Before Service Images
            const Text(
              'Before Service',
              style: AppStyles.labelStyle,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _booking!.beforeServiceImages!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Open image in full screen
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_booking!.beforeServiceImages![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // After Service Images
            const Text(
              'After Service',
              style: AppStyles.labelStyle,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _booking!.afterServiceImages!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Open image in full screen
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_booking!.afterServiceImages![index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    if (_booking!.isCompleted) {
      // Completed booking actions
      return Row(
        children: [
          // Rate button
          if (_booking!.rating == null) ...[
            Expanded(
              child: CustomButton(
                text: 'Rate Service',
                onPressed: _rateProvider,
                backgroundColor: AppColors.warning,
                prefixIcon: Icons.star,
                height: 48,
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Rebook button
          Expanded(
            child: CustomButton(
              text: 'Book Again',
              onPressed: _rebookService,
              backgroundColor: AppColors.primary,
              prefixIcon: Icons.bookmark_add,
              height: 48,
            ),
          ),
        ],
      );
    } else if (_booking!.isCancelled) {
      // Cancelled booking - only rebook option
      return CustomButton(
        text: 'Book Again',
        onPressed: _rebookService,
        backgroundColor: AppColors.primary,
        prefixIcon: Icons.bookmark_add,
        isFullWidth: true,
        height: 48,
      );
    } else {
      // Pending, confirmed or in progress - can cancel if not in progress
      return Row(
        children: [
          // Contact Provider button
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'Contact',
              onPressed: _contactProvider,
              prefixIcon: Icons.chat,
              borderColor: AppColors.secondary,
              textColor: AppColors.secondary,
              height: 48,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Cancel button (only if booking can be cancelled)
          if (_booking!.canBeCancelled) ...[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                onPressed: _cancelBooking,
                backgroundColor: AppColors.error,
                prefixIcon: Icons.cancel,
                isLoading: _isProcessing,
                height: 48,
              ),
            ),
          ] else ...[
            // If can't cancel, show contact provider button as full width
            Expanded(
              child: CustomButton(
                text: 'View Status',
                onPressed: () {},
                backgroundColor: AppColors.primary,
                prefixIcon: Icons.visibility,
                height: 48,
              ),
            ),
          ],
        ],
      );
    }
  }
} // No action