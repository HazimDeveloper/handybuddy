import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firestore_methods.dart';
import '../firebase/storage_methods.dart';
import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../utils/toast_util.dart';

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  all
}

enum BookingFilter {
  today,
  thisWeek,
  thisMonth,
  all
}

class BookingProvider with ChangeNotifier {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  final StorageMethods _storageMethods = StorageMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Current booking data
  List<BookingModel> _bookings = [];
  List<BookingModel> _filteredBookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;
  bool _hasMore = true;
  int _pageSize = 10;
  DocumentSnapshot? _lastDocument;
  
  // Booking creation data
  ServiceModel? _selectedService;
  UserModel? _selectedProvider;
  DateTime _scheduledDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _scheduledTime = TimeOfDay(hour: 10, minute: 0);
  String _address = '';
  String _contactNumber = '';
  String _paymentMethod = 'cod';
  String _specialInstructions = '';
  
  // Service evidence
  List<File> _beforeServiceImages = [];
  List<File> _afterServiceImages = [];
  
  // Current filter settings
  BookingStatus _statusFilter = BookingStatus.all;
  BookingFilter _dateFilter = BookingFilter.all;
  
  // Getters
  List<BookingModel> get bookings => _filteredBookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  
  ServiceModel? get selectedService => _selectedService;
  UserModel? get selectedProvider => _selectedProvider;
  DateTime get scheduledDate => _scheduledDate;
  TimeOfDay get scheduledTime => _scheduledTime;
  String get address => _address;
  String get contactNumber => _contactNumber;
  String get paymentMethod => _paymentMethod;
  String get specialInstructions => _specialInstructions;
  
  List<File> get beforeServiceImages => _beforeServiceImages;
  List<File> get afterServiceImages => _afterServiceImages;
  
  BookingStatus get statusFilter => _statusFilter;
  BookingFilter get dateFilter => _dateFilter;
  
  // Calculate combined date and time for scheduled service
  DateTime get combinedScheduledDateTime {
    return DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );
  }
  
  // Helper for booking progress percentage
  double getBookingProgress(BookingModel booking) {
    switch (booking.status) {
      case 'pending':
        return 0.25;
      case 'confirmed':
        return 0.5;
      case 'in_progress':
        return 0.75;
      case 'completed':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }
  
  // Check if user has active bookings
  bool get hasActiveBookings {
    return _bookings.any((booking) => 
        booking.status == 'pending' || 
        booking.status == 'confirmed' || 
        booking.status == 'in_progress');
  }
  
  // Get count of bookings by status
  int getBookingCountByStatus(String status) {
    return _bookings.where((booking) => booking.status == status).length;
  }
  
  // --------------- Fetching Bookings ---------------
  
  // Fetch bookings for current user (provider or seeker)
  Future<void> fetchBookings({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    try {
      _isLoading = true;
      if (refresh) {
        _lastDocument = null;
        _bookings = [];
        _hasMore = true;
      }
      notifyListeners();
      
      // Get user to determine role
      UserModel? user = await _firestoreMethods.getUserById(uid);
      
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      List<BookingModel> newBookings = [];
      
      if (user.isProvider) {
        // Fetch provider bookings
        newBookings = await _firestoreMethods.getProviderBookings(
          status: _statusFilter == BookingStatus.all ? null : _statusFilter.toString().split('.').last,
        );
      } else {
        // Fetch seeker bookings
        newBookings = await _firestoreMethods.getSeekerBookings(
          status: _statusFilter == BookingStatus.all ? null : _statusFilter.toString().split('.').last,
        );
      }
      
      // Add new bookings to the list
      if (refresh) {
        _bookings = newBookings;
      } else {
        _bookings.addAll(newBookings);
      }
      
      // Apply filters
      _applyFilters();
      
      _isLoading = false;
      if (newBookings.length < _pageSize) {
        _hasMore = false;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      ToastUtils.showErrorToast('Error fetching bookings: ${e.toString()}');
      notifyListeners();
    }
  }
  
  // Fetch more bookings (pagination)
  Future<void> fetchMoreBookings() async {
    if (_isLoading || !_hasMore) return;
    
    await fetchBookings();
  }
  
  // Fetch booking details by ID
  Future<BookingModel?> fetchBookingById(String bookingId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      BookingModel? booking = await _firestoreMethods.getBookingById(bookingId);
      
      if (booking != null) {
        _selectedBooking = booking;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return booking;
    } catch (e) {
      _isLoading = false;
      ToastUtils.showErrorToast('Error fetching booking details: ${e.toString()}');
      notifyListeners();
      return null;
    }
  }
  
  // Filter bookings by status and date
  void filterBookings({
    BookingStatus? status,
    BookingFilter? dateFilter,
  }) {
    if (status != null) {
      _statusFilter = status;
    }
    
    if (dateFilter != null) {
      _dateFilter = dateFilter;
    }
    
    _applyFilters();
    notifyListeners();
  }
  
  // Apply filters to the bookings list
  void _applyFilters() {
    _filteredBookings = List.from(_bookings);
    
    // Filter by status
    if (_statusFilter != BookingStatus.all) {
      String statusString = _statusFilter.toString().split('.').last;
      _filteredBookings = _filteredBookings.where((booking) {
        if (statusString == 'pending' && booking.status == 'pending') {
          return true;
        } else if (statusString == 'confirmed' && booking.status == 'confirmed') {
          return true;
        } else if (statusString == 'inProgress' && booking.status == 'in_progress') {
          return true;
        } else if (statusString == 'completed' && booking.status == 'completed') {
          return true;
        } else if (statusString == 'cancelled' && booking.status == 'cancelled') {
          return true;
        }
        return false;
      }).toList();
    }
    
    // Filter by date
    if (_dateFilter != BookingFilter.all) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      _filteredBookings = _filteredBookings.where((booking) {
        final bookingDate = booking.scheduledDate.toDate();
        final bookingDateOnly = DateTime(
          bookingDate.year,
          bookingDate.month,
          bookingDate.day,
        );
        
        if (_dateFilter == BookingFilter.today) {
          return bookingDateOnly.isAtSameMomentAs(today);
        } else if (_dateFilter == BookingFilter.thisWeek) {
          return bookingDateOnly.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
              bookingDateOnly.isBefore(startOfWeek.add(Duration(days: 7)));
        } else if (_dateFilter == BookingFilter.thisMonth) {
          return bookingDateOnly.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
              bookingDateOnly.month == now.month &&
              bookingDateOnly.year == now.year;
        }
        return true;
      }).toList();
    }
  }
  
  // Reset filters
  void resetFilters() {
    _statusFilter = BookingStatus.all;
    _dateFilter = BookingFilter.all;
    _applyFilters();
    notifyListeners();
  }
  
  // --------------- Booking Creation ---------------
  
  // Set service for booking
  void setSelectedService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }
  
  // Set provider for booking
  void setSelectedProvider(UserModel provider) {
    _selectedProvider = provider;
    notifyListeners();
  }
  
  // Set scheduled date for booking
  void setScheduledDate(DateTime date) {
    _scheduledDate = date;
    notifyListeners();
  }
  
  // Set scheduled time for booking
  void setScheduledTime(TimeOfDay time) {
    _scheduledTime = time;
    notifyListeners();
  }
  
  // Set address for booking
  void setAddress(String address) {
    _address = address;
    notifyListeners();
  }
  
  // Set contact number for booking
  void setContactNumber(String number) {
    _contactNumber = number;
    notifyListeners();
  }
  
  // Set payment method for booking
  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }
  
  // Set special instructions for booking
  void setSpecialInstructions(String instructions) {
    _specialInstructions = instructions;
    notifyListeners();
  }
  
  // Reset booking form
  void resetBookingForm() {
    _selectedService = null;
    _selectedProvider = null;
    _scheduledDate = DateTime.now().add(Duration(days: 1));
    _scheduledTime = TimeOfDay(hour: 10, minute: 0);
    _address = '';
    _contactNumber = '';
    _paymentMethod = 'cod';
    _specialInstructions = '';
    _beforeServiceImages = [];
    _afterServiceImages = [];
    notifyListeners();
  }
  
  // Check if booking form is valid
  bool get isBookingFormValid {
    return _selectedService != null &&
        _selectedProvider != null &&
        _address.isNotEmpty &&
        _contactNumber.isNotEmpty;
  }
  
  // Create a new booking
  Future<String> createBooking() async {
    if (!isBookingFormValid) {
      return 'Please fill in all required fields';
    }
    
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    if (_selectedService == null || _selectedProvider == null) {
      return 'Service or provider not selected';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Convert scheduled date and time to Timestamp
      Timestamp scheduledTimestamp = Timestamp.fromDate(combinedScheduledDateTime);
      
      // Create booking
      String result = await _firestoreMethods.createBooking(
        serviceId: _selectedService!.serviceId,
        providerId: _selectedProvider!.uid,
        scheduledDate: scheduledTimestamp,
        address: _address,
        contactNumber: _contactNumber,
        paymentMethod: _paymentMethod,
        specialInstructions: _specialInstructions.isNotEmpty ? _specialInstructions : null,
      );
      
      _isLoading = false;
      notifyListeners();
      
      if (result.length > 10) {  // If result is a booking ID (success)
        // Reset form after successful booking
        resetBookingForm();
        
        // Refresh bookings list
        await fetchBookings(refresh: true);
        
        return 'success';
      }
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // Create an emergency booking
  Future<String> createEmergencyBooking({
    required String emergencyDetails,
  }) async {
    if (_selectedService == null || _selectedProvider == null) {
      return 'Service or provider not selected';
    }
    
    if (_address.isEmpty || _contactNumber.isEmpty) {
      return 'Please provide address and contact number';
    }
    
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create emergency booking
      String result = await _firestoreMethods.createEmergencyBooking(
        serviceId: _selectedService!.serviceId,
        providerId: _selectedProvider!.uid,
        address: _address,
        contactNumber: _contactNumber,
        emergencyDetails: emergencyDetails,
      );
      
      _isLoading = false;
      notifyListeners();
      
      if (result.length > 10) {  // If result is a booking ID (success)
        // Reset form after successful booking
        resetBookingForm();
        
        // Refresh bookings list
        await fetchBookings(refresh: true);
        
        return 'success';
      }
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // Rebook a service (create new booking based on previous one)
  Future<String> rebookService(String previousBookingId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      String result = await _firestoreMethods.rebookService(previousBookingId);
      
      _isLoading = false;
      notifyListeners();
      
      if (result.length > 10) {  // If result is a booking ID (success)
        // Refresh bookings list
        await fetchBookings(refresh: true);
        
        return 'success';
      }
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // --------------- Booking Management ---------------
  
  // Update booking status (provider)
  Future<String> updateBookingStatus({
    required String bookingId,
    required String status,
    double? totalAmount,
    String? cancelReason,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      String result = await _firestoreMethods.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        totalAmount: totalAmount,
        cancelReason: cancelReason,
      );
      
      if (result == 'success') {
        // Update the booking in the local list
        await fetchBookingById(bookingId);
        await fetchBookings(refresh: true);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // Add before service images
  void addBeforeServiceImages(List<File> images) {
    _beforeServiceImages.addAll(images);
    notifyListeners();
  }
  
  // Add after service images
  void addAfterServiceImages(List<File> images) {
    _afterServiceImages.addAll(images);
    notifyListeners();
  }
  
  // Remove before service image
  void removeBeforeServiceImage(int index) {
    if (index >= 0 && index < _beforeServiceImages.length) {
      _beforeServiceImages.removeAt(index);
      notifyListeners();
    }
  }
  
  // Remove after service image
  void removeAfterServiceImage(int index) {
    if (index >= 0 && index < _afterServiceImages.length) {
      _afterServiceImages.removeAt(index);
      notifyListeners();
    }
  }
  
  // Upload before/after service images
  Future<String> uploadServiceEvidence(String bookingId) async {
    if (_beforeServiceImages.isEmpty || _afterServiceImages.isEmpty) {
      return 'Please add both before and after service images';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Upload images
      Map<String, List<String>> uploadResults = await _storageMethods.uploadBeforeAfterImages(
        bookingId: bookingId,
        beforeImages: _beforeServiceImages,
        afterImages: _afterServiceImages,
      );
      
      // Update booking with image URLs
      String result = await _firestoreMethods.updateBookingEvidence(
        bookingId: bookingId,
        beforeImages: uploadResults['before'] ?? [],
        afterImages: uploadResults['after'] ?? [],
      );
      
      if (result == 'success') {
        // Clear images
        _beforeServiceImages = [];
        _afterServiceImages = [];
        
        // Refresh booking details
        await fetchBookingById(bookingId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // Rate a completed service
  Future<String> rateService({
    required String bookingId,
    required String providerId,
    required double rating,
    String? review,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      String result = await _firestoreMethods.addRating(
        bookingId: bookingId,
        providerId: providerId,
        rating: rating,
        review: review,
      );
      
      if (result == 'success') {
        // Refresh booking details
        await fetchBookingById(bookingId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }
  
  // --------------- Booking Analytics ---------------
  
  // Get booking statistics for providers
  Map<String, dynamic> getProviderBookingStats() {
    int totalBookings = _bookings.length;
    int pendingBookings = getBookingCountByStatus('pending');
    int confirmedBookings = getBookingCountByStatus('confirmed');
    int inProgressBookings = getBookingCountByStatus('in_progress');
    int completedBookings = getBookingCountByStatus('completed');
    int cancelledBookings = getBookingCountByStatus('cancelled');
    
    double completionRate = totalBookings > 0 
        ? (completedBookings / totalBookings) * 100 
        : 0;
    
    double cancellationRate = totalBookings > 0 
        ? (cancelledBookings / totalBookings) * 100 
        : 0;
    
    return {
      'totalBookings': totalBookings,
      'pendingBookings': pendingBookings,
      'confirmedBookings': confirmedBookings,
      'inProgressBookings': inProgressBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
    };
  }
  
  // Get monthly booking data for charts
  Map<String, int> getMonthlyBookingData() {
    Map<String, int> monthlyData = {};
    
    for (var booking in _bookings) {
      DateTime date = booking.createdAt.toDate();
      String monthYear = '${date.month}/${date.year}';
      
      if (monthlyData.containsKey(monthYear)) {
        monthlyData[monthYear] = (monthlyData[monthYear] ?? 0) + 1;
      } else {
        monthlyData[monthYear] = 1;
      }
    }
    
    return monthlyData;
  }
  
  // Get booking statistics by category for providers
  Map<String, int> getBookingsByCategory() {
    Map<String, int> categoryData = {};
    
    for (var booking in _bookings) {
      // This requires extra processing to get the service category
      // You would need to fetch service details for each booking
      // This is a placeholder for the implementation
      String category = 'Unknown';
      
      if (categoryData.containsKey(category)) {
        categoryData[category] = (categoryData[category] ?? 0) + 1;
      } else {
        categoryData[category] = 1;
      }
    }
    
    return categoryData;
  }
  
  // --------------- Utilities ---------------
  
  // Format booking date
  String formatBookingDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Get status color
  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  
  // Check if booking date is today
  bool isBookingToday(BookingModel booking) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDate = booking.scheduledDate.toDate();
    final bookingDateOnly = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
    );
    
    return bookingDateOnly.isAtSameMomentAs(today);
  }
  
  // Check if booking is upcoming
  bool isBookingUpcoming(BookingModel booking) {
    if (booking.status != 'pending' && booking.status != 'confirmed') {
      return false;
    }
    
    final now = DateTime.now();
    final bookingDate = booking.scheduledDate.toDate();
    
    return bookingDate.isAfter(now);
  }
  
  // Check if booking is overdue
  bool isBookingOverdue(BookingModel booking) {
    if (booking.status != 'pending' && booking.status != 'confirmed') {
      return false;
    }
    
    final now = DateTime.now();
    final bookingDate = booking.scheduledDate.toDate();
    
    return bookingDate.isBefore(now);
  }
  
  // Get time remaining until booking
  String getTimeRemaining(BookingModel booking) {
    final now = DateTime.now();
    final bookingDate = booking.scheduledDate.toDate();
    
    if (bookingDate.isBefore(now)) {
      return 'Overdue';
    }
    
    final difference = bookingDate.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s)';
    } else {
      return '${difference.inMinutes} minute(s)';
    }
  }
}