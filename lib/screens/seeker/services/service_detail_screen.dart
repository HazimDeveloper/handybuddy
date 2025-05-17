// lib/screens/seeker/services/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/service_provider.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/cards/provider_card.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  
  const ServiceDetailScreen({
    Key? key,
    required this.serviceId,
  }) : super(key: key);

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  bool _isLoading = false;
  ServiceModel? _service;
  UserModel? _provider;
  bool _isFavorite = false;
  
  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }
  
  Future<void> _fetchServiceDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch service details
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      _service = await serviceProvider.fetchServiceById(widget.serviceId);
      
      if (_service != null) {
        // Fetch provider details
        _provider = await Provider.of<AuthProvider>(context, listen: false)
            .getUserById(_service!.providerId);
            
        // Check if service is in favorites
        _isFavorite = serviceProvider.isServiceFavorite(widget.serviceId);
      }
    } catch (e) {
      print('Error fetching service details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _navigateToBookService() {
    if (_service == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in
    if (!authProvider.isLoggedIn) {
      // Show login prompt
      _showLoginPrompt();
      return;
    }
    
    // Navigate to booking screen
    Routes.navigateTo(
      context,
      Routes.booking,
      arguments: {
        'serviceId': _service!.serviceId,
        'providerId': _service!.providerId,
      },
    );
  }
  // In the _navigateToEmergencyRequest() method:
void _navigateToEmergencyRequest() {
  if (_service == null || _provider == null) return;
  
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  // Check if user is logged in
  if (!authProvider.isLoggedIn) {
    // Show login prompt
    _showLoginPrompt();
    return;
  }
  
  // Navigate to emergency request screen
  Routes.navigateTo(
    context,
    Routes.emergencyRequest,  // Use the correct route name
    arguments: {
      'service': _service,
      'provider': _provider,
    },
  );
}
  
  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to login to book this service. Would you like to login now?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Routes.navigateTo(context, Routes.seekerLogin);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _toggleFavorite() async {
    if (_service == null) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is logged in
    if (!authProvider.isLoggedIn) {
      // Show login prompt
      _showLoginPrompt();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      String result;
      
      if (_isFavorite) {
        // Remove from favorites
        result = await serviceProvider.removeServiceFromFavorites(_service!.serviceId);
      } else {
        // Add to favorites
        result = await serviceProvider.addServiceToFavorites(_service!.serviceId);
      }
      
      if (result == 'success') {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        
        ToastUtils.showSuccessToast(
          _isFavorite 
            ? 'Added to favorites' 
            : 'Removed from favorites'
        );
      } else {
        ToastUtils.showErrorToast('Failed to update favorites');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _shareService() {
    // This would use a share package in a real app
    ToastUtils.showInfoToast('Sharing feature coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_service == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Service Details'),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Service Not Found',
                style: AppStyles.subheadingStyle,
              ),
              const SizedBox(height: 8),
              const Text(
                'The service you are looking for is not available.',
                textAlign: TextAlign.center,
                style: AppStyles.bodyTextStyle,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Service Image
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: _service!.imageUrl != null && _service!.imageUrl!.isNotEmpty
                  ? Image.network(
                      _service!.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.backgroundLight,
                      child: const Center(
                        child: Icon(
                          Icons.home_repair_service,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareService,
              ),
            ],
          ),
          
          // Service Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getCategoryColor(_service!.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _service!.formattedCategory,
                      style: AppStyles.captionBoldStyle.copyWith(
                        color: AppColors.getCategoryColor(_service!.category),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Service Title
                  Text(
                    _service!.title,
                    style: AppStyles.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  
                  // Price and Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _service!.formattedPrice,
                        style: AppStyles.headingMediumStyle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      if (_service!.estimatedDuration != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _service!.formattedDuration,
                              style: AppStyles.bodyTextStyle.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Service Description
                  const Text(
                    'Description',
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _service!.description,
                    style: AppStyles.bodyTextStyle,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  if (_service!.tags != null && _service!.tags!.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: AppStyles.labelLargeStyle,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _service!.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tag,
                            style: AppStyles.captionStyle,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Emergency Service Info
                  if (_service!.hasEmergencyService) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Emergency Service Available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Emergency service price: ${_service!.formattedEmergencyPrice ?? "Contact provider"}',
                            style: AppStyles.bodyTextStyle,
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Request Emergency Service',
                            onPressed: _navigateToEmergencyRequest,
                            backgroundColor: AppColors.error,
                            prefixIcon: Icons.warning_amber_rounded,
                            isFullWidth: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Service Provider Info
                  const Text(
                    'Service Provider',
                    style: AppStyles.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  
                  if (_provider != null)
                    ProviderCard(
                      provider: _provider!,
                      onViewProfile: () {
                        // Navigate to provider profile
                      },
                      onBookNow: _navigateToBookService,
                      isCompact: false,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.borderLight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Provider information not available',
                          style: AppStyles.bodyTextStyle,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 100), // Space for bottom actions
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: custom_outlined.OutlinedButton(
                text: 'Contact Provider',
                onPressed: () {
                  if (_service == null || _provider == null) return;
                  
                  Routes.navigateTo(
                    context,
                    Routes.chat,
                    arguments: {
                      'providerId': _service!.providerId,
                      'serviceId': _service!.serviceId,
                    },
                  );
                },
                prefixIcon: Icons.chat_bubble_outline,
                borderColor: AppColors.secondary,
                textColor: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Book Now',
                onPressed: _navigateToBookService,
                backgroundColor: AppColors.primary,
                prefixIcon: Icons.calendar_today,
              ),
            ),
          ],
        ),
      ),
    );
  }
}