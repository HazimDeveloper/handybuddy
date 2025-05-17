// lib/screens/provider/home/manage_service_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:handy_buddy/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:handy_buddy/constants/app_colors.dart';
import 'package:handy_buddy/constants/app_styles.dart';
import 'package:handy_buddy/constants/app_texts.dart';
import 'package:handy_buddy/models/service_model.dart';
import 'package:handy_buddy/providers/service_provider.dart';
import 'package:handy_buddy/utils/toast_util.dart';
import 'package:handy_buddy/widgets/buttons/custom_button.dart';
import 'package:handy_buddy/widgets/buttons/outlined_button.dart' as custom_outlined;
import 'package:handy_buddy/widgets/cards/service_card.dart';
import 'package:handy_buddy/widgets/dialogs/confirm_dialog.dart';
import 'package:handy_buddy/widgets/inputs/search_input.dart';
import 'package:handy_buddy/widgets/inputs/text_input.dart';

class ManageServiceScreen extends StatefulWidget {
  const ManageServiceScreen({Key? key}) : super(key: key);

  @override
  State<ManageServiceScreen> createState() => _ManageServiceScreenState();
}

class _ManageServiceScreenState extends State<ManageServiceScreen> {
  bool _isLoading = false;
  bool _isAddingService = false;
  bool _isEditingService = false;
  
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedCategory = '';
  ServiceModel? _editingService;
  String _searchQuery = '';
  File? _serviceImage;
  
  final List<Map<String, dynamic>> _categories = [
    {'id': 'home_repairs', 'name': 'Home Repairs'},
    {'id': 'cleaning', 'name': 'Cleaning Service'},
    {'id': 'tutoring', 'name': 'Tutoring'},
    {'id': 'plumbing', 'name': 'Plumbing Services'},
    {'id': 'electrical', 'name': 'Electrical Services'},
    {'id': 'transport', 'name': 'Transport Helper'},
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
// Replace the _loadServices method with this updated version

Future<void> _loadServices() async {
  setState(() {
    _isLoading = true;
  });

  try {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final String? providerId = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    
    if (providerId == null) {
      ToastUtils.showErrorToast('User not authenticated');
      return;
    }
    
    await serviceProvider.fetchProviderServices(providerId);
  } catch (e) {
    ToastUtils.showErrorToast('Error loading services: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _showAddServiceForm() {
    setState(() {
      _isAddingService = true;
      _isEditingService = false;
      _editingService = null;
      _resetForm();
    });
  }

  void _showEditServiceForm(ServiceModel service) {
    setState(() {
      _isAddingService = false;
      _isEditingService = true;
      _editingService = service;
      
      _titleController.text = service.title;
      _descriptionController.text = service.description;
      _priceController.text = service.price.toString();
      _selectedCategory = service.category;
      _serviceImage = null;
    });
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _selectedCategory = '';
    _serviceImage = null;
  }

  void _cancelForm() {
    setState(() {
      _isAddingService = false;
      _isEditingService = false;
      _editingService = null;
      _resetForm();
    });
  }

  Future<void> _pickServiceImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    
    if (image != null) {
      setState(() {
        _serviceImage = File(image.path);
      });
    }
  }
// Replace the _saveService method with this updated version

Future<void> _saveService() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  if (_selectedCategory.isEmpty) {
    ToastUtils.showErrorToast('Please select a service category');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    final double price = double.parse(_priceController.text);
    
    String result;
    if (_isEditingService) {
      // Update existing service
      result = await serviceProvider.updateService(
        serviceId: _editingService!.serviceId,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: price,
        // Pass serviceImage only if it's not null
        serviceImage: _serviceImage,
      );
    } else {
      // Create new service - Handle the case where serviceImage could be null
      result = await serviceProvider.createService(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        price: price,
        // Pass serviceImage only if it's not null
        serviceImage: _serviceImage,
      );
    }

    if (result == 'success') {
      ToastUtils.showSuccessToast(
        _isEditingService 
            ? 'Service updated successfully' 
            : 'Service created successfully'
      );
      
      setState(() {
        _isAddingService = false;
        _isEditingService = false;
        _editingService = null;
        _resetForm();
      });
      
      await _loadServices();
    } else {
      ToastUtils.showErrorToast('Failed to save service: $result');
    }
  } catch (e) {
    ToastUtils.showErrorToast('Error saving service: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  Future<void> _deleteService(ServiceModel service) async {
    final confirmed = await ConfirmDialog.showDeleteServiceConfirmation(context);
    
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final success = await serviceProvider.deleteService(service.serviceId);

      if (success == true) {
        ToastUtils.showSuccessToast('Service deleted successfully');
        await _loadServices();
      } else {
        ToastUtils.showErrorToast('Failed to delete service');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Error deleting service: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Replace the _toggleServiceStatus method with this updated version

Future<void> _toggleServiceStatus(ServiceModel service) async {
  setState(() {
    _isLoading = true;
  });

  try {
    final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
    // Just pass the serviceId - the method likely reads the current status internally
    final result = await serviceProvider.toggleServiceStatus(service.serviceId);

    if (result == 'success') {
      ToastUtils.showSuccessToast(
        service.isActive 
            ? 'Service deactivated successfully' 
            : 'Service activated successfully'
      );
      await _loadServices();
    } else {
      ToastUtils.showErrorToast('Failed to update service status: $result');
    }
  } catch (e) {
    ToastUtils.showErrorToast('Error updating service status: ${e.toString()}');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Services'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAddingService || _isEditingService
              ? _buildServiceForm()
              : _buildServiceList(),
      floatingActionButton: !_isAddingService && !_isEditingService
          ? FloatingActionButton(
              onPressed: _showAddServiceForm,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildServiceList() {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        final services = serviceProvider.providerServices;
        
        // Filter services by search query
        final filteredServices = _searchQuery.isEmpty
            ? services
            : services?.where((service) {
                return service.title.toLowerCase().contains(_searchQuery) ||
                    service.description.toLowerCase().contains(_searchQuery) ||
                    service.category.toLowerCase().contains(_searchQuery);
              }).toList();

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchInput(
                hintText: 'Search services',
                onSearch: _onSearch,
              ),
            ),
            
            // Services list
            Expanded(
              child: services!.isEmpty
                  ? _buildEmptyState()
                  : filteredServices!.isEmpty
                      ? _buildNoResultsState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredServices.length,
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return ServiceCard(
                              service: service,
                              viewType: 'provider',
                              onTap: () => _showEditServiceForm(service),
                              onEdit: () => _showEditServiceForm(service),
                              onToggleActive: () => _toggleServiceStatus(service),
                              onBook: null,
                              showProviderInfo: false,
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceForm() {
    final title = _isEditingService ? 'Edit Service' : 'Add New Service';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppStyles.headingStyle,
            ),
            const SizedBox(height: 24),
            
            // Service Image
            GestureDetector(
              onTap: _pickServiceImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                  image: _serviceImage != null
                      ? DecorationImage(
                          image: FileImage(_serviceImage!),
                          fit: BoxFit.cover,
                        )
                      : _isEditingService && _editingService!.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_editingService!.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                ),
                child: _serviceImage == null && 
                       (_editingService == null || _editingService!.imageUrl == null)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_a_photo,
                            color: AppColors.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add service image',
                            style: AppStyles.bodyTextStyle.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Service Title
            TextInput(
              label: 'Service Title',
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a service title';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            
            // Service Category
            Text(
              'Service Category',
              style: AppStyles.labelStyle,
            ),
            const SizedBox(height: 12),
            
            // Categories Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final bool isSelected = _selectedCategory == category['id'];
                
                return FilterChip(
                  label: Text(category['name']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category['id'] : '';
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
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Service Price
            TextInput(
              label: 'Price (RM)',
              controller: _priceController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid price';
                }
                
                if (double.parse(value) <= 0) {
                  return 'Price must be greater than 0';
                }
                
                return null;
              },
              textInputAction: TextInputAction.next,
              prefix: const Icon(
                Icons.attach_money,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 16),
            
            // Service Description
            TextAreaInput(
              label: 'Service Description',
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a service description';
                }
                
                if (value.length < 10) {
                  return 'Description must be at least 10 characters';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: custom_outlined.OutlinedButton(
                    text: 'Cancel',
                    onPressed: _cancelForm,
                    textColor: AppColors.textSecondary,
                    borderColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: _isEditingService ? 'Update' : 'Add Service',
                    onPressed: _saveService,
                    isLoading: _isLoading,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            // Delete button (for editing only)
            if (_isEditingService) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: custom_outlined.OutlinedButton(
                  text: 'Delete Service',
                  onPressed: () => _deleteService(_editingService!),
                  borderColor: AppColors.error,
                  textColor: AppColors.error,
                  prefixIcon: Icons.delete,
                ),
              ),
            ],
            
            const SizedBox(height: 32), // Bottom spacing
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.home_repair_service,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Yet',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first service to start getting bookings',
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Add Service',
            onPressed: _showAddServiceForm,
            backgroundColor: AppColors.primary,
            prefixIcon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: AppStyles.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'No services match "$_searchQuery"',
            textAlign: TextAlign.center,
            style: AppStyles.bodyTextStyle,
          ),
          const SizedBox(height: 24),
          custom_outlined.OutlinedButton(
            text: 'Clear Search',
            onPressed: () => _onSearch(''),
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
            prefixIcon: Icons.clear,
          ),
        ],
      ),
    );
  }
}