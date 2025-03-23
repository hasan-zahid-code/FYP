class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  
  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
  });
  
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['icon_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
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
    };
  }
  
  // Create a copy of the category with updated fields
  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}