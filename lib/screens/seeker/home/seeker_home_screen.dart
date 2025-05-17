// lib/screens/seeker/home/seeker_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/user_model.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:handy_buddy/providers/service_provider.dart' as service_provider;
import 'package:handy_buddy/routes.dart';
import 'package:handy_buddy/widgets/inputs/search_input.dart';

class SeekerHomeScreen extends StatefulWidget {
  const SeekerHomeScreen({Key? key}) : super(key: key);

  @override
  State<SeekerHomeScreen> createState() => _SeekerHomeScreenState();
}

class _SeekerHomeScreenState extends State<SeekerHomeScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'home_repairs',
      'name': AppTexts.homeRepairs,
      'icon': Icons.home_repair_service,
      'color': const Color(0xFF6366F1),
    },
    {
      'id': 'cleaning',
      'name': AppTexts.cleaningService,
      'icon': Icons.cleaning_services,
      'color': const Color(0xFF22C55E),
    },
    {
      'id': 'tutoring',
      'name': AppTexts.tutoring,
      'icon': Icons.school,
      'color': const Color(0xFFEC4899),
    },
    {
      'id': 'plumbing',
      'name': AppTexts.plumbingServices,
      'icon': Icons.plumbing,
      'color': const Color(0xFF4C85E2),
    },
    {
      'id': 'electrical',
      'name': AppTexts.electricalServices,
      'icon': Icons.electrical_services,
      'color': const Color(0xFFF59E0B),
    },
    {
      'id': 'transport',
      'name': AppTexts.transportHelper,
      'icon': Icons.local_shipping,
      'color': const Color(0xFF0EA5E9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch user data if available
    await Provider.of<AuthProvider>(context, listen: false).refreshUserData();

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToCategory(String categoryId, String categoryName) {
    Routes.navigateTo(
      context,
      Routes.serviceCategory,
      arguments: categoryId,
    );
  }

  void _onSearch(String query) {
    if (query.isEmpty) return;
    
    // Navigate to category screen with search query
    Routes.navigateTo(
      context,
      Routes.serviceCategory,
      arguments: {'query': query},
    );
  }

  void _navigateToEmergency() {
    Routes.navigateTo(
      context,
      Routes.serviceCategory,
      arguments: {'isEmergency': true},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user data
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: AppColors.primary,
              expandedHeight: 120,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user != null 
                            ? 'Hello, ${user.firstName}!'
                            : 'Hello there!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Find service providers near you',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.primary,
                  child: SearchInput(
                    hintText: AppTexts.searchForServices,
                    onSearch: _onSearch,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Categories
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            AppTexts.serviceCategories,
                            style: AppStyles.subheadingStyle,
                          ),
                        ),
                        
                        // Categories Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            
                            return GestureDetector(
                              onTap: () => _navigateToCategory(
                                category['id'], 
                                category['name'],
                              ),
                              child: Container(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: category['color'].withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category['icon'],
                                        size: 32,
                                        color: category['color'],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category['name'],
                                      textAlign: TextAlign.center,
                                      style: AppStyles.bodyTextStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Emergency Services
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEF4444), Color(0xFFFF6B6B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: _navigateToEmergency,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.emergency,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppTexts.emergencyServices,
                                            style: AppStyles.subheadingStyle.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            AppTexts.emergencyServicesSubtitle,
                                            style: AppStyles.bodyTextStyle.copyWith(
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Featured Providers (Placeholder)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppTexts.featuredProviders,
                                    style: AppStyles.subheadingStyle,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Navigate to see all featured providers
                                    },
                                    child: Text(
                                      AppTexts.viewAll,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Provider Cards
                              _buildProviderCard(
                                name: 'John Smith',
                                category: 'Plumbing',
                                rating: 4.9,
                                imageUrl: null,
                              ),
                              
                              _buildProviderCard(
                                name: 'Mary Johnson',
                                category: 'Electrical',
                                rating: 4.7,
                                imageUrl: null,
                              ),
                              
                              _buildProviderCard(
                                name: 'David Lee',
                                category: 'Home Repairs',
                                rating: 4.8,
                                imageUrl: null,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProviderCard({
    required String name,
    required String category,
    required double rating,
    String? imageUrl,
  }) {
    return Container(
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
      child: InkWell(
        onTap: () {
          // Navigate to provider profile
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Text(
                        name.substring(0, 1),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppStyles.bodyTextMediumStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: AppStyles.captionStyle,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AppStyles.bodySmallBoldStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}