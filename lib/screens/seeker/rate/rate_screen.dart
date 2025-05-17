// lib/screens/seeker/rate/rate_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/dialogs/success_dialog.dart';

class RateScreen extends StatefulWidget {
  final String bookingId;
  final String providerId;
  
  const RateScreen({
    Key? key,
    required this.bookingId,
    required this.providerId,
  }) : super(key: key);

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  BookingModel? _booking;
  UserModel? _provider;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch booking details
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _booking = await bookingProvider.fetchBookingById(widget.bookingId);
      
      // Fetch provider details
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _provider = await authProvider.getUserById(widget.providerId);
    } catch (e) {
      ToastUtils.showErrorToast('Error loading data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRating() async {
    if (_rating < 1.0) {
      ToastUtils.showErrorToast('Please select a rating');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final result = await bookingProvider.rateService(
        bookingId: widget.bookingId,
        providerId: widget.providerId,
        rating: _rating,
        review: _commentController.text.trim().isNotEmpty 
            ? _commentController.text.trim() 
            : null,
      );
      
      if (result == 'success') {
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        ToastUtils.showErrorToast('Failed to submit rating: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error submitting rating: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        title: AppTexts.thankYou,
        message: AppTexts.ratingSubmitted,
        buttonText: 'Done',
        onButtonPressed: () {
          // Navigate back to booking details or booking list
          Navigator.pop(context); // Close dialog
          Routes.navigateAndRemoveUntil(
            context, 
            Routes.seekerBookings,
          );
        },
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 1) {
      return AppTexts.poor;
    } else if (rating <= 2) {
      return AppTexts.fair;
    } else if (rating <= 3) {
      return AppTexts.good;
    } else if (rating <= 4) {
      return AppTexts.veryGood;
    } else {
      return AppTexts.excellent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppTexts.rateService),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Provider Info Card
                  if (_provider != null) ...[
                    Container(
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: _provider!.profileImageUrl != null 
                                ? NetworkImage(_provider!.profileImageUrl!) 
                                : null,
                            child: _provider!.profileImageUrl == null
                                ? Text(
                                    _provider!.initials,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _provider!.fullName,
                                  style: AppStyles.subheadingStyle,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _provider!.formattedCategory,
                                  style: AppStyles.captionStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Rate Experience Text
                  Text(
                    AppTexts.rateExperience,
                    style: AppStyles.bodyTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      final isHalfStar = _rating > index && _rating < starValue;
                      final isFullStar = _rating >= starValue;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = starValue;
                          });
                        },
                        child: Icon(
                          isFullStar
                              ? Icons.star
                              : isHalfStar
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: AppColors.warning,
                          size: 48,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  
                  // Rating Text
                  Text(
                    '${_rating.toStringAsFixed(1)} - ${_getRatingText(_rating)}',
                    style: AppStyles.subheadingStyle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Comment Field
                  Container(
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
                          AppTexts.additionalComments,
                          style: AppStyles.bodyTextMediumStyle,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Share your experience with this provider...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2.0,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  CustomButton(
                    text: AppTexts.submitRating,
                    onPressed: _submitRating,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
    );
  }
}