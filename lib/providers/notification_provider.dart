import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;
  
  bool _isInitialized = false;
  bool _permissionGranted = false;
  String? _deviceToken;
  List<Map<String, dynamic>> _notifications = [];
  
  NotificationProvider() : _notificationService = NotificationService();
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get permissionGranted => _permissionGranted;
  String? get deviceToken => _deviceToken;
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n['read']).length;
  
  // Initialize notification service
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      _permissionGranted = await _notificationService.requestPermission();
      
      if (_permissionGranted) {
        _deviceToken = await _notificationService.getDeviceToken();
        await _notificationService.setupForegroundNotificationHandling();
        await _notificationService.setupBackgroundNotificationHandling();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }
  
  // Request permission
  Future<bool> requestPermission() async {
    try {
      _permissionGranted = await _notificationService.requestPermission();
      notifyListeners();
      return _permissionGranted;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }
  
  // Send notification
  Future<void> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _notificationService.sendNotification(
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  
  // Add notification to local list
  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': notification['title'] ?? '',
      'body': notification['body'] ?? '',
      'data': notification['data'] ?? {},
      'timestamp': DateTime.now(),
      'read': false,
    });
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications = _notifications.sublist(0, 50);
    }
    
    notifyListeners();
  }
  
  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['read'] = true;
      notifyListeners();
    }
  }
  
  // Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification['read'] = true;
    }
    notifyListeners();
  }
  
  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }
  
  // Remove specific notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n['id'] == notificationId);
    notifyListeners();
  }
  
  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
  
  void _handleNotificationTap(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>? ?? {};
    final type = data['type'] as String?;
    
    // Store the notification action for the UI to handle
    _lastNotificationAction = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    notifyListeners();
  }

  // Get the last notification action for UI to handle
  Map<String, dynamic>? _lastNotificationAction;
  Map<String, dynamic>? get lastNotificationAction => _lastNotificationAction;
  
  void clearLastNotificationAction() {
    _lastNotificationAction = null;
    notifyListeners();
  }

  void registerDeviceToken(String token) {
    // Register device token for push notifications
    print('Device token registered: $token');
    notifyListeners();
  }
} 
