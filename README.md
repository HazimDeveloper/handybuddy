# handy_buddy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

handy_buddy_app/
├── android/                       # Android-specific files
├── ios/                           # iOS-specific files
├── lib/
│   ├── constants/
│   │   ├── app_colors.dart        # Color scheme definitions
│   │   ├── app_styles.dart        # Text and component styles
│   │   └── app_texts.dart         # Text constants and strings
│   │
│   ├── firebase/
│   │   ├── auth_methods.dart      # Firebase authentication methods
│   │   ├── firestore_methods.dart # Firestore database methods
│   │   └── storage_methods.dart   # Firebase storage methods
│   │
│   ├── models/
│   │   ├── booking_model.dart     # Booking data model
│   │   ├── service_model.dart     # Service data model
│   │   └── user_model.dart        # User data model
│   │
│   ├── providers/
│   │   ├── auth_provider.dart     # Authentication state management
│   │   ├── booking_provider.dart  # Booking state management
│   │   └── service_provider.dart  # Service state management
│   │
│   ├── screens/
│   │   ├── common/
│   │   │   ├── about_us_screen.dart           # About us screen
│   │   │   ├── contact_us_screen.dart         # Contact us screen
│   │   │   ├── language_settings_screen.dart  # Language settings
│   │   │   └── settings_screen.dart           # General settings
│   │   │
│   │   ├── provider/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart          # Provider login
│   │   │   │   ├── signup_screen.dart         # Provider signup
│   │   │   │   └── welcome_screen.dart        # Provider welcome
│   │   │   │
│   │   │   ├── bookings/
│   │   │   │   ├── bookings_screen.dart       # Provider bookings list
│   │   │   │   └── booking_detail_screen.dart # Booking details
│   │   │   │
│   │   │   ├── earnings/
│   │   │   │   └── earnings_screen.dart       # Provider earnings
│   │   │   │
│   │   │   ├── home/
│   │   │   │   ├── provider_home_screen.dart  # Provider dashboard
│   │   │   │   └── manage_service_screen.dart # Service management
│   │   │   │
│   │   │   ├── profile/
│   │   │   │   ├── provider_profile_screen.dart  # Provider profile
│   │   │   │   ├── edit_profile_screen.dart      # Edit profile
│   │   │   │   ├── edit_profile_name_screen.dart # Edit name
│   │   │   │   └── change_password_screen.dart   # Change password
│   │   │   │
│   │   │   └── provider_main_screen.dart      # Provider main (tabs)
│   │   │
│   │   ├── seeker/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart          # Seeker login
│   │   │   │   └── signup_screen.dart         # Seeker signup
│   │   │   │
│   │   │   ├── bookings/
│   │   │   │   ├── seeker_bookings_screen.dart   # Seeker bookings list
│   │   │   │   └── booking_detail_screen.dart    # Booking details
│   │   │   │
│   │   │   ├── booking/
│   │   │   │   ├── booking_screen.dart           # Create booking
│   │   │   │   ├── booking_confirmation_screen.dart # Confirm booking
│   │   │   │   ├── payment_screen.dart           # Payment screen
│   │   │   │   └── rebook_screen.dart            # Rebook service
│   │   │   │
│   │   │   ├── chat/
│   │   │   │   └── chat_screen.dart              # Chat with provider
│   │   │   │
│   │   │   ├── home/
│   │   │   │   └── seeker_home_screen.dart       # Seeker home screen
│   │   │   │
│   │   │   ├── profile/
│   │   │   │   ├── seeker_profile_screen.dart    # Seeker profile
│   │   │   │   └── edit_profile_screen.dart      # Edit profile
│   │   │   │
│   │   │   ├── rate/
│   │   │   │   └── rate_screen.dart              # Rate service
│   │   │   │
│   │   │   ├── services/
│   │   │   │   ├── service_category_screen.dart  # Service category
│   │   │   │   └── service_detail_screen.dart    # Service details
│   │   │   │
│   │   │   └── seeker_main_screen.dart           # Seeker main (tabs)
│   │   │
│   │   └── splash_screen.dart                # App splash screen
│   │
│   ├── utils/
│   │   ├── dialog_utils.dart      # Dialog and modal utilities
│   │   ├── form_validators.dart   # Form validation functions
│   │   └── toast_utils.dart       # Toast message utilities
│   │
│   ├── widgets/
│   │   ├── buttons/
│   │   │   ├── custom_button.dart         # Primary button component
│   │   │   └── outlined_button.dart       # Secondary button component
│   │   │
│   │   ├── cards/
│   │   │   ├── booking_card.dart          # Booking card component
│   │   │   ├── provider_card.dart         # Provider info card
│   │   │   └── service_card.dart          # Service info card
│   │   │
│   │   ├── dialogs/
│   │   │   ├── confirm_dialog.dart        # Confirmation dialog
│   │   │   └── success_dialog.dart        # Success message dialog
│   │   │
│   │   ├── inputs/
│   │   │   ├── text_input.dart            # Text input component
│   │   │   └── search_input.dart          # Search input component
│   │   │
│   │   └── other_widgets.dart             # Miscellaneous components
│   │
│   ├── routes.dart                # App route definitions
│   ├── firebase_options.dart      # Firebase configuration
│   └── main.dart                  # Main app entry point
│
├── assets/
│   ├── images/                    # App images and graphics
│   │   └── logo.png               # App logo
│   │
│   ├── icons/                     # Custom icons
│   └── fonts/                     # Custom fonts
│
├── pubspec.yaml                   # Project dependencies
└── README.md                      # Project documentation
