import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/data/models/organization/organization.dart';
import 'package:donation_platform/data/models/common/category.dart';
import 'package:donation_platform/data/models/organization/organization_verification.dart';
import 'package:donation_platform/core/utils/exceptions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:donation_platform/config/constants.dart';

class OrganizationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<Organization?> getOrganizationById(String organizationId) async {
    try {
      // Validate input
      if (organizationId.isEmpty) {
        throw DatabaseException('Organization ID cannot be empty');
      }

      // Check authentication status
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw DatabaseException('User is not authenticated');
      }

      // Query the organization
      final response = await _supabase
          .from('organization_profiles')
          .select('''
          *,
          users:user_id (*),
          organization_categories(
            categories:category_id (*)
          )
        ''')
          .eq('user_id', organizationId)
          .maybeSingle(); // Use maybeSingle instead of single to avoid errors when no record is found

      // Handle case where no organization is found
      if (response == null) {
        print('No organization found with ID: $organizationId');
        return null;
      }

      // Verify the response contains expected data
      if (response['organization_categories'] == null) {
        throw DatabaseException(
            'Organization categories data is missing or malformed');
      }

      // Transform to match our model's expected format
      try {
        final transformedResponse = {
          ...response,
          'categories': response['organization_categories']
              .map((oc) => oc['categories'])
              .toList(),
        };

        return Organization.fromJson(
            Map<String, dynamic>.from(transformedResponse));
      } catch (transformError) {
        throw DatabaseException(
            'Failed to transform organization data: $transformError');
      }
    } catch (e) {
      // Provide more context in error message
      if (e is PostgrestException) {
        print(
            'Supabase error fetching organization $organizationId: Code ${e.code}, Message: ${e.message}');
        throw DatabaseException('Database error: ${e.message}');
      } else if (e is DatabaseException) {
        print('Database exception for organization $organizationId: $e');
        rethrow; // Rethrow the already formatted error
      } else {
        print('Unexpected error fetching organization $organizationId: $e');
        throw DatabaseException('Failed to get organization: $e');
      }
    }
  }

  // Get nearby organizations based on user location
  Future<List<Organization>> getNearbyOrganizations({
    double? latitude,
    double? longitude,
    int radiusKm = AppConstants.defaultSearchRadiusKm,
  }) async {
    try {
      // If location not provided, try to get current location
      if (latitude == null || longitude == null) {
        try {
          final position = await _getCurrentLocation();
          latitude = position.latitude;
          longitude = position.longitude;
        } catch (e) {
          // Use default coordinates if location not available
          latitude = AppConstants.defaultLatitude;
          longitude = AppConstants.defaultLongitude;
        }
      }

      // Use Supabase stored procedure to find nearby organizations
      final response =
          await _supabase.rpc('find_nearby_organizations', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
        'verification_status': 'approved',
      });

      // Fetch complete organization details for each nearby organization
      final List<Organization> organizations = [];
      for (final item in response) {
        final org = await getOrganizationById(item['organization_id']);
        if (org != null) {
          organizations.add(org);
        }
      }

      return organizations;
    } catch (e) {
      throw DatabaseException('Failed to get nearby organizations: $e');
    }
  }

  // Get featured organizations
  Future<List<Organization>> getFeaturedOrganizations() async {
    try {
      final response = await _supabase
          .from('organization_profiles')
          .select('''
            *,
            users:user_id (*),
            organization_categories!inner(
              categories:category_id (*)
            )
          ''')
          .eq('featured', true)
          .eq('verification_status', 'approved')
          .order('created_at', ascending: false);

      return response.map<Organization>((data) {
        // Transform to match our model's expected format
        final transformedData = {
          ...data,
          'categories': data['organization_categories']
              .map((oc) => oc['categories'])
              .toList(),
        };

        return Organization.fromJson(
            Map<String, dynamic>.from(transformedData));
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get featured organizations: $e');
    }
  }

  // Get organizations by category
  Future<List<Organization>> getOrganizationsByCategory(
      String categoryId) async {
    try {
      final response = await _supabase
          .from('organization_categories')
          .select('''
            organization_profiles!inner(
              *,
              users:user_id (*),
              organization_categories!inner(
                categories:category_id (*)
              )
            )
          ''')
          .eq('category_id', categoryId)
          .eq('organization_profiles.verification_status', 'approved');

      return response.map<Organization>((data) {
        final orgData = data['organization_profiles'];

        // Transform to match our model's expected format
        final transformedData = {
          ...orgData,
          'categories': orgData['organization_categories']
              .map((oc) => oc['categories'])
              .toList(),
        };

        return Organization.fromJson(
            Map<String, dynamic>.from(transformedData));
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to get organizations by category: $e');
    }
  }

  // Search organizations
  Future<List<Organization>> searchOrganizations(String query) async {
    try {
      final response = await _supabase
          .from('organization_profiles')
          .select('''
            *,
            users:user_id (*),
            organization_categories!inner(
              categories:category_id (*)
            )
          ''')
          .or('organization_name.ilike.%$query%,description.ilike.%$query%')
          .eq('verification_status', 'approved')
          .order('created_at', ascending: false);

      return response.map<Organization>((data) {
        // Transform to match our model's expected format
        final transformedData = {
          ...data,
          'categories': data['organization_categories']
              .map((oc) => oc['categories'])
              .toList(),
        };

        return Organization.fromJson(
            Map<String, dynamic>.from(transformedData));
      }).toList();
    } catch (e) {
      throw DatabaseException('Failed to search organizations: $e');
    }
  }

  // Submit organization verification
  Future<void> submitVerification(Map<String, dynamic> verificationData) async {
    try {
      final organizationId = verificationData['organization_id'];

      // Check if organization already has verification record
      final existingVerification = await _supabase
          .from('organization_verifications')
          .select()
          .eq('organization_id', organizationId)
          .maybeSingle();

      if (existingVerification != null) {
        // Update existing verification
        await _supabase
            .from('organization_verifications')
            .update(verificationData)
            .eq('id', existingVerification['id']);
      } else {
        // Create new verification
        await _supabase
            .from('organization_verifications')
            .insert(verificationData);
      }

      // Update organization profile verification status
      await _supabase.from('organization_profiles').update({
        'verification_status': 'in_review',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', organizationId);
    } catch (e) {
      throw DatabaseException('Failed to submit verification: $e');
    }
  }

  // Get organization verification status
  Future<OrganizationVerification?> getVerificationStatus(
      String organizationId) async {
    try {
      final response = await _supabase
          .from('organization_verifications')
          .select()
          .eq('organization_id', organizationId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return OrganizationVerification.fromJson(response);
    } catch (e) {
      throw DatabaseException('Failed to get verification status: $e');
    }
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return response.map<Category>((data) => Category.fromJson(data)).toList();
    } catch (e) {
      throw DatabaseException('Failed to get categories: $e');
    }
  }

  // Helper method to get current location
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException('Location permissions are permanently denied.');
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }
}
