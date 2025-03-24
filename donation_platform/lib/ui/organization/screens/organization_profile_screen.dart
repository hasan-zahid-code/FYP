import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/ui/common/widgets/buttons/primary_button.dart';
import 'package:donation_platform/ui/common/widgets/buttons/secondary_button.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:donation_platform/providers/organization_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:donation_platform/data/models/organization/organization.dart';
import 'package:donation_platform/ui/organization/widgets/verification_status_card.dart';

class OrganizationProfileScreen extends ConsumerStatefulWidget {
  const OrganizationProfileScreen({super.key});

  @override
  ConsumerState<OrganizationProfileScreen> createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState
    extends ConsumerState<OrganizationProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _missionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();

  File? _logoFile;
  File? _bannerFile;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _missionController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _initControllers(Organization organization) {
    _nameController.text = organization.organizationName;
    _descriptionController.text = organization.description ?? '';
    _missionController.text = organization.missionStatement ?? '';
    _websiteController.text = organization.websiteUrl ?? '';
    _addressController.text = organization.address;
    _cityController.text = organization.city;
    _stateController.text = organization.state;
    _countryController.text = organization.country;
    _postalCodeController.text = organization.postalCode;
    _contactEmailController.text = organization.contactEmail;
    _contactPhoneController.text = organization.contactPhone;
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isLogo ? 500 : 1200,
      maxHeight: isLogo ? 500 : 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        if (isLogo) {
          _logoFile = File(pickedFile.path);
        } else {
          _bannerFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _saveProfile(Organization organization) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Create updated organization object
      final updatedOrganization = organization.copyWith(
        organizationName: _nameController.text,
        description: _descriptionController.text,
        missionStatement: _missionController.text,
        websiteUrl: _websiteController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        postalCode: _postalCodeController.text,
        contactEmail: _contactEmailController.text,
        contactPhone: _contactPhoneController.text,
      );

      // TODO: Upload images and update organization profile using a repository or service
      // For now, just display a success message and exit editing mode

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      setState(() {
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final organizationAsync = ref.watch(organizationProvider(user?.id ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Profile'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings screen
            },
          ),
        ],
      ),
      body: organizationAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stackTrace) => ErrorDisplay(
          message: 'Failed to load organization profile',
          onRetry: () => ref.refresh(organizationProvider(user?.id ?? '')),
        ),
        data: (organization) {
          if (organization == null) {
            return const Center(child: Text('Organization not found'));
          }

          // Initialize controllers if not in editing mode
          if (!_isEditing) {
            _initControllers(organization);
          }

          return _isEditing
              ? _buildEditForm(context, organization)
              : _buildProfileView(context, organization);
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, Organization organization) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(organizationProvider(organization.userId));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organization banner
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppThemes.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: organization.bannerUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: organization.bannerUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.business,
                              size: 50,
                              color: AppThemes.primaryColor,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.business,
                            size: 50,
                            color: AppThemes.primaryColor,
                          ),
                        ),
                ),

                // Organization logo
                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: organization.logoUrl != null
                          ? CachedNetworkImage(
                              imageUrl: organization.logoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Center(
                                child: Text(
                                  organization.organizationName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                organization.organizationName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppThemes.primaryColor,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                // Edit button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: AppThemes.primaryColor,
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 50),

            // Organization name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization.organizationName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),

                  const SizedBox(height: 4),

                  // Organization type
                  Text(
                    organization.organizationType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Verification status
                  VerificationStatusCard(
                    status: organization.verificationStatus,
                    onAction: () {
                      // Navigate to verification details or form
                    },
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (organization.description != null &&
                      organization.description!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'About'),
                    const SizedBox(height: 8),
                    Text(
                      organization.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Mission
                  if (organization.missionStatement != null &&
                      organization.missionStatement!.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Mission'),
                    const SizedBox(height: 8),
                    Text(
                      organization.missionStatement!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Categories
                  if (organization.categories.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Categories'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: organization.categories.map((category) {
                        return Chip(
                          label: Text(category.name),
                          backgroundColor:
                              AppThemes.primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: AppThemes.primaryColor,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Contact information
                  _buildSectionTitle(context, 'Contact Information'),
                  const SizedBox(height: 8),
                  _buildInfoRow(context, 'Email', organization.contactEmail),
                  _buildInfoRow(context, 'Phone', organization.contactPhone),
                  if (organization.websiteUrl != null)
                    _buildInfoRow(context, 'Website', organization.websiteUrl!),

                  const SizedBox(height: 24),

                  // Address
                  _buildSectionTitle(context, 'Address'),
                  const SizedBox(height: 8),
                  Text(
                    organization.formattedAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 16),

                  // Map button
                  if (organization.latitude != null &&
                      organization.longitude != null)
                    SecondaryButton(
                      onPressed: () {
                        // Open map with organization location
                      },
                      label: 'View on Map',
                      icon: Icons.map,
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, Organization organization) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner image picker
            GestureDetector(
              onTap: () => _pickImage(false),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _bannerFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _bannerFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : organization.bannerUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: organization.bannerUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.image,
                                    size: 50,
                                    color: AppThemes.primaryColor,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to change banner image'),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.image,
                                size: 50,
                                color: AppThemes.primaryColor,
                              ),
                              SizedBox(height: 8),
                              Text('Tap to add banner image'),
                            ],
                          ),
              ),
            ),

            const SizedBox(height: 20),

            // Logo image picker
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(true),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _logoFile != null
                        ? Image.file(
                            _logoFile!,
                            fit: BoxFit.cover,
                          )
                        : organization.logoUrl != null
                            ? CachedNetworkImage(
                                imageUrl: organization.logoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.image,
                                      size: 24,
                                      color: AppThemes.primaryColor,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Tap to change',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.image,
                                    size: 24,
                                    color: AppThemes.primaryColor,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tap to add logo',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Organization name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Organization name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Mission
            TextFormField(
              controller: _missionController,
              decoration: const InputDecoration(
                labelText: 'Mission Statement',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Website
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),

            // Contact information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Contact email
            TextFormField(
              controller: _contactEmailController,
              decoration: const InputDecoration(
                labelText: 'Contact Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact email is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Contact phone
            TextFormField(
              controller: _contactPhoneController,
              decoration: const InputDecoration(
                labelText: 'Contact Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Contact phone is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Address
            Text(
              'Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Street address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // City and state
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Country and postal code
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Postal code is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save and cancel buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    onPressed: () => _saveProfile(organization),
                    label: 'Save Profile',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SecondaryButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    label: 'Cancel',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
