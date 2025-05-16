// lib/screens/provider/earnings/earnings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/booking_model.dart';
import 'package:handy_buddy/providers/booking_provider.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _earningsData = {};
  List<BookingModel> _completedBookings = [];
  String _selectedPeriod = 'month'; // 'week', 'month', 'year', 'all'
  
  // Date filters
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  
  // Statistics
  double _totalEarnings = 0;
  int _totalCompletedJobs = 0;
  double _averageRating = 0;
  double _averageEarningsPerJob = 0;
  
  @override
  void initState() {
    super.initState();
    _loadEarningsData();
  }
  
  Future<void> _loadEarningsData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load completed bookings
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      await bookingProvider.fetchBookings(refresh: true);
      
      // Filter only completed bookings
      bookingProvider.filterBookings(status: BookingStatus.completed);
      await bookingProvider.fetchBookings(refresh: true);
      _completedBookings = bookingProvider.bookings;
      
      // Calculate earnings statistics
      _calculateEarningsStatistics();
      
      // Get provider rating
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final provider = authProvider.user;
      if (provider != null) {
        _averageRating = provider.rating ?? 0;
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error loading earnings data: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _calculateEarningsStatistics() {
    // Filter bookings by selected period
    List<BookingModel> filteredBookings = _filterBookingsByPeriod(_completedBookings);
    
    // Calculate total earnings
    _totalEarnings = filteredBookings.fold(
      0, (sum, booking) => sum + booking.totalAmount);
    
    // Count total completed jobs
    _totalCompletedJobs = filteredBookings.length;
    
    // Calculate average earnings per job
    _averageEarningsPerJob = _totalCompletedJobs > 0 
        ? _totalEarnings / _totalCompletedJobs 
        : 0;
    
    // Group earnings by date for chart
    _earningsData = _groupEarningsByDate(filteredBookings);
  }
  
  List<BookingModel> _filterBookingsByPeriod(List<BookingModel> bookings) {
    DateTime now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'week':
        _startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'all':
        _startDate = DateTime(2020, 1, 1); // Far in the past
        _endDate = now;
        break;
    }
    
    return bookings.where((booking) {
      DateTime bookingDate = booking.completedAt?.toDate() ?? now;
      return bookingDate.isAfter(_startDate) && 
             bookingDate.isBefore(_endDate.add(const Duration(days: 1)));
    }).toList();
  }
  
  Map<String, dynamic> _groupEarningsByDate(List<BookingModel> bookings) {
    Map<String, double> dailyEarnings = {};
    
    // Group by day
    for (var booking in bookings) {
      if (booking.completedAt == null) continue;
      
      DateTime date = booking.completedAt!.toDate();
      String dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      if (dailyEarnings.containsKey(dateKey)) {
        dailyEarnings[dateKey] = (dailyEarnings[dateKey] ?? 0) + booking.totalAmount;
      } else {
        dailyEarnings[dateKey] = booking.totalAmount;
      }
    }
    
    // Sort by date
    List<MapEntry<String, double>> sortedEntries = dailyEarnings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    // Convert to list format for chart
    List<Map<String, dynamic>> chartData = [];
    for (var entry in sortedEntries) {
      DateTime date = DateFormat('yyyy-MM-dd').parse(entry.key);
      chartData.add({
        'date': date,
        'amount': entry.value,
      });
    }
    
    return {
      'dailyEarnings': dailyEarnings,
      'chartData': chartData,
    };
  }
  
  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    
    _calculateEarningsStatistics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Earnings'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarningsData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Earnings Card
                    _buildTotalEarningsCard(),
                    
                    // Period Selection
                    _buildPeriodSelection(),
                    
                    // Statistics Cards
                    _buildStatisticsSection(),
                    
                    // Earnings Chart
                    _buildEarningsChart(),
                    
                    // Recent Payments
                    _buildRecentPaymentsSection(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildTotalEarningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            AppTexts.totalEarnings,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${_totalEarnings.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPeriodText(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelection() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppTexts.selectPeriod,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildPeriodButton('Today', 'today'),
              _buildPeriodButton('Week', 'week'),
              _buildPeriodButton('Month', 'month'),
              _buildPeriodButton('Year', 'year'),
              _buildPeriodButton('All', 'all'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(String label, String period) {
    bool isSelected = _selectedPeriod == period;
    
    return InkWell(
      onTap: () => _changePeriod(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: AppTexts.jobs,
                  value: _totalCompletedJobs.toString(),
                  icon: Icons.work,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: AppTexts.averageRate,
                  value: 'RM ${_averageEarningsPerJob.toStringAsFixed(2)}',
                  icon: Icons.monetization_on,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: AppTexts.rating,
                  value: _averageRating.toStringAsFixed(1),
                  icon: Icons.star,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEarningsChart() {
    List<Map<String, dynamic>> chartData = _earningsData['chartData'] ?? [];
    
    if (chartData.isEmpty) {
      return _buildEmptyChart();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Overview',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
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
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(chartData),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'RM ${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Format date for display
                        if (value < 0 || value >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        DateTime date = chartData[value.toInt()]['date'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _getDateLabel(date),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'RM ${value.toInt()}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: List.generate(
                  chartData.length,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: chartData[index]['amount'],
                        color: AppColors.primary,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _getMaxY(chartData),
                          color: AppColors.borderLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyChart() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings Overview',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bar_chart,
                    color: AppColors.textLight,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No earnings data for this period',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentPaymentsSection() {
    List<BookingModel> recentPayments = List<BookingModel>.from(_completedBookings)
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
    
    if (recentPayments.isEmpty) {
      return const SizedBox.shrink();
    }
    
    // Take only the most recent payments (up to 5)
    recentPayments = recentPayments.take(5).toList();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppTexts.recentPayments,
                style: AppStyles.subheadingStyle,
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full payment history
                  ToastUtils.showInfoToast('Coming soon!');
                },
                child: const Text(
                  AppTexts.viewFullPaymentHistory,
                  style: TextStyle(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recentPayments.map(_buildPaymentItem).toList(),
        ],
      ),
    );
  }
  
  Widget _buildPaymentItem(BookingModel booking) {
    final DateTime paymentDate = booking.completedAt!.toDate();
    final String formattedDate = DateFormat('dd MMM yyyy').format(paymentDate);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payment,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking #${booking.bookingId.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'RM ${booking.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  double _getMaxY(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return 100;
    
    double maxY = 0;
    for (var data in chartData) {
      if (data['amount'] > maxY) {
        maxY = data['amount'];
      }
    }
    
    // Round up to nearest 10
    return ((maxY / 10).ceil() * 10 + 10).toDouble();
  }
  
  String _getDateLabel(DateTime date) {
    // Format based on selected period
    switch (_selectedPeriod) {
      case 'today':
        return DateFormat('HH:mm').format(date);
      case 'week':
        return DateFormat('E').format(date); // Day of week
      case 'month':
        return DateFormat('d').format(date); // Day of month
      case 'year':
        return DateFormat('MMM').format(date); // Month name
      case 'all':
        return DateFormat('MMM yy').format(date); // Month and year
      default:
        return DateFormat('d/M').format(date);
    }
  }
  
  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Today, ${DateFormat('d MMM yyyy').format(DateTime.now())}';
      case 'week':
        return 'This Week (${DateFormat('d MMM').format(_startDate)} - ${DateFormat('d MMM').format(_endDate)})';
      case 'month':
        return 'This Month (${DateFormat('MMMM yyyy').format(_startDate)})';
      case 'year':
        return 'This Year (${DateFormat('yyyy').format(_startDate)})';
      case 'all':
        return 'All Time Earnings';
      default:
        return '';
    }
  }
}