// lib/screens/seeker/booking/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';

class PaymentScreen extends StatefulWidget {
  final String? bookingId;
  final String? paymentMethod;
  final double? amount;
  
  const PaymentScreen({
    Key? key,
    this.bookingId,
    this.paymentMethod,
    this.amount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String _selectedPaymentMethod = '';
  String _selectedOption = '';
  
  // List of available e-wallets
  final List<Map<String, dynamic>> _ewallets = [
    {'id': 'touch_n_go', 'name': 'Touch N Go', 'logo': 'assets/images/payment/tng.png'},
    {'id': 'grab_pay', 'name': 'Grab Pay', 'logo': 'assets/images/payment/grabpay.png'},
    {'id': 'boost', 'name': 'Boost', 'logo': 'assets/images/payment/boost.png'},
    {'id': 'maybank_qr', 'name': 'MAE by Maybank', 'logo': 'assets/images/payment/maybank.png'},
  ];
  
  // List of available banks for FPX
  final List<Map<String, dynamic>> _banks = [
    {'id': 'maybank', 'name': 'Maybank', 'logo': 'assets/images/payment/maybank.png'},
    {'id': 'cimb', 'name': 'CIMB Bank', 'logo': 'assets/images/payment/cimb.png'},
    {'id': 'public_bank', 'name': 'Public Bank', 'logo': 'assets/images/payment/publicbank.png'},
    {'id': 'rhb', 'name': 'RHB Bank', 'logo': 'assets/images/payment/rhb.png'},
    {'id': 'hong_leong', 'name': 'Hong Leong Bank', 'logo': 'assets/images/payment/hongleong.png'},
    {'id': 'bank_islam', 'name': 'Bank Islam', 'logo': 'assets/images/payment/bankislam.png'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.paymentMethod ?? 'ewallet';
  }

  Future<void> _processPayment() async {
    if (_selectedOption.isEmpty) {
      ToastUtils.showErrorToast('Please select a payment option');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      // For a real app, this would call your payment gateway API
      // Example:
      // final result = await PaymentGateway.processPayment(
      //   bookingId: widget.bookingId,
      //   paymentMethod: _selectedPaymentMethod,
      //   paymentOption: _selectedOption,
      //   amount: widget.amount,
      // );
      
      // For demo, we'll just show success
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        SuccessDialog.showPaymentCompleted(
          context: context,
          onViewBooking: () {
            // Navigate to booking details
            if (widget.bookingId != null) {
              Routes.navigateAndRemoveUntil(
                context, 
                Routes.seekerBookingDetail,
                arguments: widget.bookingId,
              );
            } else {
              Routes.navigateAndRemoveUntil(context, Routes.seekerBookings);
            }
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastUtils.showErrorToast('Payment failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amount = widget.amount ?? 0.0;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.payment),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Payment amount header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Total Payment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Payment method selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodTab(
                    title: AppTexts.eWallet,
                    method: 'ewallet',
                    isSelected: _selectedPaymentMethod == 'ewallet',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentMethodTab(
                    title: 'Online Banking',
                    method: 'fpx',
                    isSelected: _selectedPaymentMethod == 'fpx',
                  ),
                ),
              ],
            ),
          ),
          
          // Payment options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _selectedPaymentMethod == 'ewallet'
                  ? _buildEwalletOptions()
                  : _buildBankOptions(),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomButton(
                  text: AppTexts.completePayment,
                  onPressed: _processPayment,
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
    );
  }
  
  // Tab for selecting payment method (E-wallet or FPX)
  Widget _buildPaymentMethodTab({
    required String title,
    required String method,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
          _selectedOption = ''; // Reset selection when changing methods
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  // E-wallet payment options
  Widget _buildEwalletOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.selectEWallet,
          style: AppStyles.subheadingStyle,
        ),
        const SizedBox(height: 16),
        
        // E-wallet options
        ..._ewallets.map((wallet) => _buildPaymentOption(
          title: wallet['name'],
          id: wallet['id'],
          logo: wallet['logo'],
        )).toList(),
        
        const SizedBox(height: 24),
        
        // E-wallet instructions
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Pay with E-wallet',
                  style: AppStyles.subheadingStyle,
                ),
                SizedBox(height: 12),
                Text(
                  '1. Select your preferred e-wallet above',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '2. Click "Complete Payment" to proceed',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '3. You will be redirected to your e-wallet app to confirm payment',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '4. Once payment is confirmed, you will be redirected back to Handy Buddy',
                  style: AppStyles.bodyTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Online Banking (FPX) options
  Widget _buildBankOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.selectBank,
          style: AppStyles.subheadingStyle,
        ),
        const SizedBox(height: 16),
        
        // Bank options
        ..._banks.map((bank) => _buildPaymentOption(
          title: bank['name'],
          id: bank['id'],
          logo: bank['logo'],
        )).toList(),
        
        const SizedBox(height: 24),
        
        // FPX instructions
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Pay with Online Banking',
                  style: AppStyles.subheadingStyle,
                ),
                SizedBox(height: 12),
                Text(
                  '1. Select your bank from the options above',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '2. Click "Complete Payment" to proceed',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '3. You will be redirected to your bank\'s login page',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '4. Log in to your online banking and confirm the payment',
                  style: AppStyles.bodyTextStyle,
                ),
                SizedBox(height: 8),
                Text(
                  '5. Once payment is confirmed, you will be redirected back to Handy Buddy',
                  style: AppStyles.bodyTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Individual payment option item (e-wallet or bank)
  Widget _buildPaymentOption({
    required String title,
    required String id,
    required String logo,
  }) {
    final bool isSelected = _selectedOption == id;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = id;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primaryExtraLight : Colors.white,
        ),
        child: Row(
          children: [
            // Logo/Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                logo,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: AppColors.backgroundLight,
                  child: const Icon(
                    Icons.account_balance,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Bank/E-wallet name
            Expanded(
              child: Text(
                title,
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            
            // Selection indicator
            Radio<String>(
              value: id,
              groupValue: _selectedOption,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedOption = value;
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