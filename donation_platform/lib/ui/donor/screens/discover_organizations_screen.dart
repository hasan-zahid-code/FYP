import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/ui/donor/widgets/category_filter_chips.dart';
import 'package:donation_platform/ui/donor/widgets/organization_card.dart';
import 'package:donation_platform/ui/common/widgets/inputs/search_bar.dart';
import 'package:donation_platform/providers/auth_providers.dart';
import 'package:donation_platform/data/models/organization/organization.dart';
import 'package:donation_platform/providers/organization_providers.dart';
import 'package:donation_platform/ui/common/widgets/loading_indicators.dart';
import 'package:donation_platform/ui/common/widgets/error_displays.dart';
import 'package:go_router/go_router.dart';

class DiscoverOrganizationsScreen extends ConsumerStatefulWidget {
  const DiscoverOrganizationsScreen({super.key});

  @override
  ConsumerState<DiscoverOrganizationsScreen> createState() => _DiscoverOrganizationsScreenState();
}

class _DiscoverOrganizationsScreenState extends ConsumerState<DiscoverOrganizationsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).user;
    final organizationsAsync = ref.watch(nearbyOrganizationsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    // User greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello ${user?.fullName.split(' ')[0] ?? 'there'}!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Make a difference today',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Notifications button
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        // Navigate to notifications
                      },
                    ),
                  ],
                ),
              ),
              
              // Search bar
              CustomSearchBar(
                controller: _searchController,
                hintText: 'Search organizations',
                onSearch: (query) {
                  // TODO: Implement search functionality
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category filters
              CategoryFilterChips(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                  // TODO: Apply category filter
                },
              ),
              
              const SizedBox(height: 24),
              
              // Organizations list title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nearby Organizations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Map view button
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to map view
                    },
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Map View'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppThemes.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Organizations list
              Expanded(
                child: organizationsAsync.when(
                  loading: () => const Center(child: LoadingSpinner()),
                  error: (error, stackTrace) => ErrorDisplay(
                    message: 'Failed to load organizations',
                    onRetry: () => ref.refresh(nearbyOrganizationsProvider),
                  ),
                  data: (organizations) {
                    if (organizations.isEmpty) {
                      return const Center(
                        child: Text('No organizations found nearby'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: organizations.length,
                      itemBuilder: (context, index) {
                        final organization = organizations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: OrganizationCard(
                            organization: organization,
                            onTap: () {
                              // Navigate to organization detail
                              context.push('/donor/organization/${organization.userId}');
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}