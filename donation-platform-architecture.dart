// DONATION PLATFORM APP ARCHITECTURE
// This comprehensive architecture outlines the structure of a Flutter donation platform
// with three interfaces: Donor, Organization, and Admin

// =======================================================
// 1. PROJECT STRUCTURE
// =======================================================

/*
lib/
├── main.dart                    # App entry point
├── config/                      # App configuration
│   ├── router.dart              # App router using go_router/auto_route
│   ├── themes.dart              # App themes (light/dark)
│   ├── constants.dart           # App constants
│   └── app_config.dart          # Environment configuration
├── core/                        # Core functionality
│   ├── auth/                    # Authentication services
│   │   ├── auth_service.dart    # Authentication logic
│   │   ├── auth_provider.dart   # Authentication state provider
│   │   ├── otp_service.dart     # OTP verification
│   │   └── user_session.dart    # User session management
│   ├── services/                # App services
│   │   ├── api_service.dart     # API communication
│   │   ├── location_service.dart      # Location services
│   │   ├── notification_service.dart  # Notifications
│   │   ├── storage_service.dart       # Local storage
│   │   ├── analytics_service.dart     # Analytics tracking
│   │   ├── cnic_verification_service.dart  # CNIC verification
│   │   └── payment_service.dart       # Payment processing
│   └── utils/                   # Utilities
│       ├── validators.dart      # Input validators
│       ├── formatters.dart      # Data formatters
│       ├── extensions/          # Extension methods
│       ├── helpers.dart         # Helper functions
│       └── connectivity_utils.dart  # Network connectivity helpers
├── data/                        # Data layer
│   ├── models/                  # Data models
│   │   ├── user/                # User-related models
│   │   │   ├── user.dart        # User model
│   │   │   ├── donor_profile.dart  # Donor profile
│   │   │   ├── user_verification.dart  # User verification
│   │   │   └── user_report.dart  # User reporting
│   │   ├── organization/        # Organization-related models
│   │   │   ├── organization.dart  # Organization model
│   │   │   ├── organization_verification.dart  # Verification
│   │   │   ├── organization_review.dart  # Reviews
│   │   │   └── board_member.dart  # Board members
│   │   ├── donation/            # Donation-related models
│   │   │   ├── donation.dart    # Donation model
│   │   │   ├── donation_category.dart  # Donation categories
│   │   │   ├── donation_tracking.dart  # Tracking info
│   │   │   ├── donation_update.dart  # Updates
│   │   │   └── recurring_donation.dart  # Recurring donations
│   │   ├── payment/             # Payment-related models
│   │   │   ├── payment_transaction.dart  # Payment transaction
│   │   │   ├── payment_method.dart  # Payment methods
│   │   │   └── bank_details.dart  # Bank account details
│   │   └── common/              # Common models
│   │       ├── geo_point.dart   # Geolocation
│   │       ├── notification.dart  # Notifications
│   │       ├── campaign.dart    # Campaign model
│   │       └── category.dart    # Organization categories
│   ├── repositories/            # Data repositories
│   │   ├── user_repository.dart
│   │   ├── donor_repository.dart
│   │   ├── organization_repository.dart
│   │   ├── donation_repository.dart
│   │   ├── campaign_repository.dart
│   │   ├── payment_repository.dart
│   │   ├── report_repository.dart
│   │   └── admin_repository.dart
│   └── datasources/             # Data sources
│       ├── remote/              # Remote data sources
│       │   ├── api_client.dart  # API client (Dio/http)
│       │   ├── user_remote_datasource.dart
│       │   ├── organization_remote_datasource.dart
│       │   ├── donation_remote_datasource.dart
│       │   └── payment_remote_datasource.dart
│       └── local/               # Local data sources
│           ├── secure_storage.dart  # Secure storage
│           ├── shared_prefs.dart  # Shared preferences
│           ├── hive_storage.dart  # Hive database
│           └── cache_manager.dart  # Caching data
├── ui/                          # UI layer
│   ├── common/                  # Common UI components
│   │   ├── widgets/             # Reusable widgets
│   │   │   ├── buttons/         # Button components
│   │   │   ├── inputs/          # Input fields
│   │   │   ├── cards/           # Card components
│   │   │   ├── dialogs/         # Dialogs and modals
│   │   │   ├── loading_indicators.dart  # Loading states
│   │   │   └── error_displays.dart  # Error states
│   │   └── screens/             # Common screens
│   │       ├── splash_screen.dart
│   │       ├── onboarding_screen.dart
│   │       └── error_screen.dart
│   ├── auth/                    # Authentication UI
│   │   ├── screens/             # Auth screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── verification_screen.dart
│   │   │   └── password_reset_screen.dart
│   │   └── widgets/             # Auth-specific widgets
│   ├── donor/                   # Donor interface
│   │   ├── screens/             # Donor screens
│   │   │   ├── donor_home_screen.dart
│   │   │   ├── discover_organizations_screen.dart
│   │   │   ├── organization_detail_screen.dart
│   │   │   ├── donation_form_screen.dart
│   │   │   ├── donation_history_screen.dart
│   │   │   ├── donation_detail_screen.dart
│   │   │   ├── impact_visualization_screen.dart
│   │   │   └── donor_profile_screen.dart
│   │   └── widgets/             # Donor-specific widgets
│   │       ├── organization_card.dart
│   │       ├── donation_list_item.dart
│   │       ├── impact_summary_card.dart
│   │       └── nearby_organization_map.dart
│   ├── organization/            # Organization interface
│   │   ├── screens/             # Organization screens
│   │   │   ├── organization_dashboard_screen.dart
│   │   │   ├── verification_form_screen.dart
│   │   │   ├── pending_donations_screen.dart
│   │   │   ├── completed_donations_screen.dart
│   │   │   ├── donation_detail_screen.dart
│   │   │   ├── donation_update_form.dart
│   │   │   ├── organization_profile_screen.dart
│   │   │   └── analytics_screen.dart
│   │   └── widgets/             # Organization-specific widgets
│   │       ├── donation_stats_card.dart
│   │       ├── verification_status_card.dart
│   │       └── donor_demographics_chart.dart
│   └── admin/                   # Admin interface
│       ├── screens/             # Admin screens
│       │   ├── admin_dashboard_screen.dart
│       │   ├── organization_list_screen.dart
│       │   ├── organization_verification_screen.dart
│       │   ├── user_management_screen.dart
│       │   ├── blacklist_management_screen.dart
│       │   ├── reports_management_screen.dart
│       │   └── system_settings_screen.dart
│       └── widgets/             # Admin-specific widgets
│           ├── pending_verifications_card.dart
│           ├── user_reports_card.dart
│           ├── platform_stats_card.dart
│           └── blacklisted_users_table.dart
└── providers/                   # State management (Riverpod/Provider)
    ├── auth_providers.dart      # Authentication state
    ├── user_providers.dart      # User state
    ├── donor_providers.dart     # Donor state
    ├── organization_providers.dart  # Organization state
    ├── donation_providers.dart  # Donation state
    ├── campaign_providers.dart  # Campaign state
    ├── notification_providers.dart  # Notification state
    └── admin_providers.dart     # Admin state

*/

// =======================================================
// 2. CORE MODELS
// =======================================================

// User Model - Base class for all users
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;
  final String userType; // "donor", "organization", "admin"
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // User verification details
  final UserVerification verification;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
    required this.userType,
    required this.createdAt,
    required this.updatedAt,
    required this.verification,
  });
}

// User Verification Model
class UserVerification {
  final String userId;
  final String cnic; // National ID number
  final bool cnicVerified;
  final bool phoneVerified;
  final DateTime verifiedAt;
  
  UserVerification({
    required this.userId,
    required this.cnic,
    required this.cnicVerified,
    required this.phoneVerified,
    required this.verifiedAt,
  });
}

// Organization Model
class Organization {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String description;
  final String address;
  final GeoPoint location;
  final List<String> categories;
  final String status; // "pending", "approved", "rejected"
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Organization verification details
  final OrganizationVerification verification;
  
  Organization({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.address,
    required this.location,
    required this.categories,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.verification,
  });
}

// Organization Verification Model (Comprehensive fields for authenticity)
class OrganizationVerification {
  final String organizationId;
  final String registrationNumber; // Official registration number
  final String taxId; // Tax identification number
  final String registrationCertificate; // Document URL
  final String taxCertificate; // Document URL
  final String bankStatement; // Document URL
  final String boardResolution; // Document URL
  final List<String> boardMembers; // List of board members with positions
  final String website;
  final Map<String, String> socialMediaProfiles; // Platform -> URL
  final List<String> referenceLetters; // Document URLs
  final bool physicalAddressVerified;
  final bool bankAccountVerified;
  final String verificationNotes;
  final String verifiedBy; // Admin ID
  final DateTime verifiedAt;
  
  OrganizationVerification({
    required this.organizationId,
    required this.registrationNumber,
    required this.taxId,
    required this.registrationCertificate,
    required this.taxCertificate,
    required this.bankStatement,
    required this.boardResolution,
    required this.boardMembers,
    required this.website,
    required this.socialMediaProfiles,
    required this.referenceLetters,
    required this.physicalAddressVerified,
    required this.bankAccountVerified,
    required this.verificationNotes,
    required this.verifiedBy,
    required this.verifiedAt,
  });
}

// Donation Model
class Donation {
  final String id;
  final String donorId;
  final String organizationId;
  final double amount;
  final String currency;
  final String status; // "pending", "completed", "failed", "rejected"
  final String paymentMethod;
  final String transactionId;
  final String description;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Feedback and tracking
  final DonationTracking tracking;
  
  Donation({
    required this.id,
    required this.donorId,
    required this.organizationId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.description,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.tracking,
  });
}

// Donation Tracking Model
class DonationTracking {
  final String donationId;
  final String status; // "received", "processing", "utilized", "completed"
  final String feedback;
  final List<DonationUpdate> updates;
  
  DonationTracking({
    required this.donationId,
    required this.status,
    required this.feedback,
    required this.updates,
  });
}

// Donation Update Model
class DonationUpdate {
  final String id;
  final String donationId;
  final String title;
  final String description;
  final List<String> mediaUrls; // Images or videos showing impact
  final DateTime createdAt;
  
  DonationUpdate({
    required this.id,
    required this.donationId,
    required this.title,
    required this.description,
    required this.mediaUrls,
    required this.createdAt,
  });
}

// GeoPoint for location
class GeoPoint {
  final double latitude;
  final double longitude;
  
  GeoPoint({
    required this.latitude,
    required this.longitude,
  });
}

// =======================================================
// 3. AUTHENTICATION AND VERIFICATION SERVICES
// =======================================================

abstract class AuthService {
  Future<User> registerUser(String email, String password, String userType);
  Future<User> loginUser(String email, String password);
  Future<void> logoutUser();
  Future<User> getCurrentUser();
  Future<bool> resetPassword(String email);
}

abstract class VerificationService {
  // Phone verification with OTP
  Future<bool> sendPhoneVerificationOTP(String phone);
  Future<bool> verifyPhoneOTP(String phone, String otp);
  
  // CNIC (National ID) verification
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth);
  
  // Organization verification
  Future<bool> submitOrganizationVerification(OrganizationVerification verification);
  Future<OrganizationVerification> getOrganizationVerificationStatus(String organizationId);
}

// =======================================================
// 4. KEY SCREENS FOR EACH INTERFACE
// =======================================================

// DONOR INTERFACE SCREENS
/*
1. Authentication
   - Login Screen
   - Registration Screen
   - Verification Screen (CNIC and Phone OTP)

2. Home & Discovery
   - Dashboard Screen (summary of donations, impact)
   - Organization Discovery Screen (with filters)
   - Organization Detail Screen
   - Map View (nearby organizations)

3. Donation Process
   - Donation Form Screen
   - Payment Method Selection
   - Donation Confirmation
   - Receipt Screen

4. Tracking & History
   - Donation History Screen
   - Donation Detail Screen (with updates from organization)
   - Impact Visualization Screen
   
5. Profile & Settings
   - Profile Screen
   - Preferences Screen
   - Notification Settings
*/

// ORGANIZATION INTERFACE SCREENS
/*
1. Authentication
   - Login Screen
   - Registration Screen
   - Verification Form Screen (comprehensive fields)

2. Dashboard
   - Overview Screen (summary of donations, statistics)
   - Pending Donations Screen
   - Completed Donations Screen
   
3. Donation Management
   - Donation Detail Screen
   - Donation Update Form (provide feedback and updates)
   - Donor Communication Screen
   
4. Profile & Settings
   - Organization Profile Screen
   - Organization Settings
   - Notification Settings
   
5. Analytics
   - Donation Analytics Screen
   - Donor Demographics Screen
   - Impact Report Generation
*/

// ADMIN INTERFACE SCREENS
/*
1. Authentication
   - Login Screen
   - Admin Dashboard

2. Organization Management
   - Organization List Screen (with filters)
   - Organization Verification Screen
   - Organization Detail Screen
   
3. User Management
   - User List Screen
   - User Detail Screen
   - User Verification Screen
   
4. Reporting & Analytics
   - Platform Statistics Dashboard
   - Fraud Detection Screen
   - System Logs Screen
   
5. Settings & Configuration
   - System Settings
   - Notification Templates
   - Platform Configuration
*/

// =======================================================
// 5. IMPLEMENTATION OF VERIFICATION MECHANISMS
// =======================================================

// CNIC Verification Service Implementation
class CNICVerificationService {
  Future<bool> verifyCNIC(String cnic, String name, String dateOfBirth) async {
    // 1. Format validation
    if (!isValidCNICFormat(cnic)) {
      return false;
    }
    
    // 2. Call to NADRA API or similar national ID verification service
    // This is a placeholder for the actual API integration
    try {
      final response = await apiService.post('/verify/cnic', {
        'cnic': cnic,
        'name': name,
        'dob': dateOfBirth,
      });
      
      return response['verified'] == true;
    } catch (e) {
      logError('CNIC verification failed', e);
      return false;
    }
  }
  
  bool isValidCNICFormat(String cnic) {
    // Pakistani CNIC format: 12345-1234567-1
    final RegExp cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return cnicRegex.hasMatch(cnic);
  }
}

// Phone OTP Verification Service
class PhoneOTPService {
  // Generate and send OTP
  Future<bool> sendOTP(String phone) async {
    try {
      // Generate a random 6-digit OTP
      final String otp = generateRandomOTP();
      
      // Store the OTP with expiration time (e.g., 10 minutes)
      await storeOTP(phone, otp, Duration(minutes: 10));
      
      // Send the OTP via SMS gateway
      final bool sent = await sendSMS(phone, 'Your verification code is: $otp');
      
      return sent;
    } catch (e) {
      logError('Failed to send OTP', e);
      return false;
    }
  }
  
  // Verify submitted OTP
  Future<bool> verifyOTP(String phone, String submittedOTP) async {
    try {
      // Retrieve stored OTP and check if it's valid and not expired
      final StoredOTP storedOTP = await getStoredOTP(phone);
      
      if (storedOTP == null) {
        return false; // No OTP found
      }
      
      if (DateTime.now().isAfter(storedOTP.expiresAt)) {
        return false; // OTP expired
      }
      
      return storedOTP.otp == submittedOTP;
    } catch (e) {
      logError('OTP verification failed', e);
      return false;
    }
  }
  
  // Helper methods
  String generateRandomOTP() {
    // Generate a random 6-digit number
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }
  
  Future<void> storeOTP(String phone, String otp, Duration expiration) async {
    final expiresAt = DateTime.now().add(expiration);
    // Store in secure storage or database
    await secureStorage.write(
      key: 'otp_$phone',
      value: json.encode({
        'otp': otp,
        'expiresAt': expiresAt.toIso8601String(),
      }),
    );
  }
  
  Future<StoredOTP> getStoredOTP(String phone) async {
    final String storedData = await secureStorage.read(key: 'otp_$phone');
    if (storedData == null) return null;
    
    final data = json.decode(storedData);
    return StoredOTP(
      otp: data['otp'],
      expiresAt: DateTime.parse(data['expiresAt']),
    );
  }
  
  Future<bool> sendSMS(String phone, String message) async {
    // Integration with SMS gateway provider
    // This is a placeholder for the actual SMS gateway integration
    try {
      final response = await apiService.post('/sms/send', {
        'to': phone,
        'message': message,
      });
      
      return response['sent'] == true;
    } catch (e) {
      logError('SMS sending failed', e);
      return false;
    }
  }
}

class StoredOTP {
  final String otp;
  final DateTime expiresAt;
  
  StoredOTP({
    required this.otp,
    required this.expiresAt,
  });
}

// =======================================================
// 6. ORGANIZATION VERIFICATION REQUIREMENTS
// =======================================================

// Organization Verification Process:
// 1. Basic Registration
// 2. Document Submission
// 3. Background Check
// 4. Physical Address Verification
// 5. Bank Account Verification
// 6. Final Approval

class OrganizationVerificationProcess {
  // Submit verification request with all required documents
  Future<bool> submitVerificationRequest(
    String organizationId,
    OrganizationVerificationRequest request
  ) async {
    try {
      // Upload all documents to secure storage
      final Map<String, String> documentUrls = await uploadVerificationDocuments(
        organizationId,
        request.documents,
      );
      
      // Submit verification data to backend
      final response = await apiService.post('/organizations/verification/submit', {
        'organizationId': organizationId,
        'registrationNumber': request.registrationNumber,
        'taxId': request.taxId,
        'documentUrls': documentUrls,
        'contactPerson': request.contactPerson,
        'boardMembers': request.boardMembers,
        'website': request.website,
        'socialMediaProfiles': request.socialMediaProfiles,
        'bankDetails': request.bankDetails,
      });
      
      return response['submitted'] == true;
    } catch (e) {
      logError('Verification submission failed', e);
      return false;
    }
  }
  
  // Check verification status
  Future<VerificationStatus> checkVerificationStatus(String organizationId) async {
    try {
      final response = await apiService.get('/organizations/verification/status/$organizationId');
      
      return VerificationStatus(
        status: response['status'],
        stage: response['stage'],
        notes: response['notes'],
        updatedAt: DateTime.parse(response['updatedAt']),
      );
    } catch (e) {
      logError('Failed to check verification status', e);
      throw Exception('Unable to retrieve verification status');
    }
  }
}

class OrganizationVerificationRequest {
  final String registrationNumber;
  final String taxId;
  final Map<String, File> documents; // Document type -> File
  final ContactPerson contactPerson;
  final List<BoardMember> boardMembers;
  final String website;
  final Map<String, String> socialMediaProfiles;
  final BankDetails bankDetails;
  
  OrganizationVerificationRequest({
    required this.registrationNumber,
    required this.taxId,
    required this.documents,
    required this.contactPerson,
    required this.boardMembers,
    required this.website,
    required this.socialMediaProfiles,
    required this.bankDetails,
  });
}

class ContactPerson {
  final String name;
  final String position;
  final String email;
  final String phone;
  final String cnic;
  
  ContactPerson({
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.cnic,
  });
}

class BoardMember {
  final String name;
  final String position;
  final String cnic;
  
  BoardMember({
    required this.name,
    required this.position,
    required this.cnic,
  });
}

class BankDetails {
  final String accountTitle;
  final String accountNumber;
  final String bankName;
  final String branchCode;
  final String swiftCode;
  
  BankDetails({
    required this.accountTitle,
    required this.accountNumber,
    required this.bankName,
    required this.branchCode,
    required this.swiftCode,
  });
}

class VerificationStatus {
  final String status; // "pending", "in_progress", "approved", "rejected"
  final String stage; // Current verification stage
  final String notes; // Any notes from the admin
  final DateTime updatedAt;
  
  VerificationStatus({
    required this.status,
    required this.stage,
    required this.notes,
    required this.updatedAt,
  });
}

// =======================================================
// 7. EXAMPLE UI IMPLEMENTATION (DONOR INTERFACE)
// =======================================================

// Example of a Donor Home Screen
class DonorHomeScreen extends StatefulWidget {
  @override
  _DonorHomeScreenState createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  final DonorBloc _donorBloc = DonorBloc();
  
  @override
  void initState() {
    super.initState();
    _donorBloc.loadDashboardData();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donation Platform'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: StreamBuilder<DonorDashboardState>(
        stream: _donorBloc.dashboardState,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data!;
            
            if (state.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Impact summary
                    ImpactSummaryCard(
                      totalDonations: state.totalDonations,
                      organizationsSupported: state.organizationsSupported,
                      totalImpact: state.totalImpact,
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Recent donations
                    Text(
                      'Recent Donations',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.recentDonations.length,
                      itemBuilder: (context, index) {
                        final donation = state.recentDonations[index];
                        return DonationListItem(
                          donation: donation,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/donations/${donation.id}',
                          ),
                        );
                      },
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Nearby organizations
                    Text(
                      'Organizations Near You',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.nearbyOrganizations.length,
                        itemBuilder: (context, index) {
                          final organization = state.nearbyOrganizations[index];
                          return OrganizationCard(
                            organization: organization,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/organizations/${organization.id}',
                            ),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Discover more organizations
                    ElevatedButton(
                      child: Text('Discover More Organizations'),
                      onPressed: () => Navigator.pushNamed(context, '/discover'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Donations',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // Already on home
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/discover');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/donations');
              break;
          }
        },
      ),
    );
  }
}

// =======================================================
// 8. MAIN APP INITIALIZATION
// =======================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await initializeServices();
  
  runApp(DonationApp());
}

Future<void> initializeServices() async {
  // Initialize Firebase or other backend services
  await Firebase.initializeApp();
  
  // Initialize location services
  final locationService = LocationService();
  await locationService.initialize();
  
  // Initialize secure storage
  final secureStorage = SecureStorageService();
  await secureStorage.initialize();
  
  // Register all services in the service locator
  ServiceLocator.registerServices();
}

class DonationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donation Platform',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: NavigationService.navigatorKey,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: FirebaseAnalytics()),
      ],
    );
  }
}

// App router for navigation
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Parse route and parameters
    final uri = Uri.parse(settings.name!);
    final pathSegments = uri.pathSegments;
    
    // Get the current user type (if logged in)
    final userType = AuthService.getCurrentUserType();
    
    // Route to the appropriate screen based on user type and requested route
    switch (userType) {
      case 'donor':
        return _generateDonorRoutes(pathSegments, settings);
      case 'organization':
        return _generateOrganizationRoutes(pathSegments, settings);
      case 'admin':
        return _generateAdminRoutes(pathSegments, settings);
      default:
        return _generateAuthRoutes(pathSegments, settings);
    }
  }
  
  // Handle donor-specific routes
  static Route<dynamic> _generateDonorRoutes(List<String> pathSegments, RouteSettings settings) {
    // Implement donor routing logic
    switch (pathSegments.first) {
      case '':
        return MaterialPageRoute(builder: (_) => DonorHomeScreen());
      case 'discover':
        return MaterialPageRoute(builder: (_) => DiscoverOrganizationsScreen());
      // Add more donor routes
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
  
  // Handle organization-specific routes
  static Route<dynamic> _generateOrganizationRoutes(List<String> pathSegments, RouteSettings settings) {
    // Implement organization routing logic
    switch (pathSegments.first) {
      case '':
        return MaterialPageRoute(builder: (_) => OrganizationDashboardScreen());
      // Add more organization routes
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
  
  // Handle admin-specific routes
  static Route<dynamic> _generateAdminRoutes(List<String> pathSegments, RouteSettings settings) {
    // Implement admin routing logic
    switch (pathSegments.first) {
      case '':
        return MaterialPageRoute(builder: (_) => AdminDashboardScreen());
      // Add more admin routes
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
  
  // Handle authentication routes
  static Route<dynamic> _generateAuthRoutes(List<String> pathSegments, RouteSettings settings) {
    // Implement authentication routing logic
    switch (pathSegments.first) {
      case '':
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case 'login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case 'register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      // Add more auth routes
      default:
        return MaterialPageRoute(builder: (_) => NotFoundScreen());
    }
  }
}
