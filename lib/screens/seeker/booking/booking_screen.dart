// lib/screens/seeker/booking/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/form_validators.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel? service;
  final UserModel? provider;
  final bool isEmergency; // Add this property
  
  const BookingScreen({
    Key? key,
    this.service,
    this.provider,
    this.isEmergency = false, // Default to regular booking
  }) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _addressController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  
  // Booking details
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _paymentMethod = 'cod'; // Default to cash on delivery
  
  // State variables
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    
    // If this is an emergency booking, set the date to today
    if (widget.isEmergency) {
      _selectedDate = DateTime.now();
      // Set time to current time + 1 hour
      final now = TimeOfDay.now();
      _selectedTime = TimeOfDay(
        hour: (now.hour + 1) % 24, 
        minute: now.minute
      );
    }
  }
  
  @override
  void dispose() {
    _addressController.dispose();
    _contactNumberController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user != null) {
      // Auto-fill contact number if available
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        setState(() {
          _contactNumberController.text = user.phoneNumber!;
        });
      }
      
      // Auto-fill address from saved addresses if available (future enhancement)
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    // If this is an emergency, don't allow date selection
    if (widget.isEmergency) {
      ToastUtils.showInfoToast('Date cannot be changed for emergency requests');
      return;
    }
    
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
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
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
  
  Future<void> _selectTime(BuildContext context) async {
    // If this is an emergency, don't allow time selection
    if (widget.isEmergency) {
      ToastUtils.showInfoToast('Time cannot be changed for emergency requests');
      return;
    }
    
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
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
  
  void _proceedToConfirm() {
    if (_formKey.currentState!.validate()) {
      if (widget.isEmergency && _specialInstructionsController.text.isEmpty) {
        ToastUtils.showErrorToast('Please provide details about your emergency');
        return;
      }
      
      // Navigate to confirmation screen with all booking details
      Routes.navigateTo(
        context,
        Routes.bookingConfirmation,
        arguments: {
          'service': widget.service,
          'provider': widget.provider,
          'scheduledDate': _selectedDate,
          'scheduledTime': _selectedTime,
          'address': _addressController.text,
          'contactNumber': _contactNumberController.text,
          'specialInstructions': _specialInstructionsController.text.isEmpty 
              ? null 
              : _specialInstructionsController.text,
          'paymentMethod': _paymentMethod,
          'isEmergency': widget.isEmergency,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format date and time for display
    final String formattedDate = DateFormat('dd MMMM yyyy').format(_selectedDate);
    final String formattedTime = _selectedTime.format(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEmergency ? 'Emergency Request' : AppTexts.bookService),
        backgroundColor: widget.isEmergency ? AppColors.error : AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Banner
              if (widget.isEmergency)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.errorBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Emergency Request',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please provide your details for immediate assistance. Emergency services may have higher rates.',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              
              // Service Info Card
              if (widget.service != null) ...[
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      // Service Image
                      if (widget.service?.imageUrl != null)
                        Container(
                          width: 80,
                          height: 80,
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.home_repair_service,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      const SizedBox(width: 16),
                      
                      // Service Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service!.title,
                              style: AppStyles.subheadingStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.service!.formattedCategory,
                              style: AppStyles.captionStyle.copyWith(
                                color: AppColors.getCategoryColor(widget.service!.category),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isEmergency && widget.service!.emergencyPrice != null
                                ? 'RM ${widget.service!.emergencyPrice!.toStringAsFixed(2)}'
                                : widget.service!.formattedPrice,
                              style: AppStyles.bodyTextBoldStyle.copyWith(
                                color: widget.isEmergency ? AppColors.error : AppColors.primary,
                              ),
                            ),
                            if (widget.isEmergency && widget.service!.emergencyPrice != null)
                              Text(
                                'Emergency Rate',
                                style: AppStyles.captionStyle.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Provider Info
              if (widget.provider != null) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    children: [
                      // Provider Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.backgroundLight,
                        backgroundImage: widget.provider!.profileImageUrl != null
                            ? NetworkImage(widget.provider!.profileImageUrl!)
                            : null,
                        child: widget.provider!.profileImageUrl == null
                            ? Text(
                                widget.provider!.initials,
                                style: AppStyles.subheadingStyle.copyWith(
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      
                      // Provider Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.provider!.fullName,
                              style: AppStyles.subheadingStyle,
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
                                  widget.provider!.formattedRating,
                                  style: AppStyles.bodyTextBoldStyle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.provider!.verificationStatus,
                                  style: AppStyles.captionStyle.copyWith(
                                    color: widget.provider!.isVerified == true
                                        ? AppColors.success
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Booking Form
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                    // Date and Time Section - Only show if not emergency or show with different styling
                    Text(
                      widget.isEmergency ? 'Emergency Request Time' : AppTexts.selectDateAndTime,
                      style: AppStyles.subheadingStyle.copyWith(
                        color: widget.isEmergency ? AppColors.error : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selector
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.date,
                                style: AppStyles.labelStyle,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: widget.isEmergency 
                                    ? null 
                                    : () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: widget.isEmergency 
                                          ? AppColors.error 
                                          : AppColors.borderLight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: widget.isEmergency 
                                        ? AppColors.errorBackground 
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: AppStyles.bodyTextStyle.copyWith(
                                          color: widget.isEmergency 
                                              ? AppColors.error 
                                              : null,
                                        ),
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: widget.isEmergency 
                                            ? AppColors.error 
                                            : AppColors.primary,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Time Selector
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.time,
                                style: AppStyles.labelStyle,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: widget.isEmergency 
                                    ? null 
                                    : () => _selectTime(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: widget.isEmergency 
                                          ? AppColors.error 
                                          : AppColors.borderLight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: widget.isEmergency 
                                        ? AppColors.errorBackground 
                                        : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: AppStyles.bodyTextStyle.copyWith(
                                          color: widget.isEmergency 
                                              ? AppColors.error 
                                              : null,
                                        ),
                                      ),
                                      Icon(
                                        Icons.access_time,
                                        color: widget.isEmergency 
                                            ? AppColors.error 
                                            : AppColors.primary,
                                        size: 20,
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
                    const SizedBox(height: 24),
                    
                    // Location Section
                    Text(
                      AppTexts.serviceLocation,
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Input
                    TextInput(
                      label: AppTexts.address,
                      controller: _addressController,
                      validator: FormValidators.validateAddress,
                      prefix: const Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    
                    // Contact Number
                    PhoneInput(
                      controller: _contactNumberController,
                      validator: FormValidators.validatePhoneNumber,
                    ),
                    const SizedBox(height: 24),
                    
                    // Additional Notes / Emergency Details
                    Text(
                      widget.isEmergency ? 'Emergency Details (Required)' : AppTexts.additionalNotes,
                      style: AppStyles.subheadingStyle.copyWith(
                        color: widget.isEmergency ? AppColors.error : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Special Instructions / Emergency Details
                    TextAreaInput(
                      controller: _specialInstructionsController,
                      validator: widget.isEmergency 
                          ? FormValidators.validateEmergencyDetails 
                          : FormValidators.validateSpecialInstructions,
                      hint: widget.isEmergency 
                          ? 'Please describe your emergency situation in detail' 
                          : 'Add any special instructions for the service provider',
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),
                    
                    // Payment Method
                    Text(
                      AppTexts.paymentMethod,
                      style: AppStyles.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment Options - If emergency, default to COD
                    widget.isEmergency 
                        ? _buildPaymentOption(
                            title: 'Cash on Delivery',
                            subtitle: 'Pay directly to the service provider',
                            value: 'cod',
                            icon: Icons.payments,
                          )
                        : _buildPaymentOptions(),
                  ],
                ),
              ),
              
              // Proceed Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  text: widget.isEmergency ? 'Request Emergency Service' : AppTexts.proceedToConfirm,
                  onPressed: _proceedToConfirm,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  backgroundColor: widget.isEmergency ? AppColors.error : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPaymentOptions() {
    return Column(
      children: [
        // Cash on Delivery
        _buildPaymentOption(
          title: 'Cash on Delivery',
          subtitle: 'Pay directly to the service provider',
          value: 'cod',
          icon: Icons.payments,
        ),
        const SizedBox(height: 12),
        
        // E-wallet
        _buildPaymentOption(
          title: AppTexts.eWallet,
          subtitle: AppTexts.eWalletSubtitle,
          value: 'ewallet',
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 12),
        
        // Online Banking
        _buildPaymentOption(
          title: AppTexts.onlineBanking,
          subtitle: AppTexts.onlineBankingSubtitle,
          value: 'fpx',
          icon: Icons.account_balance,
        ),
      ],
    );
  }
  
  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = _paymentMethod == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primaryExtraLight : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyTextBoldStyle.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppStyles.captionStyle,
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _paymentMethod,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _paymentMethod = newValue;
                  });
                }
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}