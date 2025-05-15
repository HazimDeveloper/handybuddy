import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String serviceId;
  final String providerId;
  final String title;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;
  final Timestamp createdAt;
  final bool isActive;
  
  // Additional fields for enhanced service details
  final List<String>? tags;
  final Map<String, dynamic>? availability;
  final double? averageRating;
  final int? totalBookings;
  final int? completedBookings;
  final List<String>? additionalImages;
  final Map<String, dynamic>? pricingOptions;
  final int? estimatedDuration;
  final String? durationType; // minutes, hours, days
  final bool featuresEmergencyService;
  final double? emergencyServiceSurcharge;
  final List<Map<String, dynamic>>? faqs;
  final bool requiresVerification;
  final int displayOrder;

  ServiceModel({
    required this.serviceId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
    required this.createdAt,
    required this.isActive,
    this.tags,
    this.availability,
    this.averageRating,
    this.totalBookings,
    this.completedBookings,
    this.additionalImages,
    this.pricingOptions,
    this.estimatedDuration,
    this.durationType,
    this.featuresEmergencyService = false,
    this.emergencyServiceSurcharge,
    this.faqs,
    this.requiresVerification = false,
    this.displayOrder = 0,
  });

  // Create a service model from a Firestore document snapshot
  factory ServiceModel.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    
    return ServiceModel(
      serviceId: data['serviceId'] ?? '',
      providerId: data['providerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isActive: data['isActive'] ?? true,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      availability: data['availability'],
      averageRating: data['averageRating'] != null ? (data['averageRating'] as num).toDouble() : null,
      totalBookings: data['totalBookings'],
      completedBookings: data['completedBookings'],
      additionalImages: data['additionalImages'] != null 
          ? List<String>.from(data['additionalImages']) 
          : null,
      pricingOptions: data['pricingOptions'],
      estimatedDuration: data['estimatedDuration'],
      durationType: data['durationType'],
      featuresEmergencyService: data['featuresEmergencyService'] ?? false,
      emergencyServiceSurcharge: data['emergencyServiceSurcharge'] != null 
          ? (data['emergencyServiceSurcharge'] as num).toDouble() 
          : null,
      faqs: data['faqs'] != null 
          ? List<Map<String, dynamic>>.from(data['faqs']) 
          : null,
      requiresVerification: data['requiresVerification'] ?? false,
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  // Convert to a map that can be stored in Firestore
  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'providerId': providerId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'isActive': isActive,
      'tags': tags,
      'availability': availability,
      'averageRating': averageRating,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'additionalImages': additionalImages,
      'pricingOptions': pricingOptions,
      'estimatedDuration': estimatedDuration,
      'durationType': durationType,
      'featuresEmergencyService': featuresEmergencyService,
      'emergencyServiceSurcharge': emergencyServiceSurcharge,
      'faqs': faqs,
      'requiresVerification': requiresVerification,
      'displayOrder': displayOrder,
    };
  }

  // Create a copy of the service with updated fields
  ServiceModel copyWith({
    String? serviceId,
    String? providerId,
    String? title,
    String? description,
    String? category,
    double? price,
    String? imageUrl,
    Timestamp? createdAt,
    bool? isActive,
    List<String>? tags,
    Map<String, dynamic>? availability,
    double? averageRating,
    int? totalBookings,
    int? completedBookings,
    List<String>? additionalImages,
    Map<String, dynamic>? pricingOptions,
    int? estimatedDuration,
    String? durationType,
    bool? featuresEmergencyService,
    double? emergencyServiceSurcharge,
    List<Map<String, dynamic>>? faqs,
    bool? requiresVerification,
    int? displayOrder,
  }) {
    return ServiceModel(
      serviceId: serviceId ?? this.serviceId,
      providerId: providerId ?? this.providerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      availability: availability ?? this.availability,
      averageRating: averageRating ?? this.averageRating,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      additionalImages: additionalImages ?? this.additionalImages,
      pricingOptions: pricingOptions ?? this.pricingOptions,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      durationType: durationType ?? this.durationType,
      featuresEmergencyService: featuresEmergencyService ?? this.featuresEmergencyService,
      emergencyServiceSurcharge: emergencyServiceSurcharge ?? this.emergencyServiceSurcharge,
      faqs: faqs ?? this.faqs,
      requiresVerification: requiresVerification ?? this.requiresVerification,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  // Helper methods for service info
  String get formattedPrice => 'RM ${price.toStringAsFixed(2)}';
  
  String get formattedDuration {
    if (estimatedDuration == null || durationType == null) {
      return 'Variable';
    }
    
    if (estimatedDuration == 1) {
      // Handle singular form
      switch (durationType) {
        case 'minutes':
          return '1 minute';
        case 'hours':
          return '1 hour';
        case 'days':
          return '1 day';
        default:
          return '$estimatedDuration $durationType';
      }
    } else {
      return '$estimatedDuration $durationType';
    }
  }
  
  // Check if service offers emergency service
  bool get hasEmergencyService => featuresEmergencyService;
  
  // Get emergency service price
  double? get emergencyPrice {
    if (featuresEmergencyService && emergencyServiceSurcharge != null) {
      return price + emergencyServiceSurcharge!;
    }
    return null;
  }
  
  // Format emergency price
  String? get formattedEmergencyPrice {
    final price = emergencyPrice;
    if (price != null) {
      return 'RM ${price.toStringAsFixed(2)}';
    }
    return null;
  }
  
  // Get service age in days
  int get serviceAge {
    final now = DateTime.now();
    final created = createdAt.toDate();
    return now.difference(created).inDays;
  }
  
  // Check if service is new (less than 7 days old)
  bool get isNew => serviceAge < 7;
  
  // Get success rate 
  double? get successRate {
    if (totalBookings != null && 
        completedBookings != null && 
        totalBookings! > 0) {
      return (completedBookings! / totalBookings!) * 100;
    }
    return null;
  }
  
  // Format success rate
  String get formattedSuccessRate {
    final rate = successRate;
    if (rate != null) {
      return '${rate.toStringAsFixed(1)}%';
    }
    return 'N/A';
  }
  
  // Check if service is trending (high booking rate)
  bool get isTrending {
    if (totalBookings != null && serviceAge > 0) {
      // Calculate bookings per day
      final bookingsPerDay = totalBookings! / serviceAge;
      // Service is trending if it has more than 5 bookings per day
      return bookingsPerDay > 5;
    }
    return false;
  }
  
  // Check if category is related to emergency categories
  bool get isEmergencyCategory {
    final emergencyCategories = [
      'plumbing', 
      'electrical', 
      'emergency',
      'medical',
      'security'
    ];
    return emergencyCategories.contains(category.toLowerCase());
  }
  
  // Get formatted category name with proper capitalization
  String get formattedCategory {
    if (category.isEmpty) return '';
    
    // Handle multi-word categories
    if (category.contains('_')) {
      return category
          .split('_')
          .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
          .join(' ');
    }
    
    // Single word category
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }
  
  // Get a list of relevant search keywords for the service
  List<String> get searchKeywords {
    final List<String> keywords = [];
    
    // Add title words
    keywords.addAll(title.toLowerCase().split(' '));
    
    // Add category
    keywords.add(category.toLowerCase());
    
    // Add description words (limit to first 20 words)
    final descriptionWords = description.toLowerCase().split(' ');
    if (descriptionWords.length > 20) {
      keywords.addAll(descriptionWords.sublist(0, 20));
    } else {
      keywords.addAll(descriptionWords);
    }
    
    // Add tags
    if (tags != null) {
      keywords.addAll(tags!.map((tag) => tag.toLowerCase()));
    }
    
    // Remove duplicates and return
    return keywords.toSet().toList();
  }
  
  // Check if the service is available on a specific day of week
  bool isAvailableOnDay(String day) {
    if (availability == null) return true; // Default to available
    
    final Map<String, dynamic>? daysAvailability = availability!['days'];
    if (daysAvailability == null) return true;
    
    return daysAvailability[day.toLowerCase()] ?? true;
  }
  
  // Get the current status display text
  String get statusText => isActive ? 'Active' : 'Inactive';
  
  // Get relevant image URL (returns default if none available)
  String getDisplayImageUrl() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    
    // Return a default image URL based on category
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'assets/images/default_services/cleaning.png';
      case 'plumbing':
        return 'assets/images/default_services/plumbing.png';
      case 'electrical':
        return 'assets/images/default_services/electrical.png';
      case 'tutoring':
        return 'assets/images/default_services/tutoring.png';
      case 'home_repairs':
        return 'assets/images/default_services/home_repairs.png';
      case 'transport':
        return 'assets/images/default_services/transport.png';
      default:
        return 'assets/images/default_services/general.png';
    }
  }
  
  // Check if service has FAQs
  bool get hasFaqs => faqs != null && faqs!.isNotEmpty;
  
  // Check if service has multiple pricing options
  bool get hasMultiplePricingOptions => 
      pricingOptions != null && pricingOptions!.isNotEmpty;
      
  // Get the base price (minimum pricing option if multiple available)
  double get basePrice {
    if (!hasMultiplePricingOptions) return price;
    
    double minPrice = price;
    pricingOptions!.forEach((key, value) {
      if (value is num && value < minPrice) {
        minPrice = value.toDouble();
      }
    });
    
    return minPrice;
  }
}