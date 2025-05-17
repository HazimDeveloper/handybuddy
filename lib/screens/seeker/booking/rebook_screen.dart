// lib/screens/seeker/booking/rebook_screen.dart
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
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';

class RebookScreen extends StatefulWidget {
  final String previousBookingId;
  
  const RebookScreen({
    Key? key,
    required this.previousBookingId,
  }) : super(key: key);

  @override
  State<RebookScreen> createState() => _RebookScreenState();
}

class _RebookScreenState extends State<RebookScreen> {
  BookingModel? _previousBooking;
  ServiceModel? _service;
  UserModel? _provider;
  bool _isLoading = true;
  bool _isRebooking = false;
  
  // Booking details
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  
  @override
  void initState() {
    super.initState();
    _loadPreviousBookingDetails();
  }
  
  Future<void> _loadPreviousBookingDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch previous booking details
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _previousBooking = await bookingProvider.fetchBookingById(widget.previousBookingId);
      
      if (_previousBooking != null) {
        // Fetch service details
        final serviceProvider = Provider.of<service_provider.ServiceProvider>(context, listen: false);
        _service = await serviceProvider.fetchServiceById(_previousBooking!.serviceId);
        
        // Fetch provider details
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        _provider = await authProvider.getUserById(_previousBooking!.providerId);
        
        // Set booking details from previous booking
        bookingProvider.setSelectedService(_service!);
        bookingProvider.setSelectedProvider(_provider!);
        bookingProvider.setAddress(_previousBooking!.address);
        bookingProvider.setContactNumber(_previousBooking!.contactNumber);
        bookingProvider.setPaymentMethod(_previousBooking!.paymentMethod);
        if (_previousBooking!.specialInstructions != null) {
          bookingProvider.setSpecialInstructions(_previousBooking!.specialInstructions!);
        }
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error loading booking details: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _rebookService() async {
    if (_previousBooking == null || _service == null || _provider == null) {
      ToastUtils.showErrorToast('Missing booking information');
      return;
    }
    
    // Validate date and time
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    
    if (selectedDateTime.isBefore(now)) {
      ToastUtils.showErrorToast('Please select a future date and time');
      return;
    }
    
    setState(() {
      _isRebooking = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Set scheduled date and time
      bookingProvider.setScheduledDate(_selectedDate);
      bookingProvider.setScheduledTime(_selectedTime);
      
      final result = await bookingProvider.rebookService(widget.previousBookingId);
      
      if (result == 'success') {
        // Show success dialog
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        ToastUtils.showErrorToast('Failed to rebook service: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error rebooking service: ${e.toString()}');
    } finally {
      setState(() {
        _isRebooking = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    SuccessDialog.show(
      context: context,
      title: AppTexts.rebookingSuccessful,
      message: AppTexts.rebookingSuccessfulMessage,
      buttonText: 'View Booking',
      onButtonPressed: () {
        Navigator.of(context).pop();
        Routes.navigateAndRemoveUntil(
          context, 
          Routes.seekerBookings,
        );
      },
      secondaryButtonText: 'Back to Home',
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
        Routes.navigateAndRemoveUntil(
          context, 
          Routes.seekerMain,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.rebookService),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _previousBooking == null || _service == null || _provider == null
              ? _buildErrorView()
              : _buildRebookForm(),
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
  
  Widget _buildRebookForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Previous Booking Card
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
                    AppTexts.previousBooking,
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 12),
                  _buildServiceDetails(),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildProviderDetails(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Date and Time Selection
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
                    AppTexts.selectNewDateAndTime,
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppTexts.date,
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy').format(_selectedDate),
                                      style: AppStyles.bodyTextStyle,
                                    ),
                                    const Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Time Picker
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppTexts.time,
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedTime.format(context),
                                      style: AppStyles.bodyTextStyle,
                                    ),
                                    const Icon(
                                      Icons.access_time,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Rebooking Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info,
                  color: AppColors.info,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppTexts.rebookingNote,
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Confirm Rebooking Button
          CustomButton(
            text: AppTexts.confirmRebooking,
            onPressed: _rebookService,
            isLoading: _isRebooking,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceDetails() {
    return Row(
      children: [
        // Service Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: _service!.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(_service!.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: AppColors.backgroundLight,
          ),
          child: _service!.imageUrl == null
              ? const Icon(
                  Icons.home_repair_service,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        const SizedBox(width: 12),
        
        // Service Details
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
    );
  }
  
  Widget _buildProviderDetails() {
    return Row(
      children: [
        // Provider Image
        CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.backgroundLight,
          backgroundImage: _provider!.profileImageUrl != null
              ? NetworkImage(_provider!.profileImageUrl!)
              : null,
          child: _provider!.profileImageUrl == null
              ? Text(
                  _provider!.initials,
                  style: AppStyles.subheadingStyle.copyWith(
                    color: AppColors.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        
        // Provider Details
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
                    color: AppColors.warning,
                    size: 16,
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
            ],
          ),
        ),
      ],
    );
  }
}