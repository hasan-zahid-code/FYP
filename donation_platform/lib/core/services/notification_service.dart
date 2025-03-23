import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:donation_platform/config/app_config.dart';
import 'package:donation_platform/data/models/common/notification.dart'
    as model;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  final _notificationStreamController =
      StreamController<model.Notification>.broadcast();

  Stream<model.Notification> get notificationStream =>
      _notificationStreamController.stream;
  RealtimeChannel? _notificationChannel;
  bool _isInitialized = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    if (!AppConfig.enableNotifications || _isInitialized) {
      return;
    }

    _isInitialized = true;

    // Setup real-time notifications if user is authenticated
    setupRealtimeNotifications();

    // Listen for auth state changes to setup/teardown realtime connection
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        setupRealtimeNotifications();
      } else if (event == AuthChangeEvent.signedOut) {
        _notificationChannel?.unsubscribe();
      }
    });
  }

  void setupRealtimeNotifications() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Subscribe to user's notifications
    _notificationChannel = _supabase.channel('notifications:${user.id}');

    _notificationChannel!.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
        filter: 'user_id=eq.${user.id}',
      ),
      (payload, [ref]) {
        try {
          final notification = model.Notification.fromJson(payload['new']);
          _notificationStreamController.add(notification);
        } catch (e) {
          debugPrint('Error parsing notification: $e');
        }
      },
    ).subscribe();
  }

  // Get all notifications for current user
  Future<List<model.Notification>> getNotifications(
      {int limit = 20, int offset = 0}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((data) => model.Notification.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String()
      }).eq('id', notificationId);

      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('notifications')
          .update(
              {'is_read': true, 'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', user.id)
          .eq('is_read', false);

      return true;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return false;
    }
  }

  // Count unread notifications
  Future<int> getUnreadCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 0;

      // Get all unread notifications and count them
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .eq('is_read', false);

      // The response will be a list, so we can just count its length
      return (response as List).length;
    } catch (e) {
      debugPrint('Error counting unread notifications: $e');
      return 0;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabase.from('notifications').delete().eq('id', notificationId);

      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  // Dispose
  void dispose() {
    _notificationChannel?.unsubscribe();
    _notificationStreamController.close();
  }
}
