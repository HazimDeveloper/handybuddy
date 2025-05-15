import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String serviceId;
  final String providerId;
  final String seekerId;
  final String status; // pending, confirmed, in_progress, completed, cancelled
  final Timestamp scheduledDate;
  final Timestamp createdAt;
  final String address;
  final String contactNumber;
  final String paymentMethod; // cod, fpx, ewallet
  final String? specialInstructions;
  final bool isEmergency;
  final Timestamp? completedAt;
  final Timestamp? cancelledAt;
  final String? cancelReason;
  final double totalAmount;
  
  // Optional fields for extended functionality
  final List<String>? beforeServiceImages;
  final List<String>? afterServiceImages;
  final Map<String, dynamic>? paymentDetails;
  final String? providerNotes;
  final Map<String, dynamic>? locationCoordinates;
  final double? rating;
  final String? reviewComment;
  final bool isRebooked;
  final String? parentBookingId; // For rebooked services

  BookingModel({
    required this.bookingId,
    required this.serviceId,
    required this.providerId,
    required this.seekerId,
    required this.status,
    required this.scheduledDate,
    required this.createdAt,
    required this.address,
    required this.contactNumber,
    required this.paymentMethod,
    this.specialInstructions,
    required this.isEmergency,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    required this.totalAmount,
    this.beforeServiceImages,
    this.afterServiceImages,
    this.paymentDetails,
    this.providerNotes,
    this.locationCoordinates,
    this.rating,
    this.reviewComment,
    this.isRebooked = false,
    this.parentBookingId,
  });

  // Create booking model from Firestore document snapshot
  factory BookingModel.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    
    return BookingModel(
      bookingId: data['bookingId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      providerId: data['providerId'] ?? '',
      seekerId: data['seekerId'] ?? '',
      status: data['status'] ?? 'pending',
      scheduledDate: data['scheduledDate'] ?? Timestamp.now(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      paymentMethod: data['paymentMethod'] ?? 'cod',
      specialInstructions: data['specialInstructions'],
      isEmergency: data['isEmergency'] ?? false,
      completedAt: data['completedAt'],
      cancelledAt: data['cancelledAt'],
      cancelReason: data['cancelReason'],
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      beforeServiceImages: data['beforeServiceImages'] != null 
          ? List<String>.from(data['beforeServiceImages']) 
          : null,
      afterServiceImages: data['afterServiceImages'] != null 
          ? List<String>.from(data['afterServiceImages']) 
          : null,
      paymentDetails: data['paymentDetails'],
      providerNotes: data['providerNotes'],
      locationCoordinates: data['locationCoordinates'],
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      reviewComment: data['reviewComment'],
      isRebooked: data['isRebooked'] ?? false,
      parentBookingId: data['parentBookingId'],
    );
  }

  // Convert to a map that can be stored in Firestore
  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'serviceId': serviceId,
      'providerId': providerId,
      'seekerId': seekerId,
      'status': status,
      'scheduledDate': scheduledDate,
      'createdAt': createdAt,
      'address': address,
      'contactNumber': contactNumber,
      'paymentMethod': paymentMethod,
      'specialInstructions': specialInstructions,
      'isEmergency': isEmergency,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancelReason': cancelReason,
      'totalAmount': totalAmount,
      'beforeServiceImages': beforeServiceImages,
      'afterServiceImages': afterServiceImages,
      'paymentDetails': paymentDetails,
      'providerNotes': providerNotes,
      'locationCoordinates': locationCoordinates,
      'rating': rating,
      'reviewComment': reviewComment,
      'isRebooked': isRebooked,
      'parentBookingId': parentBookingId,
    };
  }

  // Create a copy of the booking with updated fields
  BookingModel copyWith({
    String? bookingId,
    String? serviceId,
    String? providerId,
    String? seekerId,
    String? status,
    Timestamp? scheduledDate,
    Timestamp? createdAt,
    String? address,
    String? contactNumber,
    String? paymentMethod,
    String? specialInstructions,
    bool? isEmergency,
    Timestamp? completedAt,
    Timestamp? cancelledAt,
    String? cancelReason,
    double? totalAmount,
    List<String>? beforeServiceImages,
    List<String>? afterServiceImages,
    Map<String, dynamic>? paymentDetails,
    String? providerNotes,
    Map<String, dynamic>? locationCoordinates,
    double? rating,
    String? reviewComment,
    bool? isRebooked,
    String? parentBookingId,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      seekerId: seekerId ?? this.seekerId,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      isEmergency: isEmergency ?? this.isEmergency,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      totalAmount: totalAmount ?? this.totalAmount,
      beforeServiceImages: beforeServiceImages ?? this.beforeServiceImages,
      afterServiceImages: afterServiceImages ?? this.afterServiceImages,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      providerNotes: providerNotes ?? this.providerNotes,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      rating: rating ?? this.rating,
      reviewComment: reviewComment ?? this.reviewComment,
      isRebooked: isRebooked ?? this.isRebooked,
      parentBookingId: parentBookingId ?? this.parentBookingId,
    );
  }

  // Helper methods for status checks
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  // Helper method to check if booking can be canceled
  bool get canBeCancelled => isPending || isConfirmed;
  
  // Helper method to check if booking can be rated
  bool get canBeRated => isCompleted && rating == null;

  // Get formatted date string
  String getFormattedDate() {
    DateTime date = scheduledDate.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  // Get formatted status with proper capitalization
  String get formattedStatus {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.substring(0, 1).toUpperCase() + status.substring(1);
    }
  }
  
  // Calculate time remaining until scheduled date
  String getTimeRemaining() {
    final now = DateTime.now();
    final scheduled = scheduledDate.toDate();
    
    if (scheduled.isBefore(now)) {
      return 'Overdue';
    }
    
    final difference = scheduled.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s)';
    } else {
      return '${difference.inMinutes} minute(s)';
    }
  }
  
  // Get payment method in readable format
  String get formattedPaymentMethod {
    switch (paymentMethod) {
      case 'cod':
        return 'Cash on Delivery';
      case 'fpx':
        return 'FPX';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }
  
  // Check if booking is an emergency request
  bool get isEmergencyRequest => isEmergency;
  
  // Check if booking has been rebooked
  bool get hasBeenRebooked => isRebooked;
  
  // Check if booking has a parent booking (is itself a rebooking)
  bool get isRebooking => parentBookingId != null;
}