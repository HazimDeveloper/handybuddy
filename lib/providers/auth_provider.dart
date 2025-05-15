import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String userType; // 'provider' or 'seeker'
  final Timestamp createdAt;
  final String? profileImageUrl;
  
  // Shared properties for both user types
  final String? phoneNumber;
  final bool isActive;
  final Timestamp? lastActive;
  final Map<String, dynamic>? preferences;
  final List<String>? favoriteServices;
  final List<String>? favoriteProviders;
  final String? fcmToken; // For push notifications
  final String? language; // User's preferred language
  
  // Provider-specific properties
  final String? category;
  final String? icImageUrl;
  final String? resumeUrl;
  final bool? isVerified;
  final bool? availableForWork;
  final double? rating;
  final int? totalServices;
  final int? totalBookings;
  final int? completedBookings;
  final String? bio;
  final List<String>? skills;
  final Map<String, dynamic>? availability;
  final Map<String, dynamic>? bankDetails;
  final bool? offerEmergencyServices;
  final Map<String, dynamic>? serviceLocations;
  
  // Seeker-specific properties
  final List<String>? recentSearches;
  final List<String>? savedAddresses;
  final List<Map<String, dynamic>>? paymentMethods;
  final int? totalSpent;
  final Map<String, dynamic>? notificationSettings;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.createdAt,
    this.profileImageUrl,
    this.phoneNumber,
    this.isActive = true,
    this.lastActive,
    this.preferences,
    this.favoriteServices,
    this.favoriteProviders,
    this.fcmToken,
    this.language,
    
    // Provider-specific
    this.category,
    this.icImageUrl,
    this.resumeUrl,
    this.isVerified,
    this.availableForWork,
    this.rating,
    this.totalServices,
    this.totalBookings,
    this.completedBookings,
    this.bio,
    this.skills,
    this.availability,
    this.bankDetails,
    this.offerEmergencyServices,
    this.serviceLocations,
    
    // Seeker-specific
    this.recentSearches,
    this.savedAddresses,
    this.paymentMethods,
    this.totalSpent,
    this.notificationSettings,
  });

  // Create a user model from a Firestore document snapshot
  factory UserModel.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      userType: data['userType'] ?? 'seeker',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      profileImageUrl: data['profileImageUrl'],
      phoneNumber: data['phoneNumber'],
      isActive: data['isActive'] ?? true,
      lastActive: data['lastActive'],
      preferences: data['preferences'],
      favoriteServices: data['favoriteServices'] != null 
          ? List<String>.from(data['favoriteServices']) 
          : null,
      favoriteProviders: data['favoriteProviders'] != null 
          ? List<String>.from(data['favoriteProviders']) 
          : null,
      fcmToken: data['fcmToken'],
      language: data['language'],
      
      // Provider-specific
      category: data['category'],
      icImageUrl: data['icImageUrl'],
      resumeUrl: data['resumeUrl'],
      isVerified: data['isVerified'],
      availableForWork: data['availableForWork'],
      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : null,
      totalServices: data['totalServices'],
      totalBookings: data['totalBookings'],
      completedBookings: data['completedBookings'],
      bio: data['bio'],
      skills: data['skills'] != null 
          ? List<String>.from(data['skills']) 
          : null,
      availability: data['availability'],
      bankDetails: data['bankDetails'],
      offerEmergencyServices: data['offerEmergencyServices'],
      serviceLocations: data['serviceLocations'],
      
      // Seeker-specific
      recentSearches: data['recentSearches'] != null 
          ? List<String>.from(data['recentSearches']) 
          : null,
      savedAddresses: data['savedAddresses'] != null 
          ? List<String>.from(data['savedAddresses']) 
          : null,
      paymentMethods: data['paymentMethods'] != null 
          ? List<Map<String, dynamic>>.from(data['paymentMethods']) 
          : null,
      totalSpent: data['totalSpent'],
      notificationSettings: data['notificationSettings'],
    );
  }

  // Convert to a map that can be stored in Firestore
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'lastActive': lastActive,
      'preferences': preferences,
      'favoriteServices': favoriteServices,
      'favoriteProviders': favoriteProviders,
      'fcmToken': fcmToken,
      'language': language,
    };
    
    // Add provider-specific fields if user is a provider
    if (userType == 'provider') {
      data.addAll({
        'category': category,
        'icImageUrl': icImageUrl,
        'resumeUrl': resumeUrl,
        'isVerified': isVerified,
        'availableForWork': availableForWork,
        'rating': rating,
        'totalServices': totalServices,
        'totalBookings': totalBookings,
        'completedBookings': completedBookings,
        'bio': bio,
        'skills': skills,
        'availability': availability,
        'bankDetails': bankDetails,
        'offerEmergencyServices': offerEmergencyServices,
        'serviceLocations': serviceLocations,
      });
    }
    
    // Add seeker-specific fields if user is a seeker
    if (userType == 'seeker') {
      data.addAll({
        'recentSearches': recentSearches,
        'savedAddresses': savedAddresses,
        'paymentMethods': paymentMethods,
        'totalSpent': totalSpent,
        'notificationSettings': notificationSettings,
      });
    }
    
    return data;
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? userType,
    Timestamp? createdAt,
    String? profileImageUrl,
    String? phoneNumber,
    bool? isActive,
    Timestamp? lastActive,
    Map<String, dynamic>? preferences,
    List<String>? favoriteServices,
    List<String>? favoriteProviders,
    String? fcmToken,
    String? language,
    
    // Provider-specific
    String? category,
    String? icImageUrl,
    String? resumeUrl,
    bool? isVerified,
    bool? availableForWork,
    double? rating,
    int? totalServices,
    int? totalBookings,
    int? completedBookings,
    String? bio,
    List<String>? skills,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? bankDetails,
    bool? offerEmergencyServices,
    Map<String, dynamic>? serviceLocations,
    
    // Seeker-specific
    List<String>? recentSearches,
    List<String>? savedAddresses,
    List<Map<String, dynamic>>? paymentMethods,
    int? totalSpent,
    Map<String, dynamic>? notificationSettings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
      favoriteServices: favoriteServices ?? this.favoriteServices,
      favoriteProviders: favoriteProviders ?? this.favoriteProviders,
      fcmToken: fcmToken ?? this.fcmToken,
      language: language ?? this.language,
      
      // Provider-specific
      category: category ?? this.category,
      icImageUrl: icImageUrl ?? this.icImageUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      isVerified: isVerified ?? this.isVerified,
      availableForWork: availableForWork ?? this.availableForWork,
      rating: rating ?? this.rating,
      totalServices: totalServices ?? this.totalServices,
      totalBookings: totalBookings ?? this.totalBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      availability: availability ?? this.availability,
      bankDetails: bankDetails ?? this.bankDetails,
      offerEmergencyServices: offerEmergencyServices ?? this.offerEmergencyServices,
      serviceLocations: serviceLocations ?? this.serviceLocations,
      
      // Seeker-specific
      recentSearches: recentSearches ?? this.recentSearches,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      totalSpent: totalSpent ?? this.totalSpent,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  // Helper methods
  
  // Get user's full name
  String get fullName => '$firstName $lastName';
  
  // Check if user is a provider
  bool get isProvider => userType == 'provider';
  
  // Check if user is a seeker
  bool get isSeeker => userType == 'seeker';
  
  // Check if provider is available (verified and available for work)
  bool get isAvailableProvider => 
      isProvider && 
      (isVerified ?? false) && 
      (availableForWork ?? false);
  
  // Get avatar image (with fallback to initials-based avatar)
  String getAvatarImage() {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return profileImageUrl!;
    }
    
    // Return default avatar based on user type
    if (isProvider) {
      return 'assets/images/default_provider_avatar.png';
    } else {
      return 'assets/images/default_seeker_avatar.png';
    }
  }
  
  // Get user initials for avatar
  String get initials {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
  
  // Get user activity status
  String get activityStatus {
    if (!isActive) return 'Inactive';
    
    if (lastActive != null) {
      final now = DateTime.now();
      final lastActiveTime = lastActive!.toDate();
      final difference = now.difference(lastActiveTime);
      
      if (difference.inMinutes < 5) {
        return 'Online';
      } else if (difference.inHours < 1) {
        return 'Last seen ${difference.inMinutes} min ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inHours} hr ago';
      } else {
        return 'Last seen ${difference.inDays} days ago';
      }
    }
    
    return 'Online';
  }
  
  // Check if user has a complete profile
  bool get hasCompleteProfile {
    if (isProvider) {
      return firstName.isNotEmpty && 
          lastName.isNotEmpty && 
          (category ?? '').isNotEmpty &&
          (bio ?? '').isNotEmpty;
    } else {
      return firstName.isNotEmpty && 
          lastName.isNotEmpty && 
          (phoneNumber ?? '').isNotEmpty;
    }
  }
  
  // Get formatted date when user joined
  String get joinedDate {
    final date = createdAt.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Format provider rating (with fallback)
  String get formattedRating {
    if (rating == null) return 'New';
    return rating!.toStringAsFixed(1);
  }
  
  // Provider verification status
  String get verificationStatus {
    if (!isProvider) return '';
    
    if (isVerified == null) return 'Pending';
    return isVerified! ? 'Verified' : 'Unverified';
  }
  
  // Provider success rate
  String get successRate {
    if (!isProvider) return '';
    
    if (totalBookings == null || 
        completedBookings == null || 
        totalBookings == 0) {
      return 'New';
    }
    
    final rate = (completedBookings! / totalBookings!) * 100;
    return '${rate.toStringAsFixed(0)}%';
  }
  
  // Provider experience level based on completed bookings
  String get experienceLevel {
    if (!isProvider) return '';
    
    if (completedBookings == null) return 'New';
    
    if (completedBookings! >= 100) {
      return 'Expert';
    } else if (completedBookings! >= 50) {
      return 'Advanced';
    } else if (completedBookings! >= 20) {
      return 'Intermediate';
    } else if (completedBookings! >= 5) {
      return 'Beginner';
    } else {
      return 'New';
    }
  }
  
  // Check if user is new (joined less than 7 days ago)
  bool get isNew {
    final now = DateTime.now();
    final joined = createdAt.toDate();
    return now.difference(joined).inDays < 7;
  }
  
  // Check if user has a verified phone number
  bool get hasVerifiedPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
  
  // Check if provider offers emergency services
  bool get offersEmergency => 
      isProvider && 
      (offerEmergencyServices ?? false);
  
  // Get formatted category name with proper capitalization
  String get formattedCategory {
    if (!isProvider || category == null || category!.isEmpty) return '';
    
    // Handle multi-word categories
    if (category!.contains('_')) {
      return category!
          .split('_')
          .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
          .join(' ');
    }
    
    // Single word category
    return category!.substring(0, 1).toUpperCase() + category!.substring(1);
  }
  
  // Check if user has any saved addresses
  bool get hasSavedAddresses => 
      isSeeker && 
      savedAddresses != null && 
      savedAddresses!.isNotEmpty;
  
  // Check if user has any saved payment methods
  bool get hasSavedPaymentMethods => 
      isSeeker && 
      paymentMethods != null && 
      paymentMethods!.isNotEmpty;
  
  // Check if user has favorites
  bool get hasFavorites => 
      (favoriteServices != null && favoriteServices!.isNotEmpty) ||
      (favoriteProviders != null && favoriteProviders!.isNotEmpty);
      
  // Check if current language is English (default)
  bool get isEnglish => language == null || language == 'en';
  
  // Check if provider has skills
  bool get hasSkills => 
      isProvider && 
      skills != null && 
      skills!.isNotEmpty;
}