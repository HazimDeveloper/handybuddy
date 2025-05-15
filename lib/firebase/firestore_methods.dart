import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _servicesCollection = 
      FirebaseFirestore.instance.collection('services');
  final CollectionReference _bookingsCollection = 
      FirebaseFirestore.instance.collection('bookings');
  final CollectionReference _ratingsCollection = 
      FirebaseFirestore.instance.collection('ratings');
  final CollectionReference _chatsCollection = 
      FirebaseFirestore.instance.collection('chats');

  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // ----- USER MANAGEMENT METHODS -----

  Future<String> updateBookingEvidence({
    required String bookingId,
    required List<String> beforeImages,
    required List<String> afterImages,
  }) async {
    String result = "Error occurred";
    
    try {
      if (beforeImages.isEmpty || afterImages.isEmpty) {
        return "Both before and after images are required";
      }
      
      await _bookingsCollection.doc(bookingId).update({
        'beforeServiceImages': beforeImages,
        'afterServiceImages': afterImages,
      });
      
      result = "success";
    } catch (e) {
      if (kDebugMode) {
        print('Error updating booking evidence: $e');
      }
      result = e.toString();
    }
    
    return result;
  }
  
  // Create a service provider user
  Future<String> createServiceProvider({
    required String email,
    required String firstName,
    required String lastName,
    required String category,
    required File icImage,
    required File resumeFile,
  }) async {
    String result = "Error occurred";
    
    try {
      // Upload IC image
      String icImageUrl = await _uploadFile(
        file: icImage,
        path: 'provider_documents/${currentUserId}/ic_image'
      );
      
      // Upload resume file
      String resumeUrl = await _uploadFile(
        file: resumeFile,
        path: 'provider_documents/${currentUserId}/resume'
      );
      
      // Create user model
      UserModel userModel = UserModel(
        uid: currentUserId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        userType: 'provider',
        category: category,
        icImageUrl: icImageUrl,
        resumeUrl: resumeUrl,
        createdAt: Timestamp.now(),
        isVerified: false, // Admin will verify later
        availableForWork: true,
        rating: 0,
        profileImageUrl: '',
      );
      
      // Save to Firestore
      await _usersCollection.doc(currentUserId).set(userModel.toJson());
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Create a service seeker user
  Future<String> createServiceSeeker({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    String result = "Error occurred";
    
    try {
      // Create user model
      UserModel userModel = UserModel(
        uid: currentUserId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        userType: 'seeker',
        createdAt: Timestamp.now(),
        profileImageUrl: '',
      );
      
      // Save to Firestore
      await _usersCollection.doc(currentUserId).set(userModel.toJson());
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Get user data by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromSnap(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user: $e');
      }
      return null;
    }
  }
  
  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    if (currentUserId.isEmpty) return null;
    return getUserById(currentUserId);
  }
  
  // Update user profile
  Future<String> updateUserProfile({
    String? firstName,
    String? lastName,
    File? profileImage,
  }) async {
    String result = "Error occurred";
    
    try {
      Map<String, dynamic> updates = {};
      
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      
      if (profileImage != null) {
        String profileImageUrl = await _uploadFile(
          file: profileImage,
          path: 'profile_images/$currentUserId'
        );
        updates['profileImageUrl'] = profileImageUrl;
      }
      
      await _usersCollection.doc(currentUserId).update(updates);
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Update provider availability
  Future<String> updateProviderAvailability(bool isAvailable) async {
    String result = "Error occurred";
    
    try {
      await _usersCollection.doc(currentUserId).update({
        'availableForWork': isAvailable
      });
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Delete user account
  Future<String> deleteUserAccount() async {
    String result = "Error occurred";
    
    try {
      // Get user data to check type
      UserModel? user = await getCurrentUser();
      
      if (user == null) {
        return "User not found";
      }
      
      // If provider, delete services
      if (user.userType == 'provider') {
        QuerySnapshot servicesSnapshot = await _servicesCollection
            .where('providerId', isEqualTo: currentUserId)
            .get();
            
        WriteBatch batch = _firestore.batch();
        
        for (var doc in servicesSnapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      }
      
      // Delete user document
      await _usersCollection.doc(currentUserId).delete();
      
      // Note: The Firebase Auth account should be deleted separately
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }

  // ----- SERVICE MANAGEMENT METHODS -----
  
  // Create or update a service
  Future<String> createOrUpdateService({
    String? serviceId,
    required String title,
    required String description,
    required String category,
    required double price,
    File? serviceImage,
  }) async {
    String result = "Error occurred";
    
    try {
      String finalServiceId = serviceId ?? const Uuid().v4();
      String? serviceImageUrl;
      
      if (serviceImage != null) {
        serviceImageUrl = await _uploadFile(
          file: serviceImage,
          path: 'service_images/$finalServiceId'
        );
      }
      
      ServiceModel serviceModel = ServiceModel(
        serviceId: finalServiceId,
        providerId: currentUserId,
        title: title,
        description: description,
        category: category,
        price: price,
        imageUrl: serviceImageUrl,
        createdAt: Timestamp.now(),
        isActive: true,
      );
      
      await _servicesCollection.doc(finalServiceId).set(
        serviceModel.toJson(),
        SetOptions(merge: true)
      );
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Delete a service
  Future<String> deleteService(String serviceId) async {
    String result = "Error occurred";
    
    try {
      // Check if there are active bookings for this service
      QuerySnapshot bookingsSnapshot = await _bookingsCollection
          .where('serviceId', isEqualTo: serviceId)
          .where('status', whereIn: ['pending', 'confirmed', 'in_progress'])
          .get();
          
      if (bookingsSnapshot.docs.isNotEmpty) {
        return "Cannot delete service with active bookings";
      }
      
      await _servicesCollection.doc(serviceId).delete();
      
      // Delete service image from storage if exists
      try {
        await _storage.ref('service_images/$serviceId').delete();
      } catch (e) {
        // Image might not exist, continue
      }
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Toggle service active status
  Future<String> toggleServiceStatus(String serviceId, bool isActive) async {
    String result = "Error occurred";
    
    try {
      await _servicesCollection.doc(serviceId).update({
        'isActive': isActive
      });
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Get service by ID
  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      DocumentSnapshot doc = await _servicesCollection.doc(serviceId).get();
      
      if (doc.exists) {
        return ServiceModel.fromSnap(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting service: $e');
      }
      return null;
    }
  }
  
  // Get all services by category
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _servicesCollection
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting services by category: $e');
      }
      return [];
    }
  }
  
  // Get all services by provider
  Future<List<ServiceModel>> getServicesByProvider(String providerId) async {
    try {
      QuerySnapshot querySnapshot = await _servicesCollection
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting services by provider: $e');
      }
      return [];
    }
  }
  
  // Get current provider's services
  Future<List<ServiceModel>> getCurrentProviderServices() async {
    return getServicesByProvider(currentUserId);
  }
  
  // Search services
  Future<List<ServiceModel>> searchServices(String query) async {
    try {
      // Firestore doesn't support native text search
      // A basic implementation using startAt and endAt with title field
      String lowercaseQuery = query.toLowerCase();
      String uppercaseQuery = query.toLowerCase() + '\uf8ff';
      
      QuerySnapshot querySnapshot = await _servicesCollection
          .where('title', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('title', isLessThan: uppercaseQuery)
          .where('isActive', isEqualTo: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching services: $e');
      }
      return [];
    }
  }

  // ----- BOOKING MANAGEMENT METHODS -----
  
  // Create a new booking
  Future<String> createBooking({
    required String serviceId,
    required String providerId,
    required Timestamp scheduledDate,
    required String address,
    required String contactNumber,
    required String paymentMethod,
    String? specialInstructions,
  }) async {
    String result = "Error occurred";
    
    try {
      String bookingId = const Uuid().v4();
      
      BookingModel bookingModel = BookingModel(
        bookingId: bookingId,
        serviceId: serviceId,
        providerId: providerId,
        seekerId: currentUserId,
        status: 'pending',
        scheduledDate: scheduledDate,
        createdAt: Timestamp.now(),
        address: address,
        contactNumber: contactNumber,
        paymentMethod: paymentMethod,
        specialInstructions: specialInstructions,
        isEmergency: false,
        completedAt: null,
        cancelledAt: null,
        cancelReason: null,
        totalAmount: 0, // Will be updated when provider confirms
      );
      
      await _bookingsCollection.doc(bookingId).set(bookingModel.toJson());
      
      result = bookingId; // Return booking ID for success
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Create emergency booking
  Future<String> createEmergencyBooking({
    required String serviceId,
    required String providerId,
    required String address,
    required String contactNumber,
    required String emergencyDetails,
  }) async {
    String result = "Error occurred";
    
    try {
      String bookingId = const Uuid().v4();
      
      BookingModel bookingModel = BookingModel(
        bookingId: bookingId,
        serviceId: serviceId,
        providerId: providerId,
        seekerId: currentUserId,
        status: 'pending',
        scheduledDate: Timestamp.now(), // Immediate service
        createdAt: Timestamp.now(),
        address: address,
        contactNumber: contactNumber,
        paymentMethod: 'cod', // Cash on delivery for emergency
        specialInstructions: emergencyDetails,
        isEmergency: true,
        completedAt: null,
        cancelledAt: null,
        cancelReason: null,
        totalAmount: 0, // Will be updated when provider confirms
      );
      
      await _bookingsCollection.doc(bookingId).set(bookingModel.toJson());
      
      result = bookingId; // Return booking ID for success
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Update booking status (provider)
  Future<String> updateBookingStatus({
    required String bookingId,
    required String status,
    double? totalAmount,
    String? cancelReason,
  }) async {
    String result = "Error occurred";
    
    try {
      Map<String, dynamic> updates = {
        'status': status,
      };
      
      if (status == 'confirmed' && totalAmount != null) {
        updates['totalAmount'] = totalAmount;
      }
      
      if (status == 'completed') {
        updates['completedAt'] = Timestamp.now();
      }
      
      if (status == 'cancelled') {
        updates['cancelledAt'] = Timestamp.now();
        updates['cancelReason'] = cancelReason;
      }
      
      await _bookingsCollection.doc(bookingId).update(updates);
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await _bookingsCollection.doc(bookingId).get();
      
      if (doc.exists) {
        return BookingModel.fromSnap(doc);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting booking: $e');
      }
      return null;
    }
  }
  
  // Get bookings for provider
  Future<List<BookingModel>> getProviderBookings({
    String? status,
    bool onlyActive = false,
  }) async {
    try {
      Query query = _bookingsCollection
          .where('providerId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);
          
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      } else if (onlyActive) {
        query = query.where('status', whereIn: ['pending', 'confirmed', 'in_progress']);
      }
      
      QuerySnapshot querySnapshot = await query.get();
          
      return querySnapshot.docs
          .map((doc) => BookingModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting provider bookings: $e');
      }
      return [];
    }
  }
  
  // Get bookings for seeker
  Future<List<BookingModel>> getSeekerBookings({
    String? status,
    bool onlyActive = false,
  }) async {
    try {
      Query query = _bookingsCollection
          .where('seekerId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true);
          
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      } else if (onlyActive) {
        query = query.where('status', whereIn: ['pending', 'confirmed', 'in_progress']);
      }
      
      QuerySnapshot querySnapshot = await query.get();
          
      return querySnapshot.docs
          .map((doc) => BookingModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting seeker bookings: $e');
      }
      return [];
    }
  }
  
  // Rebook a service (create new booking based on previous one)
  Future<String> rebookService(String previousBookingId) async {
    String result = "Error occurred";
    
    try {
      BookingModel? previousBooking = await getBookingById(previousBookingId);
      
      if (previousBooking == null) {
        return "Previous booking not found";
      }
      
      String bookingId = await createBooking(
        serviceId: previousBooking.serviceId,
        providerId: previousBooking.providerId,
        scheduledDate: Timestamp.now(), // User will pick new date in UI
        address: previousBooking.address,
        contactNumber: previousBooking.contactNumber,
        paymentMethod: previousBooking.paymentMethod,
        specialInstructions: previousBooking.specialInstructions,
      );
      
      if (bookingId.contains("Error")) {
        return bookingId;
      }
      
      result = bookingId;
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }

  // ----- RATINGS AND REVIEWS -----
  
  // Add rating for a completed service
  Future<String> addRating({
    required String bookingId,
    required String providerId,
    required double rating,
    String? review,
  }) async {
    String result = "Error occurred";
    
    try {
      // Check if booking exists and is completed
      BookingModel? booking = await getBookingById(bookingId);
      
      if (booking == null) {
        return "Booking not found";
      }
      
      if (booking.status != 'completed') {
        return "Cannot rate a booking that is not completed";
      }
      
      if (booking.seekerId != currentUserId) {
        return "You can only rate your own bookings";
      }
      
      // Add rating document
      String ratingId = const Uuid().v4();
      
      await _ratingsCollection.doc(ratingId).set({
        'ratingId': ratingId,
        'bookingId': bookingId,
        'providerId': providerId,
        'seekerId': currentUserId,
        'rating': rating,
        'review': review,
        'createdAt': Timestamp.now(),
      });
      
      // Update provider's average rating
      await _updateProviderAverageRating(providerId);
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Get ratings for a provider
  Future<List<Map<String, dynamic>>> getProviderRatings(String providerId) async {
    try {
      QuerySnapshot querySnapshot = await _ratingsCollection
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();
          
      List<Map<String, dynamic>> ratings = [];
      
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Get seeker info
        UserModel? seeker = await getUserById(data['seekerId']);
        
        if (seeker != null) {
          data['seekerName'] = '${seeker.firstName} ${seeker.lastName}';
          data['seekerProfileImage'] = seeker.profileImageUrl;
        }
        
        ratings.add(data);
      }
      
      return ratings;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting provider ratings: $e');
      }
      return [];
    }
  }
  
  // Update provider's average rating
  Future<void> _updateProviderAverageRating(String providerId) async {
    try {
      QuerySnapshot ratingsSnapshot = await _ratingsCollection
          .where('providerId', isEqualTo: providerId)
          .get();
          
      if (ratingsSnapshot.docs.isEmpty) {
        return;
      }
      
      double totalRating = 0;
      
      for (var doc in ratingsSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        totalRating += (data['rating'] as num).toDouble();
      }
      
      double averageRating = totalRating / ratingsSnapshot.docs.length;
      
      await _usersCollection.doc(providerId).update({
        'rating': averageRating
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating provider rating: $e');
      }
    }
  }

  // ----- CHAT METHODS -----
  
  // Create or get chat between provider and seeker
  Future<String?> createOrGetChat(String otherUserId) async {
    try {
      // Check if chat already exists
      QuerySnapshot chatQuery = await _chatsCollection
          .where('participants', arrayContains: currentUserId)
          .get();
          
      for (var doc in chatQuery.docs) {
        List<dynamic> participants = (doc.data() as Map<String, dynamic>)['participants'];
        
        if (participants.contains(otherUserId)) {
          return doc.id;
        }
      }
      
      // Create new chat
      String chatId = const Uuid().v4();
      
      await _chatsCollection.doc(chatId).set({
        'chatId': chatId,
        'participants': [currentUserId, otherUserId],
        'lastMessage': null,
        'lastMessageTimestamp': null,
        'createdAt': Timestamp.now(),
      });
      
      return chatId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating/getting chat: $e');
      }
      return null;
    }
  }
  
  // Send a message
  Future<String> sendMessage({
    required String chatId,
    required String content,
  }) async {
    String result = "Error occurred";
    
    try {
      String messageId = const Uuid().v4();
      
      await _chatsCollection.doc(chatId).collection('messages').doc(messageId).set({
        'messageId': messageId,
        'senderId': currentUserId,
        'content': content,
        'timestamp': Timestamp.now(),
        'isRead': false,
      });
      
      // Update last message in chat
      await _chatsCollection.doc(chatId).update({
        'lastMessage': content,
        'lastMessageTimestamp': Timestamp.now(),
      });
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }
  
  // Get all chats for current user
  Future<List<Map<String, dynamic>>> getUserChats() async {
    try {
      QuerySnapshot chatQuery = await _chatsCollection
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastMessageTimestamp', descending: true)
          .get();
          
      List<Map<String, dynamic>> chats = [];
      
      for (var doc in chatQuery.docs) {
        Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;
        
        // Get other participant's info
        List<dynamic> participants = chatData['participants'];
        String otherUserId = participants[0] == currentUserId 
            ? participants[1] 
            : participants[0];
            
        UserModel? otherUser = await getUserById(otherUserId);
        
        if (otherUser != null) {
          chatData['otherUserName'] = '${otherUser.firstName} ${otherUser.lastName}';
          chatData['otherUserImage'] = otherUser.profileImageUrl;
          chatData['otherUserType'] = otherUser.userType;
        }
        
        chats.add(chatData);
      }
      
      return chats;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user chats: $e');
      }
      return [];
    }
  }
  
  // Get messages for a chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
  
  // Mark messages as read
  Future<String> markMessagesAsRead(String chatId) async {
    String result = "Error occurred";
    
    try {
      QuerySnapshot unreadMessages = await _chatsCollection
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();
          
      WriteBatch batch = _firestore.batch();
      
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      
      result = "success";
    } catch (e) {
      result = e.toString();
    }
    
    return result;
  }

  // ----- HELPER METHODS -----

  // Upload file to Firebase Storage
  Future<String> _uploadFile({
    required File file,
    required String path,
  }) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  
  // Get providers by category (for service seeker to browse)
  Future<List<UserModel>> getProvidersByCategory(String category) async {
    try {
      QuerySnapshot querySnapshot = await _usersCollection
          .where('userType', isEqualTo: 'provider')
          .where('category', isEqualTo: category)
          .where('isVerified', isEqualTo: true)
          .where('availableForWork', isEqualTo: true)
          .orderBy('rating', descending: true)
          .get();
          
      return querySnapshot.docs
          .map((doc) => UserModel.fromSnap(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting providers by category: $e');
      }
      return [];
    }
  }
  
  // Get earnings data for a provider
  Future<Map<String, dynamic>> getProviderEarnings() async {
    try {
      QuerySnapshot completedBookings = await _bookingsCollection
          .where('providerId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'completed')
          .get();
          
      double totalEarnings = 0;
      Map<String, double> monthlyEarnings = {};
      
      for (var doc in completedBookings.docs) {
        BookingModel booking = BookingModel.fromSnap(doc);
        totalEarnings += booking.totalAmount;
        
        // Process monthly data
        DateTime completedDate = booking.completedAt!.toDate();
        String monthYear = '${completedDate.month}-${completedDate.year}';
        
        if (monthlyEarnings.containsKey(monthYear)) {
          monthlyEarnings[monthYear] = (monthlyEarnings[monthYear] ?? 0) + booking.totalAmount;
        } else {
          monthlyEarnings[monthYear] = booking.totalAmount;
        }
      }
      
      return {
        'totalEarnings': totalEarnings,
        'completedBookings': completedBookings.docs.length,
        'monthlyData': monthlyEarnings,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting provider earnings: $e');
      }
      return {
        'totalEarnings': 0,
        'completedBookings': 0,
        'monthlyData': {},
      };
    }
  }
}