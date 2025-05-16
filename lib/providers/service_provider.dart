// providers/service_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/firestore_methods.dart';
import '../firebase/storage_methods.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import '../utils/toast_util.dart';

class ServiceProvider with ChangeNotifier {
  final FirestoreMethods _firestoreMethods = FirestoreMethods();
  final StorageMethods _storageMethods = StorageMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Services data
  List<ServiceModel> _services = [];
  List<ServiceModel> _filteredServices = [];
  ServiceModel? _selectedService;
  bool _isLoading = false;
  bool _hasMoreServices = true;
  int _servicesPageSize = 10;
  DocumentSnapshot? _lastServiceDocument;
  String _error = '';
  
  // Service search and filter
  String _searchQuery = '';
  String _selectedCategory = '';
  String _sortBy = 'createdAt'; // Options: price, rating, createdAt
  bool _sortAscending = false;
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _showEmergencyOnly = false;
  
  // Current user
  UserModel? _user;
  
  // Providers data (for service seekers)
  List<UserModel> _providers = [];
  List<UserModel> _filteredProviders = [];
  bool _hasMoreProviders = true;
  int _providersPageSize = 10;
  DocumentSnapshot? _lastProviderDocument;
  
  // Provider search and filter
  String _providerSearchQuery = '';
  double _minRating = 0;
  bool _verifiedOnly = false;
  
  // Getters
  List<ServiceModel> get services => _filteredServices;
  List<ServiceModel> get myServices => _filteredServices.where((service) => 
      service.providerId == _auth.currentUser?.uid).toList();
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  bool get hasMoreServices => _hasMoreServices;
  String get error => _error;
  
  List<UserModel> get providers => _filteredProviders;
  bool get hasMoreProviders => _hasMoreProviders;
  
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get showEmergencyOnly => _showEmergencyOnly;
  
  String get providerSearchQuery => _providerSearchQuery;
  double get minRating => _minRating;
  bool get verifiedOnly => _verifiedOnly;
  
  // Update user
  void update(UserModel? user) {
    _user = user;
  }
  
  // --------------- Service Management ---------------
  
  // Create a new service
  Future<String> createService({
    required String title,
    required String description,
    required String category,
    required double price,
    required File serviceImage,
    List<String>? tags,
    int? estimatedDuration,
    String? durationType,
    bool featuresEmergencyService = false,
    double? emergencyServiceSurcharge,
    List<Map<String, dynamic>>? faqs,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Generate service ID
      String serviceId = _firestore.collection('services').doc().id;
      
      // Upload service image
      String imageUrl = await _storageMethods.uploadServiceImage(serviceImage, serviceId);
      
      // Create service model
      ServiceModel service = ServiceModel(
        serviceId: serviceId,
        providerId: uid,
        title: title,
        description: description,
        category: category,
        price: price,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
        isActive: true,
        tags: tags,
        estimatedDuration: estimatedDuration,
        durationType: durationType,
        featuresEmergencyService: featuresEmergencyService,
        emergencyServiceSurcharge: featuresEmergencyService ? emergencyServiceSurcharge : null,
        faqs: faqs,
      );
      
      // Save to Firestore
      await _firestore.collection('services').doc(serviceId).set(service.toJson());
      
      // Refresh services
      await fetchMyServices(refresh: true);
      
      _isLoading = false;
      notifyListeners();
      
      ToastUtils.showSuccessToast('Service created successfully');
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to create service: ${e.toString()}';
    }
  }
  
  // Update an existing service
  Future<String> updateService({
    required String serviceId,
    String? title,
    String? description,
    String? category,
    double? price,
    File? serviceImage,
    List<String>? tags,
    int? estimatedDuration,
    String? durationType,
    bool? featuresEmergencyService,
    double? emergencyServiceSurcharge,
    List<Map<String, dynamic>>? faqs,
    bool? isActive,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current service data
      DocumentSnapshot serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      
      if (!serviceDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return 'Service not found';
      }
      
      ServiceModel currentService = ServiceModel.fromSnap(serviceDoc);
      
      // Check if user owns this service
      if (currentService.providerId != uid) {
        _isLoading = false;
        notifyListeners();
        return 'You do not have permission to update this service';
      }
      
      // Upload new image if provided
      String? imageUrl;
      if (serviceImage != null) {
        imageUrl = await _storageMethods.uploadServiceImage(serviceImage, serviceId);
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (imageUrl != null) updateData['imageUrl'] = imageUrl;
      if (tags != null) updateData['tags'] = tags;
      if (estimatedDuration != null) updateData['estimatedDuration'] = estimatedDuration;
      if (durationType != null) updateData['durationType'] = durationType;
      if (featuresEmergencyService != null) {
        updateData['featuresEmergencyService'] = featuresEmergencyService;
        // If emergency service is disabled, clear surcharge
        if (!featuresEmergencyService) {
          updateData['emergencyServiceSurcharge'] = null;
        }
      }
      if (featuresEmergencyService ?? currentService.featuresEmergencyService) {
        if (emergencyServiceSurcharge != null) {
          updateData['emergencyServiceSurcharge'] = emergencyServiceSurcharge;
        }
      }
      if (faqs != null) updateData['faqs'] = faqs;
      if (isActive != null) updateData['isActive'] = isActive;
      
      // Update in Firestore
      await _firestore.collection('services').doc(serviceId).update(updateData);
      
      // Refresh services
      await fetchMyServices(refresh: true);
      
      // If this is the selected service, refresh it
      if (_selectedService != null && _selectedService!.serviceId == serviceId) {
        await fetchServiceById(serviceId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      ToastUtils.showSuccessToast('Service updated successfully');
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to update service: ${e.toString()}';
    }
  }
  
  // Delete a service
  Future<String> deleteService(String serviceId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current service data
      DocumentSnapshot serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      
      if (!serviceDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return 'Service not found';
      }
      
      ServiceModel service = ServiceModel.fromSnap(serviceDoc);
      
      // Check if user owns this service
      if (service.providerId != uid) {
        _isLoading = false;
        notifyListeners();
        return 'You do not have permission to delete this service';
      }
      
      // Check if there are active bookings for this service
      QuerySnapshot bookingsQuery = await _firestore.collection('bookings')
          .where('serviceId', isEqualTo: serviceId)
          .where('status', whereIn: ['pending', 'confirmed', 'in_progress'])
          .limit(1)
          .get();
          
      if (bookingsQuery.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Cannot delete service with active bookings';
      }
      
      // Delete service image from storage
      if (service.imageUrl != null && service.imageUrl!.isNotEmpty) {
        try {
          await _storageMethods.deleteFile(service.imageUrl!);
        } catch (e) {
          // Continue even if image deletion fails
          print('Failed to delete service image: ${e.toString()}');
        }
      }
      
      // Delete from Firestore
      await _firestore.collection('services').doc(serviceId).delete();
      
      // Refresh services
      await fetchMyServices(refresh: true);
      
      // Clear selected service if it was deleted
      if (_selectedService != null && _selectedService!.serviceId == serviceId) {
        _selectedService = null;
      }
      
      _isLoading = false;
      notifyListeners();
      
      ToastUtils.showSuccessToast('Service deleted successfully');
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to delete service: ${e.toString()}';
    }
  }
  
  // Toggle service active status
  Future<String> toggleServiceStatus(String serviceId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return 'User not logged in';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current service data
      DocumentSnapshot serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      
      if (!serviceDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return 'Service not found';
      }
      
      ServiceModel service = ServiceModel.fromSnap(serviceDoc);
      
      // Check if user owns this service
      if (service.providerId != uid) {
        _isLoading = false;
        notifyListeners();
        return 'You do not have permission to update this service';
      }
      
      // Toggle active status
      bool newStatus = !service.isActive;
      
      // Update in Firestore
      await _firestore.collection('services').doc(serviceId).update({
        'isActive': newStatus,
      });
      
      // Refresh services
      await fetchMyServices(refresh: true);
      
      // If this is the selected service, refresh it
      if (_selectedService != null && _selectedService!.serviceId == serviceId) {
        await fetchServiceById(serviceId);
      }
      
      _isLoading = false;
      notifyListeners();
      
      ToastUtils.showSuccessToast(
        newStatus ? 'Service activated successfully' : 'Service deactivated successfully'
      );
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to toggle service status: ${e.toString()}';
    }
  }
  
  // --------------- Service Fetching ---------------
  
  // Fetch all services with filters
  Future<void> fetchServices({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      if (refresh) {
        _lastServiceDocument = null;
        _services = [];
        _hasMoreServices = true;
      }
      notifyListeners();
      
      // Create base query
      Query query = _firestore.collection('services')
          .where('isActive', isEqualTo: true);
      
      // Apply category filter
      if (_selectedCategory.isNotEmpty) {
        query = query.where('category', isEqualTo: _selectedCategory);
      }
      
      // Apply emergency filter
      if (_showEmergencyOnly) {
        query = query.where('featuresEmergencyService', isEqualTo: true);
      }
      
      // Apply pagination
      if (_lastServiceDocument != null) {
        query = query.startAfterDocument(_lastServiceDocument!);
      }
      
      // Apply sorting
      if (_sortBy == 'price') {
        query = query.orderBy('price', descending: !_sortAscending);
      } else if (_sortBy == 'rating') {
        query = query.orderBy('averageRating', descending: !_sortAscending);
      } else {
        // Default sort by created date (newest first)
        query = query.orderBy('createdAt', descending: !_sortAscending);
      }
      
      // Limit results
      query = query.limit(_servicesPageSize);
      
      // Execute query
      QuerySnapshot querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        _hasMoreServices = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Save last document for pagination
      _lastServiceDocument = querySnapshot.docs.last;
      
      // Convert to service models
      List<ServiceModel> newServices = querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
      
      // Add to existing services
      if (refresh) {
        _services = newServices;
      } else {
        _services.addAll(newServices);
      }
      
      // Apply search filter
      _applyServiceFilters();
      
      _isLoading = false;
      if (querySnapshot.docs.length < _servicesPageSize) {
        _hasMoreServices = false;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Fetch services for current provider
  Future<void> fetchMyServices({bool refresh = false}) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      if (refresh) {
        _lastServiceDocument = null;
        _services = [];
        _hasMoreServices = true;
      }
      notifyListeners();
      
      // Create query
      Query query = _firestore.collection('services')
          .where('providerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true);
      
      // Apply pagination
      if (_lastServiceDocument != null) {
        query = query.startAfterDocument(_lastServiceDocument!);
      }
      
      // Limit results
      query = query.limit(_servicesPageSize);
      
      // Execute query
      QuerySnapshot querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        _hasMoreServices = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Save last document for pagination
      _lastServiceDocument = querySnapshot.docs.last;
      
      // Convert to service models
      List<ServiceModel> newServices = querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
      
      // Add to existing services
      if (refresh) {
        _services = newServices;
      } else {
        _services.addAll(newServices);
      }
      
      // Apply search filter
      _applyServiceFilters();
      
      _isLoading = false;
      if (querySnapshot.docs.length < _servicesPageSize) {
        _hasMoreServices = false;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Fetch services by provider ID
  Future<void> fetchProviderServices(String providerId, {bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      if (refresh) {
        _lastServiceDocument = null;
        _services = [];
        _hasMoreServices = true;
      }
      notifyListeners();
      
      // Create query
      Query query = _firestore.collection('services')
          .where('providerId', isEqualTo: providerId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true);
      
      // Apply pagination
      if (_lastServiceDocument != null) {
        query = query.startAfterDocument(_lastServiceDocument!);
      }
      
      // Limit results
      query = query.limit(_servicesPageSize);
      
      // Execute query
      QuerySnapshot querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        _hasMoreServices = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Save last document for pagination
      _lastServiceDocument = querySnapshot.docs.last;
      
      // Convert to service models
      List<ServiceModel> newServices = querySnapshot.docs
          .map((doc) => ServiceModel.fromSnap(doc))
          .toList();
      
      // Add to existing services
      if (refresh) {
        _services = newServices;
      } else {
        _services.addAll(newServices);
      }
      
      // Apply search filter
      _applyServiceFilters();
      
      _isLoading = false;
      if (querySnapshot.docs.length < _servicesPageSize) {
        _hasMoreServices = false;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Fetch services by category
  Future<void> fetchServicesByCategory(String category, {bool refresh = false}) async {
    _selectedCategory = category;
    await fetchServices(refresh: true);
  }
  
  // Fetch a service by ID
  Future<ServiceModel?> fetchServiceById(String serviceId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      DocumentSnapshot serviceDoc = await _firestore.collection('services').doc(serviceId).get();
      
      if (!serviceDoc.exists) {
        _isLoading = false;
        _error = 'Service not found';
        notifyListeners();
        return null;
      }
      
      _selectedService = ServiceModel.fromSnap(serviceDoc);
      
      _isLoading = false;
      notifyListeners();
      
      return _selectedService;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Search services
  Future<void> searchServices(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _applyServiceFilters();
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // For client-side search, we'll fetch all services and filter them
      // In a real app, you might want to use a server-side search solution
      await fetchServices(refresh: true);
      
      _applyServiceFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Apply service filters
  void _applyServiceFilters() {
    _filteredServices = List.from(_services);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final String query = _searchQuery.toLowerCase();
      _filteredServices = _filteredServices.where((service) {
        return service.title.toLowerCase().contains(query) ||
               service.description.toLowerCase().contains(query) ||
               (service.tags != null && service.tags!.any((tag) => tag.toLowerCase().contains(query)));
      }).toList();
    }
    
    // Apply price filter
    _filteredServices = _filteredServices.where((service) {
      return service.price >= _minPrice && service.price <= _maxPrice;
    }).toList();
  }
  
  // Set filters for services
  void setServiceFilters({
    String? category,
    String? sortBy,
    bool? sortAscending,
    double? minPrice,
    double? maxPrice,
    bool? showEmergencyOnly,
  }) {
    bool filtersChanged = false;
    
    if (category != null && category != _selectedCategory) {
      _selectedCategory = category;
      filtersChanged = true;
    }
    
    if (sortBy != null && sortBy != _sortBy) {
      _sortBy = sortBy;
      filtersChanged = true;
    }
    
    if (sortAscending != null && sortAscending != _sortAscending) {
      _sortAscending = sortAscending;
      filtersChanged = true;
    }
    
    if (minPrice != null && minPrice != _minPrice) {
      _minPrice = minPrice;
      filtersChanged = true;
    }
    
    if (maxPrice != null && maxPrice != _maxPrice) {
      _maxPrice = maxPrice;
      filtersChanged = true;
    }
    
    if (showEmergencyOnly != null && showEmergencyOnly != _showEmergencyOnly) {
      _showEmergencyOnly = showEmergencyOnly;
      filtersChanged = true;
    }
    
    if (filtersChanged) {
      if (_selectedCategory.isNotEmpty || _sortBy != 'createdAt' || _showEmergencyOnly) {
        // These filters need a new query from Firestore
        fetchServices(refresh: true);
      } else {
        // These filters can be applied client-side
        _applyServiceFilters();
        notifyListeners();
      }
    }
  }
  
  // Reset service filters
  void resetServiceFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _sortBy = 'createdAt';
    _sortAscending = false;
    _minPrice = 0;
    _maxPrice = 1000;
    _showEmergencyOnly = false;
    
    fetchServices(refresh: true);
  }
  
  // --------------- Provider Fetching ---------------
  
  // Fetch providers by category
  Future<void> fetchProvidersByCategory(String category, {bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    try {
      _isLoading = true;
      if (refresh) {
        _lastProviderDocument = null;
        _providers = [];
        _hasMoreProviders = true;
      }
      notifyListeners();
      
      // Create query
      Query query = _firestore.collection('users')
          .where('userType', isEqualTo: 'provider')
          .where('category', isEqualTo: category)
          .where('isActive', isEqualTo: true);
          
      // Apply verification filter
      if (_verifiedOnly) {
        query = query.where('isVerified', isEqualTo: true);
      }
      
      // Apply rating filter
      if (_minRating > 0) {
        query = query.where('rating', isGreaterThanOrEqualTo: _minRating);
      }
      
      // Apply pagination
      if (_lastProviderDocument != null) {
        query = query.startAfterDocument(_lastProviderDocument!);
      }
      
      // Sort by rating
      query = query.orderBy('rating', descending: true);
      
      // Limit results
      query = query.limit(_providersPageSize);
      
      // Execute query
      QuerySnapshot querySnapshot = await query.get();
      
      if (querySnapshot.docs.isEmpty) {
        _hasMoreProviders = false;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Save last document for pagination
      _lastProviderDocument = querySnapshot.docs.last;
      
      // Convert to provider models
      List<UserModel> newProviders = querySnapshot.docs
          .map((doc) => UserModel.fromSnap(doc))
          .toList();
      
      // Add to existing providers
      if (refresh) {
        _providers = newProviders;
      } else {
        _providers.addAll(newProviders);
      }
      
      // Apply search filter
      _applyProviderFilters();
      
      _isLoading = false;
      if (querySnapshot.docs.length < _providersPageSize) {
        _hasMoreProviders = false;
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Search providers
  void searchProviders(String query) {
    _providerSearchQuery = query;
    _applyProviderFilters();
    notifyListeners();
  }
  
  // Apply provider filters
  void _applyProviderFilters() {
    _filteredProviders = List.from(_providers);
    
    // Apply search filter
    if (_providerSearchQuery.isNotEmpty) {
      final String query = _providerSearchQuery.toLowerCase();
      _filteredProviders = _filteredProviders.where((provider) {
        return provider.firstName.toLowerCase().contains(query) ||
               provider.lastName.toLowerCase().contains(query) ||
               provider.category!.toLowerCase().contains(query) ||
               (provider.skills != null && provider.skills!.any((skill) => skill.toLowerCase().contains(query)));
      }).toList();
    }
  }
  
  // Set filters for providers
  void setProviderFilters({
    double? minRating,
    bool? verifiedOnly,
  }) {
    bool filtersChanged = false;
    
    if (minRating != null && minRating != _minRating) {
      _minRating = minRating;
      filtersChanged = true;
    }
    
    if (verifiedOnly != null && verifiedOnly != _verifiedOnly) {
      _verifiedOnly = verifiedOnly;
      filtersChanged = true;
    }
    
    if (filtersChanged) {
      // These filters need a new query from Firestore
      if (_selectedCategory.isNotEmpty) {
        fetchProvidersByCategory(_selectedCategory, refresh: true);
      }
    }
  }
  
  // Reset provider filters
  void resetProviderFilters() {
    _providerSearchQuery = '';
    _minRating = 0;
    _verifiedOnly = false;
    
    if (_selectedCategory.isNotEmpty) {
      fetchProvidersByCategory(_selectedCategory, refresh: true);
    }
  }
  
  // --------------- User (Provider) Operations ---------------
  
  // Fetch provider details by ID
  Future<UserModel?> fetchProviderById(String providerId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      DocumentSnapshot providerDoc = await _firestore.collection('users').doc(providerId).get();
      
      if (!providerDoc.exists) {
        _isLoading = false;
        _error = 'Provider not found';
        notifyListeners();
        return null;
      }
      
      UserModel provider = UserModel.fromSnap(providerDoc);
      
      // Ensure it's a provider
      if (provider.userType != 'provider') {
        _isLoading = false;
        _error = 'User is not a service provider';
        notifyListeners();
        return null;
      }
      
      _isLoading = false;
      notifyListeners();
      
      return provider;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Toggle provider availability
  Future<String> toggleProviderAvailability() async {
    if (_user == null || !_user!.isProvider) {
      return 'Not a service provider';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      bool newStatus = !(_user!.availableForWork ?? false);
      
      await _firestore.collection('users').doc(_user!.uid).update({
        'availableForWork': newStatus,
      });
      
      // Update local user object
      _user = _user!.copyWith(availableForWork: newStatus);
      
      _isLoading = false;
      notifyListeners();
      
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to update availability: ${e.toString()}';
    }
  }
  
  // --------------- Favorites ---------------
  
  // Add service to favorites
  Future<String> addServiceToFavorites(String serviceId) async {
    if (_user == null || !_user!.isSeeker) {
      return 'Not a service seeker';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current favorites
      List<String> favoriteServices = _user!.favoriteServices ?? [];
      
      // Add if not already in favorites
      if (!favoriteServices.contains(serviceId)) {
        favoriteServices.add(serviceId);
        // Update in Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          'favoriteServices': favoriteServices,
        });
        
        // Update local user object
        _user = _user!.copyWith(favoriteServices: favoriteServices);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to add to favorites: ${e.toString()}';
    }
  }
  
  // Remove service from favorites
  Future<String> removeServiceFromFavorites(String serviceId) async {
    if (_user == null || !_user!.isSeeker) {
      return 'Not a service seeker';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current favorites
      List<String> favoriteServices = _user!.favoriteServices ?? [];
      
      // Remove if in favorites
      if (favoriteServices.contains(serviceId)) {
        favoriteServices.remove(serviceId);
        
        // Update in Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          'favoriteServices': favoriteServices,
        });
        
        // Update local user object
        _user = _user!.copyWith(favoriteServices: favoriteServices);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to remove from favorites: ${e.toString()}';
    }
  }
  
  // Check if a service is in favorites
  bool isServiceFavorite(String serviceId) {
    if (_user == null || !_user!.isSeeker) {
      return false;
    }
    
    List<String> favoriteServices = _user!.favoriteServices ?? [];
    return favoriteServices.contains(serviceId);
  }
  
  // Fetch favorite services
  Future<void> fetchFavoriteServices() async {
    if (_user == null || !_user!.isSeeker) {
      return;
    }
    
    List<String> favoriteServices = _user!.favoriteServices ?? [];
    if (favoriteServices.isEmpty) {
      _services = [];
      _filteredServices = [];
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _services = [];
      
      // Firestore limits 'in' queries to 10 items, so we need to batch
      const int batchSize = 10;
      
      for (int i = 0; i < favoriteServices.length; i += batchSize) {
        int end = (i + batchSize < favoriteServices.length) 
            ? i + batchSize 
            : favoriteServices.length;
            
        List<String> batch = favoriteServices.sublist(i, end);
        
        QuerySnapshot querySnapshot = await _firestore.collection('services')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
            
        List<ServiceModel> batchServices = querySnapshot.docs
            .map((doc) => ServiceModel.fromSnap(doc))
            .toList();
            
        _services.addAll(batchServices);
      }
      
      _applyServiceFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Add provider to favorites
  Future<String> addProviderToFavorites(String providerId) async {
    if (_user == null || !_user!.isSeeker) {
      return 'Not a service seeker';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current favorites
      List<String> favoriteProviders = _user!.favoriteProviders ?? [];
      
      // Add if not already in favorites
      if (!favoriteProviders.contains(providerId)) {
        favoriteProviders.add(providerId);
        
        // Update in Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          'favoriteProviders': favoriteProviders,
        });
        
        // Update local user object
        _user = _user!.copyWith(favoriteProviders: favoriteProviders);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to add to favorites: ${e.toString()}';
    }
  }
  
  // Remove provider from favorites
  Future<String> removeProviderFromFavorites(String providerId) async {
    if (_user == null || !_user!.isSeeker) {
      return 'Not a service seeker';
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Get current favorites
      List<String> favoriteProviders = _user!.favoriteProviders ?? [];
      
      // Remove if in favorites
      if (favoriteProviders.contains(providerId)) {
        favoriteProviders.remove(providerId);
        
        // Update in Firestore
        await _firestore.collection('users').doc(_user!.uid).update({
          'favoriteProviders': favoriteProviders,
        });
        
        // Update local user object
        _user = _user!.copyWith(favoriteProviders: favoriteProviders);
      }
      
      _isLoading = false;
      notifyListeners();
      
      return 'success';
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return 'Failed to remove from favorites: ${e.toString()}';
    }
  }
  
  // Check if a provider is in favorites
  bool isProviderFavorite(String providerId) {
    if (_user == null || !_user!.isSeeker) {
      return false;
    }
    
    List<String> favoriteProviders = _user!.favoriteProviders ?? [];
    return favoriteProviders.contains(providerId);
  }
  
  // Fetch favorite providers
  Future<void> fetchFavoriteProviders() async {
    if (_user == null || !_user!.isSeeker) {
      return;
    }
    
    List<String> favoriteProviders = _user!.favoriteProviders ?? [];
    if (favoriteProviders.isEmpty) {
      _providers = [];
      _filteredProviders = [];
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      _providers = [];
      
      // Firestore limits 'in' queries to 10 items, so we need to batch
      const int batchSize = 10;
      
      for (int i = 0; i < favoriteProviders.length; i += batchSize) {
        int end = (i + batchSize < favoriteProviders.length) 
            ? i + batchSize 
            : favoriteProviders.length;
            
        List<String> batch = favoriteProviders.sublist(i, end);
        
        QuerySnapshot querySnapshot = await _firestore.collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
            
        List<UserModel> batchProviders = querySnapshot.docs
            .map((doc) => UserModel.fromSnap(doc))
            .toList();
            
        _providers.addAll(batchProviders);
      }
      
      _applyProviderFilters();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // --------------- Service Categories ---------------
  
  // Get all service categories
  Future<List<Map<String, dynamic>>> getServiceCategories() async {
    // This is a static list for simplicity
    // In a real app, you might want to fetch categories from Firestore
    return [
      {
        'id': 'home_repairs',
        'name': 'Home Repairs',
        'icon': Icons.home_repair_service,
        'color': Colors.blue,
        'description': 'General repairs and maintenance for your home'
      },
      {
        'id': 'cleaning',
        'name': 'Cleaning',
        'icon': Icons.cleaning_services,
        'color': Colors.green,
        'description': 'Professional cleaning services for homes and offices'
      },
      {
        'id': 'tutoring',
        'name': 'Tutoring',
        'icon': Icons.school,
        'color': Colors.purple,
        'description': 'Educational tutoring for students of all ages'
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing',
        'icon': Icons.plumbing,
        'color': Colors.blue,
        'description': 'Plumbing installation, repair and maintenance services'
      },
      {
        'id': 'electrical',
        'name': 'Electrical',
        'icon': Icons.electrical_services,
        'color': Colors.amber,
        'description': 'Electrical installation, repair and maintenance services'
      },
      {
        'id': 'transport',
        'name': 'Transport Helper',
        'icon': Icons.local_shipping,
        'color': Colors.teal,
        'description': 'Moving, delivery and transportation assistance'
      },
    ];
  }
  
  // Get category details by ID
  Map<String, dynamic>? getCategoryById(String categoryId) {
    List<Map<String, dynamic>> categories = [
      {
        'id': 'home_repairs',
        'name': 'Home Repairs',
        'icon': Icons.home_repair_service,
        'color': Colors.blue,
        'description': 'General repairs and maintenance for your home'
      },
      {
        'id': 'cleaning',
        'name': 'Cleaning',
        'icon': Icons.cleaning_services,
        'color': Colors.green,
        'description': 'Professional cleaning services for homes and offices'
      },
      {
        'id': 'tutoring',
        'name': 'Tutoring',
        'icon': Icons.school,
        'color': Colors.purple,
        'description': 'Educational tutoring for students of all ages'
      },
      {
        'id': 'plumbing',
        'name': 'Plumbing',
        'icon': Icons.plumbing,
        'color': Colors.blue,
        'description': 'Plumbing installation, repair and maintenance services'
      },
      {
        'id': 'electrical',
        'name': 'Electrical',
        'icon': Icons.electrical_services,
        'color': Colors.amber,
        'description': 'Electrical installation, repair and maintenance services'
      },
      {
        'id': 'transport',
        'name': 'Transport Helper',
        'icon': Icons.local_shipping,
        'color': Colors.teal,
        'description': 'Moving, delivery and transportation assistance'
      },
    ];
    
    try {
      return categories.firstWhere((category) => category['id'] == categoryId);
    } catch (e) {
      return null;
    }
  }
  
  // --------------- Analytics ---------------
  
  // Get service statistics for providers
  Future<Map<String, dynamic>> getServiceStats() async {
    if (_user == null || !_user!.isProvider) {
      return {
        'totalServices': 0,
        'activeServices': 0,
        'inactiveServices': 0,
        'averageRating': 0.0,
        'totalBookings': 0,
      };
    }
    
    try {
      await fetchMyServices(refresh: true);
      
      int totalServices = _services.length;
      int activeServices = _services.where((service) => service.isActive).length;
      int inactiveServices = totalServices - activeServices;
      
      // Get total bookings and average rating from user data
      double averageRating = _user!.rating ?? 0;
      int totalBookings = _user!.totalBookings ?? 0;
      
      return {
        'totalServices': totalServices,
        'activeServices': activeServices,
        'inactiveServices': inactiveServices,
        'averageRating': averageRating,
        'totalBookings': totalBookings,
      };
    } catch (e) {
      _error = e.toString();
      return {
        'totalServices': 0,
        'activeServices': 0,
        'inactiveServices': 0,
        'averageRating': 0.0,
        'totalBookings': 0,
        'error': e.toString(),
      };
    }
  }
  
  // Get service views and conversion rate
  // This would typically rely on analytics data that is not implemented
  Future<Map<String, dynamic>> getServiceInsights(String serviceId) async {
    // Placeholder for analytics data
    return {
      'views': 0,
      'bookings': 0,
      'conversionRate': 0.0,
      'averageRating': 0.0,
      'reviewCount': 0,
    };
  }
  
  // --------------- Helpers ---------------
  
  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
  
  // Get formatted price
  String formatPrice(double price) {
    return 'RM ${price.toStringAsFixed(2)}';
  }
  
  // Check if emergency services are available
  bool hasEmergencyServices(String category) {
    // In a real app, you might want to fetch this information from Firestore
    // For simplicity, we'll just return true for some categories
    return ['plumbing', 'electrical', 'home_repairs'].contains(category);
  }
  
  // Get available time slots for a provider on a specific date
  Future<List<TimeOfDay>> getAvailableTimeSlots(String providerId, DateTime date) async {
    // In a real app, you would fetch the provider's availability from Firestore
    // For simplicity, we'll return a predefined list
    
    // Default time slots
    List<TimeOfDay> allTimeSlots = [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
    ];
    
    // In a real app, you would check existing bookings for this provider on this date
    // and remove booked time slots
    
    return allTimeSlots;
  }
  
  // Get a list of skills for a specific category
  List<String> getSkillsForCategory(String category) {
    // In a real app, you might want to fetch this information from Firestore
    switch (category) {
      case 'home_repairs':
        return [
          'Furniture Assembly',
          'Wall Mounting',
          'Door Installation',
          'Window Repair',
          'Floor Repair',
          'General Repair',
        ];
      case 'cleaning':
        return [
          'House Cleaning',
          'Office Cleaning',
          'Deep Cleaning',
          'Move-in/Move-out Cleaning',
          'Carpet Cleaning',
          'Window Cleaning',
        ];
      case 'tutoring':
        return [
          'Mathematics',
          'Science',
          'English',
          'History',
          'Computer Science',
          'Music',
          'Art',
        ];
      case 'plumbing':
        return [
          'Pipe Installation',
          'Leak Repair',
          'Drain Cleaning',
          'Toilet Repair',
          'Water Heater',
          'Faucet Installation',
        ];
      case 'electrical':
        return [
          'Wiring Installation',
          'Outlet Repair',
          'Lighting Installation',
          'Circuit Breaker',
          'Fan Installation',
          'Electrical Testing',
        ];
      case 'transport':
        return [
          'Moving Assistance',
          'Furniture Delivery',
          'Grocery Delivery',
          'Package Pickup',
          'Airport Transport',
          'Shopping Helper',
        ];
      default:
        return [];
    }
  }
}