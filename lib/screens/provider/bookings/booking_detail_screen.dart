// lib/screens/provider/bookings/booking_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/providers/service_provider.dart' as service_provider;
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';

class ProviderBookingDetailScreen extends StatefulWidget {
  final String bookingId;
  
  const ProviderBookingDetailScreen({
    Key? key, 
    this.bookingId = '',
  }) : super(key: key);

  @override
  State<ProviderBookingDetailScreen> createState() => _ProviderBookingDetailScreenState();
}

class _ProviderBookingDetailScreenState extends State<ProviderBookingDetailScreen> {
  BookingModel? _booking;
  ServiceModel? _service;
  UserModel? _seeker;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isShowingEvidence = false;
  
  // Before/After service evidence
  List<File> _beforeImages = [];
  List<File> _afterImages = [];
  
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
        
        // Fetch seeker details
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _seeker = await authProvider.getUserById(_booking!.seekerId);
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error loading booking details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _updateBookingStatus(String status) async {
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      String result;
      
      if (status == 'confirmed') {
        // For confirming a booking, we need to provide the total amount
        result = await bookingProvider.updateBookingStatus(
          bookingId: _booking!.bookingId,
          status: status,
          totalAmount: _service?.price ?? 0,
        );
      } else if (status == 'cancelled') {
        // For cancellations, we need a reason
        final reason = await _showCancellationDialog();
        if (reason == null) {
          setState(() {
            _isUpdating = false;
          });
          return;
        }
        
        result = await bookingProvider.updateBookingStatus(
          bookingId: _booking!.bookingId,
          status: status,
          cancelReason: reason,
        );
      } else {
        // For other status updates (in_progress, completed)
        result = await bookingProvider.updateBookingStatus(
          bookingId: _booking!.bookingId,
          status: status,
        );
      }
      
      if (result == 'success') {
        _loadBookingDetails();
        
        if (status == 'confirmed') {
          ToastUtils.showSuccessToast('Booking confirmed successfully');
        } else if (status == 'in_progress') {
          ToastUtils.showSuccessToast('Service started successfully');
        } else if (status == 'completed') {
          _showCompletionDialog();
        } else if (status == 'cancelled') {
          ToastUtils.showInfoToast('Booking cancelled successfully');
        }
      } else {
        ToastUtils.showErrorToast('Failed to update booking: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error updating booking: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdating = false;
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
  
  void _showCompletionDialog() {
    SuccessDialog.show(
      context: context,
      title: 'Service Completed',
      message: 'The service has been marked as completed successfully.',
      buttonText: 'Add Service Evidence',
      onButtonPressed: () {
        Navigator.pop(context);
        setState(() {
          _isShowingEvidence = true;
        });
      },
      secondaryButtonText: 'Close',
      onSecondaryButtonPressed: () {
        Navigator.pop(context);
      },
    );
  }
  
  Future<void> _pickBeforeImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();
    
    if (selectedImages.isNotEmpty) {
      setState(() {
        _beforeImages.addAll(selectedImages.map((image) => File(image.path)).toList());
      });
    }
  }
  
  Future<void> _pickAfterImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> selectedImages = await picker.pickMultiImage();
    
    if (selectedImages.isNotEmpty) {
      setState(() {
        _afterImages.addAll(selectedImages.map((image) => File(image.path)).toList());
      });
    }
  }
  
  Future<void> _uploadServiceEvidence() async {
    if (_beforeImages.isEmpty) {
      ToastUtils.showErrorToast('Please add before service images');
      return;
    }
    
    if (_afterImages.isEmpty) {
      ToastUtils.showErrorToast('Please add after service images');
      return;
    }
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.addBeforeServiceImages(_beforeImages);
      bookingProvider.addAfterServiceImages(_afterImages);
      
      final result = await bookingProvider.uploadServiceEvidence(_booking!.bookingId);
      
      if (result == 'success') {
        setState(() {
          _isShowingEvidence = false;
          _beforeImages = [];
          _afterImages = [];
        });
        
        ToastUtils.showSuccessToast('Service evidence uploaded successfully');
        _loadBookingDetails();
      } else {
        ToastUtils.showErrorToast('Failed to upload service evidence: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error uploading service evidence: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
  
  void _contactSeeker() {
    if (_booking == null || _seeker == null) return;
    
    Routes.navigateTo(
      context, 
      Routes.chat,
      arguments: {
        'otherUserId': _booking!.seekerId,
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
              : _isShowingEvidence
                  ? _buildEvidenceUploadView()
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
                              _booking!.bookingId,
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
          
          // Client (Seeker) Details Card
          if (_seeker != null) ...[
            _buildSeekerCard(),
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
  
  Widget _buildSeekerCard() {
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
                  'Client Details',
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
                  backgroundImage: _seeker!.profileImageUrl != null && 
                                  _seeker!.profileImageUrl!.isNotEmpty
                      ? NetworkImage(_seeker!.profileImageUrl!)
                      : null,
                  child: _seeker!.profileImageUrl == null || 
                          _seeker!.profileImageUrl!.isEmpty
                      ? Text(
                          _seeker!.initials,
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
                        _seeker!.fullName,
                        style: AppStyles.bodyTextBoldStyle,
                      ),
                      const SizedBox(height: 4),
                      if (_seeker!.phoneNumber != null && _seeker!.phoneNumber!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _seeker!.phoneNumber!,
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _seeker!.email,
                            style: AppStyles.bodyTextStyle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Contact Client',
              onPressed: _contactSeeker,
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
                  return Container(
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
                  return Container(
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // For completed bookings
          if (_booking!.beforeServiceImages == null || 
              _booking!.afterServiceImages == null ||
              _booking!.beforeServiceImages!.isEmpty ||
              _booking!.afterServiceImages!.isEmpty) ...[
            // If no evidence uploaded yet, show upload button
            CustomButton(
              text: 'Upload Service Evidence',
              onPressed: () {
                setState(() {
                  _isShowingEvidence = true;
                });
              },
              backgroundColor: AppColors.primary,
              prefixIcon: Icons.camera_alt,
              isFullWidth: true,
            ),
          ],
        ],
      );
    } else if (_booking!.isCancelled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // For cancelled bookings, no action buttons
          const Text(
            'This booking has been cancelled and cannot be modified.',
            style: AppStyles.bodyTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_booking!.isInProgress) {
      return CustomButton(
        text: 'Mark as Completed',
        onPressed: () => _updateBookingStatus('completed'),
        backgroundColor: AppColors.success,
        prefixIcon: Icons.check_circle,
        isFullWidth: true,
        isLoading: _isUpdating,
      );
    } else if (_booking!.isConfirmed) {
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'Cancel',
              onPressed: () => _updateBookingStatus('cancelled'),
              borderColor: AppColors.error,
              textColor: AppColors.error,
              prefixIcon: Icons.cancel,
              isLoading: _isUpdating,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Start Service',
              onPressed: () => _updateBookingStatus('in_progress'),
              backgroundColor: AppColors.primary,
              prefixIcon: Icons.play_arrow,
              isLoading: _isUpdating,
            ),
          ),
        ],
      );
    } else if (_booking!.isPending) {
      return Row(
        children: [
          Expanded(
            child: custom_outlined.OutlinedButton(
              text: 'Decline',
              onPressed: () => _updateBookingStatus('cancelled'),
              borderColor: AppColors.error,
              textColor: AppColors.error,
              prefixIcon: Icons.close,
              isLoading: _isUpdating,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              text: 'Accept',
              onPressed: () => _updateBookingStatus('confirmed'),
              backgroundColor: AppColors.success,
              prefixIcon: Icons.check,
              isLoading: _isUpdating,
            ),
          ),
        ],
      );
    } else {
      // Default case
      return const SizedBox.shrink();
    }
  }
  
  Widget _buildEvidenceUploadView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  const Text(
                    'Upload Service Evidence',
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please upload images showing the condition before and after providing your service. This helps maintain transparency and quality of service.',
                    style: AppStyles.bodyTextStyle,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Before Service Images
          Text(
            'Before Service Images (${_beforeImages.length})',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload images showing the condition before starting the service',
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 16),
          
          if (_beforeImages.isEmpty) ...[
            GestureDetector(
              onTap: _pickBeforeImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add before service images',
                      style: AppStyles.bodyTextStyle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Display selected before images
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _beforeImages.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == _beforeImages.length) {
                    // Add button at the end
                    return GestureDetector(
                      onTap: _pickBeforeImages,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add More',
                              style: AppStyles.captionStyle.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Image preview with delete option
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_beforeImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _beforeImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // After Service Images
          Text(
            'After Service Images (${_afterImages.length})',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload images showing the condition after completing the service',
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 16),
          
          if (_afterImages.isEmpty) ...[
            GestureDetector(
              onTap: _pickAfterImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_a_photo,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add after service images',
                      style: AppStyles.bodyTextStyle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Display selected after images
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _afterImages.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  if (index == _afterImages.length) {
                    // Add button at the end
                    return GestureDetector(
                      onTap: _pickAfterImages,
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add More',
                              style: AppStyles.captionStyle.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Image preview with delete option
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_afterImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _afterImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: custom_outlined.OutlinedButton(
                  text: 'Cancel',
                  onPressed: () {
                    setState(() {
                      _isShowingEvidence = false;
                      _beforeImages = [];
                      _afterImages = [];
                    });
                  },
                  borderColor: AppColors.textSecondary,
                  textColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  text: 'Upload',
                  onPressed: _uploadServiceEvidence,
                  isLoading: _isUpdating,
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}