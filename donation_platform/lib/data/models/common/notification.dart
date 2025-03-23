class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String notificationType;
  final String? relatedEntityType; // donation, organization, etc.
  final String? relatedEntityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  
  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.relatedEntityType,
    this.relatedEntityId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });
  
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      message: json['message'],
      notificationType: json['notification_type'],
      relatedEntityType: json['related_entity_type'],
      relatedEntityId: json['related_entity_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Create a copy of the notification with updated fields
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? notificationType,
    String? relatedEntityType,
    String? relatedEntityId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}