// lib/screens/seeker/services/service_category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/service_provider.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/widgets/cards/service_card.dart';
import 'package:handy_buddy/widgets/inputs/search_input.dart';

class ServiceCategoryScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  
  const ServiceCategoryScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<ServiceCategoryScreen> createState() => _ServiceCategoryScreenState();
}

class _ServiceCategoryScreenState extends State<ServiceCategoryScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showFilterOptions = false;
  String _sortBy = 'createdAt'; // Options: price, rating, createdAt
  bool _sortAscending = false;
  double _minPrice = 0;
  double _maxPrice = 1000;
  bool _showEmergencyOnly = false;
  
  @override
  void initState() {
    super.initState();
    _fetchServicesByCategory();
  }
  
  Future<void> _fetchServicesByCategory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch services by category
      await Provider.of<ServiceProvider>(context, listen: false)
          .fetchServicesByCategory(widget.categoryId);
    } catch (e) {
      print('Error fetching services: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    // Search services
    Provider.of<ServiceProvider>(context, listen: false)
        .searchServices(query);
  }
  
  void _onFilterTap() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
    });
  }
  
  void _applySortAndFilters() {
    Provider.of<ServiceProvider>(context, listen: false).setServiceFilters(
      sortBy: _sortBy,
      sortAscending: _sortAscending,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      showEmergencyOnly: _showEmergencyOnly,
    );
    
    setState(() {
      _showFilterOptions = false;
    });
  }
  
  void _resetFilters() {
    setState(() {
      _sortBy = 'createdAt';
      _sortAscending = false;
      _minPrice = 0;
      _maxPrice = 1000;
      _showEmergencyOnly = false;
    });
    
    Provider.of<ServiceProvider>(context, listen: false).resetServiceFilters();
  }
  
  void _viewServiceDetails(ServiceModel service) {
    Routes.navigateTo(
      context,
      Routes.serviceDetail,
      arguments: service.serviceId,
    );
  }
  
  void _bookService(ServiceModel service) {
    Routes.navigateTo(
      context,
      Routes.booking,
      arguments: {
        'serviceId': service.serviceId,
        'providerId': service.providerId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;
    final List<ServiceModel> services = serviceProvider.services;
    final bool isLoading = serviceProvider.isLoading || _isLoading;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: AppColors.primary,
        elevation: 0,
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
              hintText: 'Search ${widget.categoryName}...',
              onSearch: _onSearch,
              backgroundColor: Colors.white,
              showFilterButton: true,
              onFilterTap: _onFilterTap,
            ),
          ),
          
          // Filter Options (expandable)
          if (_showFilterOptions)
            _buildFilterOptions(),
          
          // Services List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchServicesByCategory,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : services.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return ServiceCard(
                              service: service,
                              viewType: 'seeker',
                              onTap: () => _viewServiceDetails(service),
                              onBook: () => _bookService(service),
                              showProviderInfo: true,
                              providerInfo: {
                                'firstName': 'Provider',
                                'lastName': 'Name',
                                'rating': 4.5,
                              }, // This would be fetched in a real app
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sort & Filter',
                style: AppStyles.subheadingStyle,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showFilterOptions = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sort Options
          const Text(
            'Sort By',
            style: AppStyles.labelLargeStyle,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip(
                label: 'Newest',
                value: 'createdAt',
                ascending: false,
              ),
              _buildSortChip(
                label: 'Price: Low to High',
                value: 'price',
                ascending: true,
              ),
              _buildSortChip(
                label: 'Price: High to Low',
                value: 'price',
                ascending: false,
              ),
              _buildSortChip(
                label: 'Rating',
                value: 'rating',
                ascending: false,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Price Range
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range',
                style: AppStyles.labelLargeStyle,
              ),
              Text(
                'RM${_minPrice.toInt()} - RM${_maxPrice.toInt() == 1000 ? "1000+" : _maxPrice.toInt()}',
                style: AppStyles.bodyTextBoldStyle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.borderLight,
            labels: RangeLabels(
              'RM${_minPrice.toInt()}',
              'RM${_maxPrice.toInt() == 1000 ? "1000+" : _maxPrice.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Emergency Services Only
          Row(
            children: [
              Checkbox(
                value: _showEmergencyOnly,
                onChanged: (value) {
                  setState(() {
                    _showEmergencyOnly = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
              ),
              const Text(
                'Show Emergency Services Only',
                style: AppStyles.bodyTextStyle,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Apply and Reset Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textSecondary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applySortAndFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortChip({
    required String label,
    required String value,
    required bool ascending,
  }) {
    final bool isSelected = _sortBy == value && _sortAscending == ascending;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _sortBy = value;
          _sortAscending = ascending;
        });
      },
      backgroundColor: AppColors.backgroundLight,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_services.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Found',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'There are no services available in this category at the moment.'
                : 'No services match your search criteria.',
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty)
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Search'),
              onPressed: () {
                _onSearch('');
              },
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
}