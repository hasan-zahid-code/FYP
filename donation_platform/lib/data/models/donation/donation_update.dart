class DonationUpdate {
  final String id;
  final String donationId;
  final String title;
  final String description;
  final List<String>? mediaUrls; // Images or videos showing impact
  final String createdBy; // User ID who created the update
  final DateTime createdAt;

  DonationUpdate({
    required this.id,
    required this.donationId,
    required this.title,
    required this.description,
    this.mediaUrls,
    required this.createdBy,
    required this.createdAt,
  });

  // Create a new update with a generated ID
  factory DonationUpdate.create({
    required String donationId,
    required String title,
    required String description,
    List<String>? mediaUrls,
    required String createdBy,
  }) {
    return DonationUpdate(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Simple ID generation
      donationId: donationId,
      title: title,
      description: description,
      mediaUrls: mediaUrls,
      createdBy: createdBy,
      createdAt: DateTime.now(),
    );
  }

  factory DonationUpdate.fromJson(Map<String, dynamic> json) {
    return DonationUpdate(
      id: json['id'],
      donationId: json['donation_id'],
      title: json['title'],
      description: json['description'],
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'])
          : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'title': title,
      'description': description,
      'media_urls': mediaUrls,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy of the update with updated fields
  DonationUpdate copyWith({
    String? id,
    String? donationId,
    String? title,
    String? description,
    List<String>? mediaUrls,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return DonationUpdate(
      id: id ?? this.id,
      donationId: donationId ?? this.donationId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
