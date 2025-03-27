import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:donation_platform/config/themes.dart';
import 'package:donation_platform/providers/organization_providers.dart';

class CategoryFilterChips extends ConsumerWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: LinearProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => const SizedBox(
        height: 40,
        child: Center(
          child: Text('Failed to load categories'),
        ),
      ),
      data: (categories) {
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for "All" category
            itemBuilder: (context, index) {
              // "All" category
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedCategory.isEmpty,
                    onSelected: (selected) {
                      if (selected) {
                        onCategorySelected('');
                      }
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppThemes.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedCategory.isEmpty
                          ? AppThemes.primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: selectedCategory.isEmpty
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: selectedCategory.isEmpty
                            ? AppThemes.primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                );
              }

              // Category chips
              final category = categories[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(category.name),
                  selected: selectedCategory == category.id,
                  onSelected: (selected) {
                    if (selected) {
                      onCategorySelected(category.id);
                    } else {
                      onCategorySelected('');
                    }
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppThemes.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: selectedCategory == category.id
                        ? AppThemes.primaryColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: selectedCategory == category.id
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selectedCategory == category.id
                          ? AppThemes.primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
