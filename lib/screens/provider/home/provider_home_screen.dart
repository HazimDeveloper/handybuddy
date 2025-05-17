// lib/screens/provider/home/provider_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/providers/service_provider.dart' as service_provider;
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/cards/booking_card.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isLoading = true;
  UserModel? _provider;
  List<BookingModel> _pendingBookings = [];
  List<BookingModel> _todayBookings = [];
  Map<String, dynamic> _stats = {
    'totalEarnings': 0.0,
    'totalBookings': 0,
    'completedBookings': 0,
    'cancelledBookings': 0,
    'rating': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load provider data
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _provider = authProvider.user;

      if (_provider == null) {
        ToastUtils.showErrorToast('User data not available');
        return;
      }

      // Load bookings
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.fetchBookings(refresh: true);

      // Filter pending bookings
      bookingProvider.filterBookings(status: BookingStatus.pending);
      _pendingBookings = bookingProvider.bookings.take(3).toList(); // Take top 3

      // Filter today's bookings
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime tomorrow = today.add(const Duration(days: 1));

      bookingProvider.filterBookings(status: BookingStatus.all);
      _todayBookings = bookingProvider.bookings.where((booking) {
        final bookingDate = booking.scheduledDate.toDate();
        final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
        return bookingDay.isAtSameMomentAs(today) && 
               (booking.isConfirmed || booking.isInProgress);
      }).toList();

      // Calculate stats
      _calculateStats(bookingProvider.bookings);
    } catch (e) {
      ToastUtils.showErrorToast('Failed to load data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStats(List<BookingModel> bookings) {
    double totalEarnings = 0;
    int totalBookings = bookings.length;
    int completedBookings = 0;
    int cancelledBookings = 0;

    for (var booking in bookings) {
      if (booking.isCompleted) {
        completedBookings++;
        totalEarnings += booking.totalAmount;
      } else if (booking.isCancelled) {
        cancelledBookings++;
      }
    }

    _stats = {
      'totalEarnings': totalEarnings,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'rating': _provider?.rating ?? 0.0,
    };
  }

  void _navigateToManageServices() {
    Routes.navigateTo(context, Routes.manageService);
  }

  void _navigateToBookings() {
    Routes.navigateTo(context, Routes.providerBookings);
  }

  void _navigateToEarnings() {
    Routes.navigateTo(context, Routes.providerEarnings);
  }

  void _navigateToProfile() {
    Routes.navigateTo(context, Routes.providerProfile);
  }

  void _navigateToBookingDetails(String bookingId) {
    Routes.navigateTo(
      context,
      Routes.providerBookingDetail,
      arguments: bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: AppColors.primary,
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(),
                    ),
                  ),
                  
                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Actions
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          
                          // Quick Stats
                          _buildQuickStats(),
                          const SizedBox(height: 24),
                          
                          // Pending Bookings Section
                          _buildPendingBookings(),
                          const SizedBox(height: 24),
                          
                          // Today's Schedule
                          _buildTodaySchedule(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Provider Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: _provider?.profileImageUrl != null && 
                                _provider!.profileImageUrl!.isNotEmpty
                    ? NetworkImage(_provider!.profileImageUrl!)
                    : null,
                child: _provider?.profileImageUrl == null || 
                        _provider!.profileImageUrl!.isEmpty
                    ? Text(
                        _provider?.initials ?? 'HB',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Provider Name & Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTexts.welcomeProvider}${_provider?.firstName ?? 'Provider'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _provider?.isVerified ?? false
                                ? Colors.green
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _provider?.isVerified ?? false
                              ? 'Verified Provider'
                              : 'Pending Verification',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Profile Button
              IconButton(
                icon: const Icon(
                  Icons.account_circle,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: _navigateToProfile,
              ),
            ],
          ),
          
          const Spacer(),
          
          // Category Badge
          if (_provider?.category != null && _provider!.category!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _provider!.formattedCategory,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: AppStyles.subheadingStyle,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Manage Services
            _buildActionButton(
              icon: Icons.home_repair_service,
              color: AppColors.primary,
              label: 'Manage\nServices',
              onTap: _navigateToManageServices,
            ),
            
            // View Bookings
            _buildActionButton(
              icon: Icons.calendar_today,
              color: AppColors.secondary,
              label: 'View\nBookings',
              onTap: _navigateToBookings,
            ),
            
            // Earnings
            _buildActionButton(
              icon: Icons.attach_money,
              color: AppColors.success,
              label: 'My\nEarnings',
              onTap: _navigateToEarnings,
            ),
            
            // Profile
            _buildActionButton(
              icon: Icons.person,
              color: AppColors.info,
              label: 'My\nProfile',
              onTap: _navigateToProfile,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppTexts.quickStats,
          style: AppStyles.subheadingStyle,
        ),
        const SizedBox(height: 16),
        Container(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Earnings & Rating Row
              Row(
                children: [
                  // Earnings
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          AppTexts.totalEarnings,
                          style: AppStyles.labelStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM ${_stats['totalEarnings'].toStringAsFixed(2)}',
                          style: AppStyles.headingMediumStyle.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rating
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          AppTexts.rating,
                          style: AppStyles.labelStyle,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppColors.warning,
                              size: 24,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _stats['rating'].toStringAsFixed(1),
                              style: AppStyles.headingMediumStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Booking Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Total Bookings
                  _buildStatColumn(
                    value: _stats['totalBookings'].toString(),
                    label: 'Total',
                    icon: Icons.book,
                    color: AppColors.primary,
                  ),
                  
                  // Completed
                  _buildStatColumn(
                    value: _stats['completedBookings'].toString(),
                    label: 'Completed',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                  
                  // Cancelled
                  _buildStatColumn(
                    value: _stats['cancelledBookings'].toString(),
                    label: 'Cancelled',
                    icon: Icons.cancel,
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppStyles.headingMediumStyle,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.captionStyle,
        ),
      ],
    );
  }

  Widget _buildPendingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppTexts.pendingBookings,
              style: AppStyles.subheadingStyle,
            ),
            if (_pendingBookings.isNotEmpty)
              TextButton(
                onPressed: _navigateToBookings,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_pendingBookings.isEmpty)
          _buildEmptyBookingState(
            message: 'You have no pending bookings at the moment.',
            buttonText: 'View All Bookings',
            onPressed: _navigateToBookings,
          )
        else
          Column(
            children: _pendingBookings.map((booking) {
              return BookingCard(
                booking: booking,
                userType: 'provider',
                onViewDetails: () => _navigateToBookingDetails(booking.bookingId),
                showActions: false,
                isCompact: true,
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTodaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTexts.todaySchedule,
              style: AppStyles.subheadingStyle,
            ),
            if (_todayBookings.isNotEmpty)
              TextButton(
                onPressed: _navigateToBookings,
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_todayBookings.isEmpty)
          _buildEmptyBookingState(
            message: 'You have no scheduled services for today.',
            buttonText: 'Check Calendar',
            onPressed: _navigateToBookings,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayBookings.length,
            itemBuilder: (context, index) {
              final booking = _todayBookings[index];
              return _buildScheduleCard(booking);
            },
          ),
      ],
    );
  }

  Widget _buildScheduleCard(BookingModel booking) {
    final DateTime scheduledTime = booking.scheduledDate.toDate();
    final String formattedTime = DateFormat('h:mm a').format(scheduledTime);
    final bool isUpcoming = scheduledTime.isAfter(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToBookingDetails(booking.bookingId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Column
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUpcoming 
                      ? AppColors.primaryLight 
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: isUpcoming 
                          ? AppColors.primary 
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedTime,
                      style: AppStyles.captionBoldStyle.copyWith(
                        color: isUpcoming 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Booking Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking #${booking.bookingId.substring(0, 8)}',
                      style: AppStyles.bodyTextBoldStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.address,
                      style: AppStyles.bodySmallStyle.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client: ${booking.seekerId.substring(0, 8)}',
                      style: AppStyles.captionStyle,
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.getStatusColor(booking.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  booking.formattedStatus,
                  style: AppStyles.captionBoldStyle.copyWith(
                    color: AppColors.getStatusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBookingState({
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          const Icon(
            Icons.event_available,
            color: AppColors.textLight,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          custom_outlined.OutlinedButton(
            text: buttonText,
            onPressed: onPressed,
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}