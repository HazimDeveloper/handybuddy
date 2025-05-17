// lib/screens/seeker/booking/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';
// Modified constructor for BookingConfirmationScreen to accept a Map of arguments
class BookingConfirmationScreen extends StatefulWidget {
  final ServiceModel? service;
  final UserModel? provider;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final String? address;
  final String? contactNumber;
  final String? specialInstructions;
  final String? paymentMethod;
  
  const BookingConfirmationScreen({
    Key? key,
    this.service,
    this.provider,
    this.scheduledDate,
    this.scheduledTime,
    this.address,
    this.contactNumber,
    this.specialInstructions,
    this.paymentMethod,
  }) : super(key: key);

  // Factory constructor to handle route arguments
  factory BookingConfirmationScreen.fromArgs(Map<String, dynamic> args) {
    return BookingConfirmationScreen(
      service: args['service'],
      provider: args['provider'],
      scheduledDate: args['scheduledDate'],
      scheduledTime: args['scheduledTime'],
      address: args['address'],
      contactNumber: args['contactNumber'],
      specialInstructions: args['specialInstructions'],
      paymentMethod: args['paymentMethod'],
    );
  }

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isLoading = false;
  bool _isEmergency = false;
  double _serviceFee = 0;
  double _platformFee = 0;
  double _totalAmount = 0;
  final double _platformFeePercentage = 0.05; // 5% platform fee

  @override
  void initState() {
    super.initState();
    _calculateFees();
  }

  void _calculateFees() {
    if (widget.service != null) {
      _serviceFee = widget.service!.price;
      
      // Emergency service has additional charges if applicable
      if (_isEmergency && widget.service!.hasEmergencyService) {
        _serviceFee = widget.service!.emergencyPrice ?? _serviceFee * 1.5;
      }
      
      // Calculate platform fee (5% of service fee)
      _platformFee = _serviceFee * _platformFeePercentage;
      
      // Calculate total amount
      _totalAmount = _serviceFee + _platformFee;
    }
  }

  Future<void> _confirmBooking() async {
    if (widget.service == null || widget.provider == null) {
      ToastUtils.showErrorToast('Service or provider information is missing');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Set booking information in provider
      bookingProvider.setSelectedService(widget.service!);
      bookingProvider.setSelectedProvider(widget.provider!);
      
      if (widget.scheduledDate != null && widget.scheduledTime != null) {
        bookingProvider.setScheduledDate(widget.scheduledDate!);
        bookingProvider.setScheduledTime(widget.scheduledTime!);
      }
      
      if (widget.address != null) {
        bookingProvider.setAddress(widget.address!);
      }
      
      if (widget.contactNumber != null) {
        bookingProvider.setContactNumber(widget.contactNumber!);
      }
      
      if (widget.specialInstructions != null) {
        bookingProvider.setSpecialInstructions(widget.specialInstructions!);
      }
      
      if (widget.paymentMethod != null) {
        bookingProvider.setPaymentMethod(widget.paymentMethod!);
      }
      
      // Create booking
      String result;
      if (_isEmergency) {
        result = await bookingProvider.createEmergencyBooking(
          emergencyDetails: widget.specialInstructions ?? 'Emergency service requested',
        );
      } else {
        result = await bookingProvider.createBooking();
      }

      if (result == 'success') {
        if (mounted) {
          // Show success dialog
          SuccessDialog.showBookingConfirmed(
            context: context,
            bookingId: bookingProvider.bookings.isNotEmpty 
                ? bookingProvider.bookings.first.bookingId 
                : 'Unknown',
            onViewBooking: () {
              // Navigate to booking details screen
              if (bookingProvider.bookings.isNotEmpty) {
                Routes.navigateAndRemoveUntil(
                  context, 
                  Routes.seekerBookingDetail,
                  arguments: bookingProvider.bookings.first.bookingId,
                );
              } else {
                Routes.navigateAndRemoveUntil(context, Routes.seekerBookings);
              }
            },
          );
        }
      } else {
        ToastUtils.showErrorToast('Failed to create booking: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error creating booking: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format date and time
    String formattedDate = widget.scheduledDate != null 
        ? DateFormat('dd MMMM yyyy').format(widget.scheduledDate!)
        : 'As soon as possible';
        
    String formattedTime = widget.scheduledTime != null
        ? widget.scheduledTime!.format(context)
        : 'Flexible';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.confirmBooking),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Booking Summary Card
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTexts.bookingSummary,
                          style: AppStyles.subheadingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Service Details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.service?.imageUrl != null)
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(widget.service!.imageUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.home_repair_service,
                                  color: AppColors.primary,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.service?.title ?? 'Service',
                                    style: AppStyles.bodyTextBoldStyle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.service?.formattedCategory ?? 'Category',
                                    style: AppStyles.captionStyle.copyWith(
                                      color: widget.service != null
                                          ? AppColors.getCategoryColor(widget.service!.category)
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Provider
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Service Provider:',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.provider?.fullName ?? 'Provider',
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Date
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Date:',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Time
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Time:',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedTime,
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Location
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Address:',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.address ?? 'Address',
                                style: AppStyles.bodyTextStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Contact
                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Contact:',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.contactNumber ?? 'Contact',
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        
                        // Special Instructions
                        if (widget.specialInstructions != null && 
                            widget.specialInstructions!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          const Text(
                            'Special Instructions:',
                            style: AppStyles.labelStyle,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.specialInstructions!,
                            style: AppStyles.bodyTextStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Emergency Service Option
                  if (widget.service != null && widget.service!.hasEmergencyService) ...[
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _isEmergency,
                            onChanged: (value) {
                              setState(() {
                                _isEmergency = value ?? false;
                                _calculateFees();
                              });
                            },
                            activeColor: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Request Emergency Service',
                                  style: AppStyles.bodyTextBoldStyle.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Emergency services have higher rates and will be attended to as soon as possible',
                                  style: AppStyles.captionStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Payment Details Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payment,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppTexts.paymentDetails,
                          style: AppStyles.subheadingStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Payment Breakdown
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Service Fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppTexts.serviceFee,
                              style: AppStyles.bodyTextStyle,
                            ),
                            Text(
                              'RM ${_serviceFee.toStringAsFixed(2)}',
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Platform Fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppTexts.platformFee} (5%)',
                              style: AppStyles.bodyTextStyle,
                            ),
                            Text(
                              'RM ${_platformFee.toStringAsFixed(2)}',
                              style: AppStyles.bodyTextStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppTexts.total,
                              style: AppStyles.bodyTextBoldStyle,
                            ),
                            Text(
                              'RM ${_totalAmount.toStringAsFixed(2)}',
                              style: AppStyles.bodyTextBoldStyle.copyWith(
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Payment Method
                        Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              AppTexts.paymentMethod + ':',
                              style: AppStyles.labelStyle,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getPaymentMethodName(widget.paymentMethod ?? 'cod'),
                              style: AppStyles.bodyTextBoldStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomButton(
                    text: AppTexts.confirmAndPay,
                    onPressed: _confirmBooking,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    backgroundColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  custom_outlined.OutlinedButton(
                    text: AppTexts.cancel,
                    onPressed: () => Navigator.pop(context),
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cod':
        return 'Cash on Delivery';
      case 'fpx':
        return 'Online Banking (FPX)';
      case 'ewallet':
        return 'E-wallet';
      default:
        return method;
    }
  }
}