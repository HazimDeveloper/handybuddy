// constants/app_texts.dart

/// AppTexts defines all text constants used throughout the Handy Buddy app.
/// This makes it easier to maintain consistent terminology and enables
/// future localization by centralizing all text strings.

class AppTexts {
  // App Core
  static const String appName = 'Handy Buddy';
  static const String appTagline = 'Your Service Partner';
  static const String appVersion = 'Version 1.0.0';
  
  // Common Buttons & Actions
  static const String next = 'Next';
  static const String back = 'Back';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String view = 'View';
  static const String viewAll = 'View All';
  static const String viewDetails = 'View Details';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  
  // Authentication - Common
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String changePassword = 'Change Password';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password';
  static const String firstName = 'First Name';
  static const String lastName = 'Last Name';
  static const String phoneNumber = 'Phone Number';
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = 'Don\'t have an account?';
  
  // Authentication - Providers
  static const String providerWelcomeTitle = 'Service Provider Portal';
  static const String providerWelcomeSubtitle = 'Provide your services and earn with Handy Buddy';
  static const String providerLoginTitle = 'Service Provider Login';
  static const String providerLoginSubtitle = 'Login to continue providing your services';
  static const String providerSignupTitle = 'Service Provider Sign Up';
  static const String providerSignupSubtitle = 'Join us as a service provider';
  static const String providerProfileSetup = 'Complete Your Profile';
  static const String providerProfileSetupSubtitle = 'Set up your service provider profile';
  static const String selectServiceCategory = 'Select Service Category';
  static const String uploadIC = 'Upload IC';
  static const String uploadResume = 'Upload Resume';
  static const String clickToUploadIC = 'Click to upload IC';
  static const String clickToUploadResume = 'Click to upload Resume';
  static const String providerSignupSuccess = 'Congratulations!';
  static const String providerSignupSuccessMessage = 'You are now a service provider. You can start managing your services and accepting bookings.';
  
  // Authentication - Seekers
  static const String seekerLoginTitle = 'Welcome Back!';
  static const String seekerLoginSubtitle = 'Login to continue finding services';
  static const String seekerSignupTitle = 'Join Handy Buddy';
  static const String seekerSignupSubtitle = 'Create an account to find and book services easily';
  static const String personalInformation = 'Personal Information';
  static const String accountInformation = 'Account Information';
  static const String termsAndConditionsAgree = 'I agree to the Terms and Conditions and Privacy Policy';
  static const String becomeProvider = 'Want to offer your services?';
  static const String becomeProviderSubtitle = 'Join as a service provider and start earning';
  static const String becomeProviderButton = 'Become a Service Provider';
  
  // Profile - Common
  static const String myProfile = 'My Profile';
  static const String editProfile = 'Edit Profile';
  static const String editProfileName = 'Edit Profile Name';
  static const String profileUpdated = 'Profile Updated';
  static const String profileUpdatedMessage = 'Your profile has been updated successfully.';
  static const String accountSettings = 'Account Settings';
  static const String notification = 'Notifications';
  static const String language = 'Language';
  static const String contactUs = 'Contact Us';
  static const String aboutUs = 'About Us';
  static const String settings = 'Settings';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirm = 'Are you sure you want to delete your account? This action cannot be undone.';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  
  // Provider Dashboard
  static const String welcomeProvider = 'Welcome, ';
  static const String pendingBookings = 'Pending Bookings';
  static const String todaySchedule = 'Today\'s Schedule';
  static const String quickStats = 'Quick Stats';
  static const String thisWeek = 'This Week';
  static const String thisMonth = 'This Month';
  static const String earnings = 'Earnings';
  static const String totalEarnings = 'Total Earnings';
  static const String manageServices = 'Manage Services';
  static const String addService = 'Add Service';
  static const String editService = 'Edit Service';
  static const String deleteServiceConfirm = 'Are you sure you want to delete this service?';
  
  // Provider Bookings
  static const String myBookings = 'My Bookings';
  static const String upcomingBookings = 'Upcoming';
  static const String completedBookings = 'Completed';
  static const String cancelledBookings = 'Cancelled';
  static const String noBookingsFound = 'No bookings found';
  static const String completeBooking = 'Complete';
  static const String cancelBooking = 'Cancel';
  static const String cancelBookingConfirm = 'Are you sure you want to cancel this booking?';
  static const String completeBookingConfirm = 'Are you sure you want to mark this booking as completed?';
  
  // Provider Earnings
  static const String myEarnings = 'My Earnings';
  static const String selectPeriod = 'Select Period';
  static const String today = 'Today';
  static const String jobs = 'Jobs';
  static const String averageRate = 'Avg. Rate';
  static const String rating = 'Rating';
  static const String recentPayments = 'Recent Payments';
  static const String viewFullPaymentHistory = 'View Full Payment History';
  
  // Seeker Home
  static const String searchForServices = 'Search for services';
  static const String serviceCategories = 'Service Categories';
  static const String featuredProviders = 'Featured Providers';
  static const String emergencyServices = 'Emergency Services';
  static const String emergencyServicesSubtitle = 'Get immediate assistance for urgent issues';
  static const String requestNow = 'Request Now';
  
  // Seeker Service Categories (names of services)
  static const String homeRepairs = 'Home Repairs';
  static const String cleaningService = 'Cleaning Service';
  static const String tutoring = 'Tutoring';
  static const String plumbingServices = 'Plumbing Services';
  static const String transportHelper = 'Transport Helper';
  static const String electricalServices = 'Electrical Services';
  static const String emergencyRequest = 'Emergency Request';
  
  // Booking Process
  static const String bookService = 'Book a Service';
  static const String bookNow = 'Book Now';
  static const String selectDateAndTime = 'Select Date and Time';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String serviceLocation = 'Service Location';
  static const String address = 'Address';
  static const String additionalNotes = 'Additional Notes (Optional)';
  static const String proceedToConfirm = 'Proceed to Confirm';
  static const String confirmBooking = 'Confirm Booking';
  static const String bookingSummary = 'Booking Summary';
  static const String paymentDetails = 'Payment Details';
  static const String serviceFee = 'Service Fee';
  static const String platformFee = 'Platform Fee';
  static const String total = 'Total';
  static const String paymentMethod = 'Payment Method';
  static const String confirmAndPay = 'Confirm and Pay';
  static const String bookingSuccessful = 'Booking Successful!';
  static const String bookingSuccessfulMessage = 'Your booking has been confirmed. The service provider will contact you soon.';
  
  // Payment
  static const String payment = 'Payment';
  static const String paymentSuccessful = 'Payment Successful!';
  static const String paymentSuccessfulMessage = 'Your payment has been processed successfully. The service provider will be notified about your booking.';
  static const String eWallet = 'E-wallet';
  static const String eWalletSubtitle = 'Touch n Go, Grab Pay, Boost, etc.';
  static const String onlineBanking = 'Online Banking (FPX)';
  static const String onlineBankingSubtitle = 'Direct bank transfer';
  static const String selectEWallet = 'Select your E-wallet';
  static const String selectBank = 'Select your bank';
  static const String completePayment = 'Complete Payment';
  
  // Rating and Reviews
  static const String rateService = 'Rate Service';
  static const String rateExperience = 'How would you rate your experience?';
  static const String additionalComments = 'Additional Comments (Optional)';
  static const String submitRating = 'Submit Rating';
  static const String thankYou = 'Thank You!';
  static const String ratingSubmitted = 'Your rating has been submitted successfully.';
  static const String tapToRate = 'Tap to rate';
  static const String poor = 'Poor';
  static const String fair = 'Fair';
  static const String good = 'Good';
  static const String veryGood = 'Very Good';
  static const String excellent = 'Excellent';
  
  // Rebooking
  static const String rebookService = 'Rebook Service';
  static const String previousBooking = 'Previous Booking';
  static const String selectNewDateAndTime = 'Select New Date and Time';
  static const String rebookingNote = 'Rebooking is subject to provider availability. You will receive a confirmation once the provider accepts your request.';
  static const String confirmRebooking = 'Confirm Rebooking';
  static const String rebookingSuccessful = 'Rebooking Successful!';
  static const String rebookingSuccessfulMessage = 'Your service has been rebooked successfully.';
  
  // Chat
  static const String typeMessage = 'Type a message...';
  
  // Status Labels
  static const String statusPending = 'PENDING';
  static const String statusCompleted = 'COMPLETED';
  static const String statusCancelled = 'CANCELLED';
  
  // About Us
  static const String aboutUsTitle = 'About Us';
  static const String ourMission = 'Our Mission';
  static const String ourMissionText = 'At Handy Buddy, our mission is to connect service providers with service seekers in a seamless and efficient manner. We aim to create a platform that makes finding and booking services easy, reliable, and affordable for everyone.';
  static const String whoWeAre = 'Who We Are';
  static const String whoWeAreText = 'Handy Buddy is a Malaysian-based service platform founded in 2025. We started with a simple idea: to make home services accessible to everyone. Today, we\'ve grown into a comprehensive platform offering a wide range of services from home repairs to tutoring.';
  static const String howItWorks = 'How It Works';
  static const String howItWorksText = 'Our platform connects skilled service providers with customers looking for quality services. Service providers can list their services, set their availability, and manage bookings through our app. Service seekers can browse available services, book appointments, and pay securely all in one place.';
  static const String ourValues = 'Our Values';
  static const String ourValuesText = 'Quality: We prioritize quality service delivery.\nTrust: We build trust through transparency and reliability.\nAccessibility: We make services accessible to everyone.\nCommunity: We foster a supportive community of providers and users.';
  
  // Contact Us
  static const String contactUsTitle = 'Contact Us';
  static const String getInTouch = 'Get in touch with us';
  static const String contactUsSubtitle = 'We\'d love to hear from you. Please fill out the form below and we\'ll get back to you as soon as possible.';
  static const String yourName = 'Your Name';
  static const String yourEmail = 'Your Email';
  static const String message = 'Message';
  static const String sendMessage = 'Send Message';
  static const String messageSent = 'Your message has been sent. We\'ll get back to you soon!';
  static const String contactInformation = 'Contact Information';
  
  // Language Settings
  static const String languageSettings = 'Language Settings';
  static const String selectLanguage = 'Select your preferred language';
  static const String languageSettingsSubtitle = 'The app will use this language for all screens and notifications';
  static const String english = 'English';
  static const String malay = 'Malay';
  static const String chinese = 'Chinese';
  static const String tamil = 'Tamil';
  
  // Form Validations
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 6 characters long';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String acceptTerms = 'Please accept the terms and conditions';
  
  // Gender
  static const String male = 'Male';
  static const String female = 'Female';
  static const String other = 'Other';
  static const String preferNotToSay = 'Prefer not to say';
  
  // Splash Screen
  static const String loading = 'Loading...';
  
  // Error Messages
  static const String errorOccurred = 'An error occurred';
  static const String tryAgain = 'Please try again';
  static const String noInternet = 'No internet connection';
  static const String checkConnection = 'Please check your internet connection and try again';
  static const String sessionExpired = 'Your session has expired';
  static const String pleaseLogin = 'Please login again to continue';
  
  // Empty States
  static const String noDataFound = 'No data found';
  static const String noResultsFound = 'No results found';
  static const String emptyBookings = 'You don\'t have any bookings yet';
  static const String emptyServices = 'No services available at the moment';
  static const String emptyCategories = 'No categories available';
  static const String emptyChat = 'Start a conversation with your service provider';
}