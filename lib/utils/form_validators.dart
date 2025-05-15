import 'dart:io';

class FormValidators {
  // Prevent instantiation
  FormValidators._();

  //-------------------------------------------------------------------------
  // Authentication Validators
  //-------------------------------------------------------------------------
  
  /// Validate email address format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validate simple password (less strict, for login)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    return null;
  }
  
  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validate current password (for changing password)
  static String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    
    return null;
  }

  //-------------------------------------------------------------------------
  // User Profile Validators
  //-------------------------------------------------------------------------
  
  /// Validate first name
  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    
    if (value.length < 2) {
      return 'First name must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final nameRegExp = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegExp.hasMatch(value)) {
      return 'First name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validate last name
  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    
    if (value.length < 2) {
      return 'Last name must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, hyphens, apostrophes)
    final nameRegExp = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegExp.hasMatch(value)) {
      return 'Last name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }
  
  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Regular expression for Malaysian phone numbers
    // Accepts formats like: 01X-XXXXXXX, 01X XXXXXXX, 01XXXXXXXX
    final phoneRegExp = RegExp(r'^(01[0-9])[0-9]{7,8}$');
    
    // Remove spaces, dashes, and parentheses to normalize
    final normalizedPhone = value.replaceAll(RegExp(r'[\s\-()]'), '');
    
    if (!phoneRegExp.hasMatch(normalizedPhone)) {
      return 'Please enter a valid Malaysian phone number';
    }
    
    return null;
  }
  
  /// Validate user bio (for provider profile)
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bio is required';
    }
    
    if (value.length < 20) {
      return 'Bio must be at least 20 characters long';
    }
    
    if (value.length > 500) {
      return 'Bio cannot exceed 500 characters';
    }
    
    return null;
  }
  
  /// Validate IC number (for providers)
  static String? validateIcNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'IC number is required';
    }
    
    // Regular expression for Malaysian IC numbers (YYMMDD-PB-###G)
    final icRegExp = RegExp(r'^[0-9]{6}-[0-9]{2}-[0-9]{4}$');
    
    // Remove spaces and dashes to normalize
    final normalizedIc = value.replaceAll('-', '');
    
    if (normalizedIc.length != 12 || !normalizedIc.contains(RegExp(r'^[0-9]+$'))) {
      return 'Please enter a valid Malaysian IC number (YYMMDD-PB-###G)';
    }
    
    return null;
  }
  
  /// Validate bank account number
  static String? validateBankAccount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bank account number is required';
    }
    
    // Regular expression for numeric characters only
    final numericRegExp = RegExp(r'^[0-9]+$');
    
    // Remove spaces and dashes to normalize
    final normalizedAccount = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (!numericRegExp.hasMatch(normalizedAccount)) {
      return 'Bank account number can only contain numbers';
    }
    
    if (normalizedAccount.length < 8 || normalizedAccount.length > 17) {
      return 'Bank account number should be between 8 and 17 digits';
    }
    
    return null;
  }

  //-------------------------------------------------------------------------
  // Service Validators
  //-------------------------------------------------------------------------
  
  /// Validate service title
  static String? validateServiceTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service title is required';
    }
    
    if (value.length < 5) {
      return 'Service title must be at least 5 characters long';
    }
    
    if (value.length > 100) {
      return 'Service title cannot exceed 100 characters';
    }
    
    return null;
  }
  
  /// Validate service description
  static String? validateServiceDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service description is required';
    }
    
    if (value.length < 50) {
      return 'Service description must be at least 50 characters long';
    }
    
    if (value.length > 1000) {
      return 'Service description cannot exceed 1000 characters';
    }
    
    return null;
  }
  
  /// Validate service price
  static String? validateServicePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service price is required';
    }
    
    // Regular expression for decimal numbers
    final priceRegExp = RegExp(r'^\d+(\.\d{1,2})?$');
    
    if (!priceRegExp.hasMatch(value)) {
      return 'Please enter a valid price (e.g., 50 or 50.99)';
    }
    
    final double price = double.tryParse(value) ?? 0;
    
    if (price <= 0) {
      return 'Price must be greater than zero';
    }
    
    if (price > 10000) {
      return 'Price cannot exceed RM 10,000';
    }
    
    return null;
  }
  
  /// Validate service category selection
  static String? validateServiceCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a service category';
    }
    
    return null;
  }
  
  /// Validate service tags
  static String? validateServiceTags(List<String>? tags) {
    if (tags == null || tags.isEmpty) {
      return 'Please add at least one tag';
    }
    
    if (tags.length > 10) {
      return 'Cannot add more than 10 tags';
    }
    
    return null;
  }
  
  /// Validate service duration
  static String? validateServiceDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Service duration is required';
    }
    
    final int? duration = int.tryParse(value);
    
    if (duration == null || duration <= 0) {
      return 'Please enter a valid duration';
    }
    
    return null;
  }
  
  /// Validate service image
  static String? validateServiceImage(File? image) {
    if (image == null) {
      return 'Please upload a service image';
    }
    
    return null;
  }

  //-------------------------------------------------------------------------
  // Booking Validators
  //-------------------------------------------------------------------------
  
  /// Validate booking address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    
    return null;
  }
  
  /// Validate booking date
  static String? validateBookingDate(DateTime? date) {
    if (date == null) {
      return 'Please select a date';
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    
    if (selectedDate.isBefore(today)) {
      return 'Cannot select a past date';
    }
    
    // Cannot book more than 3 months in advance
    final maxDate = today.add(const Duration(days: 90));
    if (selectedDate.isAfter(maxDate)) {
      return 'Cannot book more than 3 months in advance';
    }
    
    return null;
  }
  
  /// Validate booking time
  static String? validateBookingTime(DateTime? time) {
    if (time == null) {
      return 'Please select a time';
    }
    
    // Check if booking time is between 8am and 8pm
    if (time.hour < 8 || time.hour >= 20) {
      return 'Booking time must be between 8:00 AM and 8:00 PM';
    }
    
    return null;
  }
  
  /// Validate payment method
  static String? validatePaymentMethod(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a payment method';
    }
    
    return null;
  }
  
  /// Validate special instructions
  static String? validateSpecialInstructions(String? value) {
    if (value != null && value.length > 500) {
      return 'Special instructions cannot exceed 500 characters';
    }
    
    return null;
  }
  
  /// Validate cancellation reason
  static String? validateCancellationReason(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide a reason for cancellation';
    }
    
    if (value.length < 10) {
      return 'Reason must be at least 10 characters long';
    }
    
    return null;
  }
  
  /// Validate emergency details
  static String? validateEmergencyDetails(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide emergency details';
    }
    
    if (value.length < 20) {
      return 'Please provide more details about the emergency';
    }
    
    return null;
  }

  //-------------------------------------------------------------------------
  // Rating and Review Validators
  //-------------------------------------------------------------------------
  
  /// Validate rating value
  static String? validateRating(double? value) {
    if (value == null || value <= 0) {
      return 'Please select a rating';
    }
    
    return null;
  }
  
  /// Validate review text
  static String? validateReview(String? value) {
    if (value != null && value.isNotEmpty && value.length < 5) {
      return 'Review must be at least 5 characters long';
    }
    
    if (value != null && value.length > 500) {
      return 'Review cannot exceed 500 characters';
    }
    
    return null;
  }

  //-------------------------------------------------------------------------
  // Other Common Validators
  //-------------------------------------------------------------------------
  
  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Validate text field character limit
  static String? validateCharLimit(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // Not required
    }
    
    if (value.length > maxLength) {
      final field = fieldName != null ? '$fieldName ' : '';
      return '${field}cannot exceed $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate search query
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a search term';
    }
    
    if (value.length < 2) {
      return 'Search term must be at least 2 characters long';
    }
    
    return null;
  }
  
  /// Validate file size
  static String? validateFileSize(File? file, int maxSizeInMB) {
    if (file == null) {
      return null; // Not required
    }
    
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    
    if (fileSizeInMB > maxSizeInMB) {
      return 'File size cannot exceed $maxSizeInMB MB';
    }
    
    return null;
  }
  
  /// Validate file type (by extension)
  static String? validateFileType(File? file, List<String> allowedExtensions) {
    if (file == null) {
      return null; // Not required
    }
    
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    
    if (!allowedExtensions.contains(extension)) {
      return 'Only ${allowedExtensions.join(', ')} files are allowed';
    }
    
    return null;
  }
  
  /// Validate image dimensions
  static String? validateImageDimensions(
    int width,
    int height, {
    int? minWidth,
    int? minHeight,
    int? maxWidth,
    int? maxHeight,
  }) {
    if (minWidth != null && width < minWidth) {
      return 'Image width must be at least $minWidth pixels';
    }
    
    if (minHeight != null && height < minHeight) {
      return 'Image height must be at least $minHeight pixels';
    }
    
    if (maxWidth != null && width > maxWidth) {
      return 'Image width cannot exceed $maxWidth pixels';
    }
    
    if (maxHeight != null && height > maxHeight) {
      return 'Image height cannot exceed $maxHeight pixels';
    }
    
    return null;
  }
}