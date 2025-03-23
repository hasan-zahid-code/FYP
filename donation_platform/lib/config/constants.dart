class AppConstants {
  // API Endpoints
  static const String apiVersion = 'v1';
  static const String usersEndpoint = 'users';
  static const String donorsEndpoint = 'donors';
  static const String organizationsEndpoint = 'organizations';
  static const String donationsEndpoint = 'donations';
  static const String campaignsEndpoint = 'campaigns';
  static const String categoriesEndpoint = 'categories';
  static const String donationCategoriesEndpoint = 'donation_categories';
  static const String reportsEndpoint = 'reports';
  static const String notificationsEndpoint = 'notifications';

  // Authentication
  static const int otpExpiryMinutes = 5;
  static const int sessionExpiryDays = 30;
  static const int passwordMinLength = 8;

  // Location
  static const double defaultMapZoom = 14.0;
  static const int defaultSearchRadiusKm = 10;
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;

  // App Settings
  static const int minDonationAmount = 500;
  static const String defaultCurrency = 'PKR';
  static const List<String> supportedCurrencies = [
    'USD',
    'PKR',
    'EUR',
    'GBP',
    'AUD',
    'CAD'
  ];
  static const List<String> donationFrequencies = [
    'One time',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly'
  ];

  // Donation Types
  static const String donationTypeMoney = 'Money';
  static const String donationTypeFood = 'Food';
  static const String donationTypeClothes = 'Clothes';
  static const String donationTypeBooks = 'Books';
  static const String donationTypeMedical = 'Medical Supplies';
  static const String donationTypeHousehold = 'Household Items';
  static const String donationTypeOther = 'Other';

  // Organization Types
  static const List<String> organizationTypes = [
    'NGO',
    'Foundation',
    'Charity',
    'Non-profit',
    'Religious',
    'Community',
    'Educational',
    'Healthcare',
    'Animal Welfare',
    'Environmental',
    'Other'
  ];

  // Verification Stages
  static const String verificationStagePending = 'pending';
  static const String verificationStageDocuments = 'documents';
  static const String verificationStageContacts = 'contacts';
  static const String verificationStageBank = 'bank';
  static const String verificationStageReview = 'in_review';
  static const String verificationStageApproved = 'approved';
  static const String verificationStageRejected = 'rejected';

  // Report Types
  static const String reportTypeSpam = 'spam';
  static const String reportTypeFraud = 'fraud';
  static const String reportTypeInappropriate = 'inappropriate';
  static const String reportTypeOther = 'other';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double circularBorderRadius = 100.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 350);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String defaultProfileImage = 'assets/images/default_profile.png';
  static const String defaultOrgImage =
      'assets/images/default_organization.png';

  // Error Messages
  static const String defaultErrorMessage =
      'Something went wrong. Please try again later.';
  static const String connectionErrorMessage =
      'No internet connection. Please check your network.';
  static const String authFailedErrorMessage =
      'Authentication failed. Please check your credentials.';
  static const String verificationFailedErrorMessage =
      'Verification failed. Please try again.';
}
