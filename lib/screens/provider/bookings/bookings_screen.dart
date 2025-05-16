// lib/screens/provider/bookings/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/providers/service_provider.dart' as service_provider;
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/cards/booking_card.dart';
import 'package:handy_buddy/widgets/inputs/search_input.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  BookingFilter _dateFilter = BookingFilter.all;
  
  // Tab indices corresponding to booking statuses
  final List<BookingStatus> _statusFilters = [
    BookingStatus.all,
    BookingStatus.pending,
    BookingStatus.confirmed,
    BookingStatus.inProgress,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];
  
  final List<String> _tabLabels = [
    'All',
    'Pending',
    'Confirmed',
    'In Progress',
    'Completed',
    'Cancelled',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load bookings when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      return;
    }
    
    setState(() {
      // Update the status filter based on the current tab
      final status = _statusFilters[_tabController.index];
      
      // Only reload if the status filter has changed
      if (Provider.of<BookingProvider>(context, listen: false).statusFilter != status) {
        _loadBookings(status: status);
      }
    });
  }
  
  Future<void> _loadBookings({
    BookingStatus? status,
    BookingFilter? dateFilter,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;
    
    setState(() {
      _isLoading = true;
      if (refresh) {
        _isRefreshing = true;
      }
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // Apply filters
      bookingProvider.filterBookings(
        status: status ?? _statusFilters[_tabController.index],
        dateFilter: dateFilter ?? _dateFilter,
      );
      
      // Fetch bookings
      await bookingProvider.fetchBookings(refresh: true);
    } catch (e) {
      ToastUtils.showErrorToast('Error loading bookings: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
        if (refresh) {
          _isRefreshing = false;
        }
      });
    }
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }
  
  void _onFilterTap() {
    _showFilterBottomSheet();
  }
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Bookings',
                        style: AppStyles.subheadingStyle,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Date filter options
                  const Text(
                    'Date Range',
                    style: AppStyles.labelStyle,
                  ),
                  const SizedBox(height: 10),
                  
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildFilterChip(
                        label: 'All Time',
                        selected: _dateFilter == BookingFilter.all,
                        onSelected: (selected) {
                          setModalState(() {
                            _dateFilter = BookingFilter.all;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Today',
                        selected: _dateFilter == BookingFilter.today,
                        onSelected: (selected) {
                          setModalState(() {
                            _dateFilter = BookingFilter.today;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'This Week',
                        selected: _dateFilter == BookingFilter.thisWeek,
                        onSelected: (selected) {
                          setModalState(() {
                            _dateFilter = BookingFilter.thisWeek;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'This Month',
                        selected: _dateFilter == BookingFilter.thisMonth,
                        onSelected: (selected) {
                          setModalState(() {
                            _dateFilter = BookingFilter.thisMonth;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Apply filter button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _loadBookings(dateFilter: _dateFilter, refresh: true);
                    },
                    child: const Text('Apply Filters'),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Reset filters button
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _dateFilter = BookingFilter.all;
                      });
                    },
                    child: const Text('Reset Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required void Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppColors.backgroundLight,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  // Navigate to booking details
  void _viewBookingDetails(String bookingId) {
    Routes.navigateTo(
      context,
      Routes.providerBookingDetail,
      arguments: bookingId,
    );
  }
  
  // Handle booking cancellation
  Future<void> _cancelBooking(BookingModel booking) async {
    // Show cancellation dialog and get reason
    final reason = await _showCancellationDialog();
    if (reason == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final result = await bookingProvider.updateBookingStatus(
        bookingId: booking.bookingId,
        status: 'cancelled',
        cancelReason: reason,
      );
      
      if (result == 'success') {
        ToastUtils.showInfoToast('Booking cancelled successfully');
        _loadBookings(refresh: true);
      } else {
        ToastUtils.showErrorToast('Failed to cancel booking: $result');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error cancelling booking: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show cancellation dialog
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
  
  // Complete a booking
  Future<void> _completeBooking(BookingModel booking) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      
      // If booking is pending, confirm it first
      if (booking.isPending) {
        final confirmResult = await bookingProvider.updateBookingStatus(
          bookingId: booking.bookingId,
          status: 'confirmed',
          totalAmount: 0, // This will be updated when provider completes
        );
        
        if (confirmResult != 'success') {
          ToastUtils.showErrorToast('Failed to confirm booking: $confirmResult');
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // After confirming, start the service
        final startResult = await bookingProvider.updateBookingStatus(
          bookingId: booking.bookingId,
          status: 'in_progress',
        );
        
        if (startResult != 'success') {
          ToastUtils.showErrorToast('Failed to start service: $startResult');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      } else if (booking.isConfirmed) {
        // If booking is confirmed, start the service
        final startResult = await bookingProvider.updateBookingStatus(
          bookingId: booking.bookingId,
          status: 'in_progress',
        );
        
        if (startResult != 'success') {
          ToastUtils.showErrorToast('Failed to start service: $startResult');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }
      
      // If booking is in progress, complete it
      if (booking.isInProgress || booking.status == 'in_progress') {
        final completeResult = await bookingProvider.updateBookingStatus(
          bookingId: booking.bookingId,
          status: 'completed',
        );
        
        if (completeResult == 'success') {
          ToastUtils.showSuccessToast('Booking completed successfully');
          
          // Navigate to booking details for evidence upload
          if (mounted) {
            _loadBookings(refresh: true);
            Routes.navigateTo(
              context,
              Routes.providerBookingDetail,
              arguments: booking.bookingId,
            );
          }
        } else {
          ToastUtils.showErrorToast('Failed to complete booking: $completeResult');
        }
      } else {
        _loadBookings(refresh: true);
        ToastUtils.showSuccessToast('Booking status updated successfully');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error updating booking: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _tabLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: SearchInput(
              hintText: 'Search bookings...',
              onSearch: _onSearch,
              backgroundColor: Colors.white,
              showFilterButton: true,
              onFilterTap: _onFilterTap,
            ),
          ),
          
          // Date filter chip if active
          if (_dateFilter != BookingFilter.all)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: AppColors.backgroundLight,
              child: Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(
                      _getDateFilterLabel(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: AppColors.primaryLight,
                    deleteIconColor: AppColors.primary,
                    onDeleted: () {
                      setState(() {
                        _dateFilter = BookingFilter.all;
                      });
                      _loadBookings(dateFilter: BookingFilter.all, refresh: true);
                    },
                  ),
                ],
              ),
            ),
          
          // Bookings List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadBookings(refresh: true),
              child: Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  final bookings = bookingProvider.bookings;
                  
                  // Filter bookings by search query if needed
                  final filteredBookings = _searchQuery.isEmpty
                      ? bookings
                      : bookings.where((booking) {
                          return booking.bookingId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              booking.address.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();
                  
                  if (_isRefreshing) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (bookings.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  if (filteredBookings.isEmpty) {
                    return _buildNoResultsState();
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return BookingCard(
                        booking: booking,
                        userType: 'provider',
                        onViewDetails: () => _viewBookingDetails(booking.bookingId),
                        onCancel: booking.canBeCancelled
                            ? () => _cancelBooking(booking)
                            : null,
                        onComplete: booking.isPending || booking.isConfirmed || booking.isInProgress
                            ? () => _completeBooking(booking)
                            : null,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
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
          const Text(
            'No Bookings Found',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            onPressed: () => _loadBookings(refresh: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'No bookings match your search criteria',
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text('Clear Search'),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        ],
      ),
    );
  }
  
  String _getEmptyStateMessage() {
    final status = _statusFilters[_tabController.index];
    
    switch (status) {
      case BookingStatus.pending:
        return 'You have no pending bookings at the moment';
      case BookingStatus.confirmed:
        return 'You have no confirmed bookings at the moment';
      case BookingStatus.inProgress:
        return 'You have no bookings in progress at the moment';
      case BookingStatus.completed:
        return 'You have not completed any bookings yet';
      case BookingStatus.cancelled:
        return 'You have no cancelled bookings';
      default:
        return 'You have no bookings yet';
    }
  }
  
  String _getDateFilterLabel() {
    switch (_dateFilter) {
      case BookingFilter.today:
        return 'Today';
      case BookingFilter.thisWeek:
        return 'This Week';
      case BookingFilter.thisMonth:
        return 'This Month';
      default:
        return 'All Time';
    }
  }
}