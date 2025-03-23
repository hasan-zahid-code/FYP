class DonationTracking {
  final String id;
  final String donationId;
  final String status; // "received", "processing", "utilized", "completed"
  final String? feedback;
  final String updatedBy;
  final DateTime createdAt;
  final List<DonationUpdate>? updates;
  
  DonationTracking({
    required this.id,
    required this.donationId,
    required this.status,
    this.feedback,
    required this.updatedBy,
    required this.createdAt,
    this.updates,
  });
  
  factory DonationTracking.fromJson(Map<String, dynamic> json) {
    return DonationTracking(
      id: json['id'],
      donationId: json['donation_id'],
      status: json['status'],
      feedback: json['feedback'],
      updatedBy: json['updated_by'],
      createdAt: DateTime.parse(json['created_at']),
      updates: json['updates'] != null 
        ? (json['updates'] as List).map((u) => DonationUpdate.fromJson(u)).toList()
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donation_id': donationId,
      'status': status,
      'feedback': feedback,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updates': updates?.map((u) => u.toJson()).toList(),
    };
  }
  
  // Create a copy of the tracking with updated fields
  DonationTracking copyWith({
    String? id,
    String? donationId,
    String? status,
    String? feedback,
    String? updatedBy,
    DateTime? createdAt,
    List<DonationUpdate>? updates,
  }) {
    return DonationTracking(
      id: id ?? this.id,
      donationId: donationId ?? this.donationId,
      status: status ?? this.status,
      feedback: feedback ?? this.feedback,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updates: updates ?? this.updates,
    );
  }
}

class DonationUpdate {
  final String id;
  final String donationId;
  final String title;
  final String description;
  final List<String>? mediaUrls; // Images or videos showing impact
  final String createdBy;
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
  
  factory DonationUpdate.fromJson(Map<String, dynamic> json) {
    return DonationUpdate(
      id: json['id'],
      donationId: json['donation_id'],
      title: json['title'],
      description: json['description'],
      mediaUrls: json['media_urls'] != null ? List<String>.from(json['media_urls']) : null,
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