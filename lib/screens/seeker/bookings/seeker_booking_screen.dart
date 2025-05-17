// lib/screens/seeker/bookings/seeker_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/widgets/cards/booking_card.dart';

class SeekerBookingScreen extends StatefulWidget {
  const SeekerBookingScreen({Key? key}) : super(key: key);

  @override
  State<SeekerBookingScreen> createState() => _SeekerBookingScreenState();
}

class _SeekerBookingScreenState extends State<SeekerBookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load bookings when screen initializes
    _loadBookings();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });
    
    // Here we would fetch bookings from the provider
    // For now, we'll just simulate loading time
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList('upcoming'),
                _buildBookingList('completed'),
                _buildBookingList('cancelled'),
              ],
            ),
    );
  }
  
  Widget _buildBookingList(String status) {
    // This is a placeholder. In a real app, you'd filter bookings by status
    final hasBookings = status != 'cancelled'; // Just for demo
    
    if (!hasBookings) {
      return _buildEmptyState(status);
    }
    
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3, // Placeholder count
        itemBuilder: (context, index) {
          // This is a placeholder. In a real app, you'd use real booking data
          return BookingCard(
            booking: BookingModel( // Placeholder booking data
              bookingId: 'booking-${status}-$index',
              serviceId: 'service-$index',
              providerId: 'provider-$index',
              seekerId: 'seeker-1',
              status: status == 'upcoming' ? 'confirmed' : status,
              scheduledDate: DateTime.now().add(const Duration(days: 1)).microsecondsSinceEpoch as dynamic,
              createdAt: DateTime.now().microsecondsSinceEpoch as dynamic,
              address: '123 Main St, City',
              contactNumber: '123-456-7890',
              paymentMethod: 'cod',
              isEmergency: false,
              totalAmount: 125.0,
            ),
            userType: 'seeker',
            onViewDetails: () {
              // Navigate to booking details
            },
            onCancel: status == 'upcoming' ? () {
              // Show cancellation dialog
            } : null,
            onRebook: status == 'completed' ? () {
              // Navigate to rebook screen
            } : null,
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState(String status) {
    String message;
    
    switch (status) {
      case 'upcoming':
        message = 'You have no upcoming bookings';
        break;
      case 'completed':
        message = 'You have no completed bookings yet';
        break;
      case 'cancelled':
        message = 'You have no cancelled bookings';
        break;
      default:
        message = 'No bookings found';
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_bookings.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}