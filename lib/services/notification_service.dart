import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl = 'https://api.nursemingle.com'; // Replace with your API URL
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  // Initialize the notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }
  
  // Request permission for notifications
  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }
  
  // Get device token (mock implementation)
  Future<String?> getDeviceToken() async {
    // In a real implementation, this would get the FCM token
    // For now, return a mock token
    return 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  // Show local notification
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'nurse_mingle_channel',
      'Nurse Mingle Notifications',
      channelDescription: 'Notifications for Nurse Mingle app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: data != null ? json.encode(data) : null,
    );
  }
  
  // Send notification to server
  Future<void> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'body': body,
          'data': data ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
      // For development, show local notification as fallback
      await showNotification(title: title, body: body, data: data);
    }
  }
  
  // Subscribe to topic (mock implementation)
  Future<void> subscribeToTopic(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/subscribe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'topic': topic,
          'device_token': await getDeviceToken(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }
  
  // Unsubscribe from topic (mock implementation)
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/unsubscribe'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'topic': topic,
          'device_token': await getDeviceToken(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
  
  // Setup foreground notification handling
  Future<void> setupForegroundNotificationHandling() async {
    // This would typically handle FCM foreground messages
    // For now, just print a message
    print('Foreground notification handling set up');
  }
  
  // Setup background notification handling
  Future<void> setupBackgroundNotificationHandling() async {
    // This would typically handle FCM background messages
    // For now, just print a message
    print('Background notification handling set up');
  }
  
  // Handle notification tap
  void _onNotificationTap(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final Map<String, dynamic> data = json.decode(payload);
        print('Notification tapped with data: $data');
        // Handle navigation based on notification data
        _handleNotificationNavigation(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
          }
  }

  Future<String?> getDeviceToken() async {
    try {
      // Mock device token for development
      await Future.delayed(const Duration(milliseconds: 500));
      return 'mock_device_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      print('Failed to get device token: $e');
      return null;
    }
  }
}
  
  // Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final String? type = data['type'];
    
    switch (type) {
      case 'message':
        // Navigate to chat screen
        print('Navigate to chat screen');
        break;
      case 'like':
        // Navigate to likes screen
        print('Navigate to likes screen');
        break;
      case 'match':
        // Navigate to matches screen
        print('Navigate to matches screen');
        break;
      default:
        // Navigate to main screen
        print('Navigate to main screen');
        break;
    }
  }
  
  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
} 
