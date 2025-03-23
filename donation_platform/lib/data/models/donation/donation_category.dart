class DonationCategory {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  DonationCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory DonationCategory.fromJson(Map<String, dynamic> json) {
    return DonationCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  // Create a copy of the category with updated fields
  DonationCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  // Get icon data for this category
  Map<String, dynamic> getIconData() {
    // Default icon mappings for common donation categories
    switch (name.toLowerCase()) {
      case 'money':
        return {'icon': 'attach_money', 'color': 0xFF4CAF50};
      case 'food':
        return {'icon': 'restaurant', 'color': 0xFFF44336};
      case 'clothes':
        return {'icon': 'checkroom', 'color': 0xFF2196F3};
      case 'books':
        return {'icon': 'menu_book', 'color': 0xFF9C27B0};
      case 'medical supplies':
        return {'icon': 'medical_services', 'color': 0xFF00BCD4};
      case 'household items':
        return {'icon': 'home', 'color': 0xFFFF9800};
      default:
        return {'icon': 'volunteer_activism', 'color': 0xFF607D8B};
    }
  }
}