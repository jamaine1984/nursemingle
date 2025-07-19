import '../models/message.dart';
import '../utils/api_service.dart';

class MessageService {
  static List<Message> getMockMessages() {
    return [
      Message(
        id: '1',
        senderId: 'user1',
        recipientId: 'current_user',
        conversationId: 'conv1',
        content: 'Hey! How are you doing?',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'sender_name': 'Jane Doe'},
      ),
      Message(
        id: '2',
        senderId: 'user2',
        recipientId: 'current_user',
        conversationId: 'conv2',
        content: 'Great to meet you! Are you working tonight?',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        metadata: {'sender_name': 'Dr. Smith'},
      ),
    ];
  }

  static Future<List<Message>> getMessagesForUser(String userId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Message(
        id: '1',
        senderId: userId,
        recipientId: 'current_user',
        conversationId: 'conv_$userId',
        content: 'Hello!',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        metadata: {'sender_name': 'User'},
      ),
      Message(
        id: '2',
        senderId: 'current_user',
        recipientId: userId,
        conversationId: 'conv_$userId',
        content: 'Hi there! How are you doing?',
        type: 'text',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        metadata: {'sender_name': 'Me'},
      ),
    ];
  }

  static Future<List<Message>> getChatMessages(String userId) async {
    try {
      final response = await ApiService.get('/messages/chat/$userId');
      if (response['success']) {
        final List<dynamic> messagesJson = response['data'] ?? [];
        return messagesJson.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // Return mock data for development
      return [
        Message(
          id: '1',
          senderId: userId,
          recipientId: 'current_user',
          conversationId: 'conv_$userId',
          content: 'Hello!',
          type: 'text',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          metadata: {'sender_name': 'User'},
        ),
        Message(
          id: '2',
          senderId: 'current_user',
          recipientId: userId,
          conversationId: 'conv_$userId',
          content: 'Hi there! How are you doing?',
          type: 'text',
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          metadata: {'sender_name': 'Me'},
        ),
      ];
    }
  }

  static Future<bool> sendMessage(String receiverId, String content) async {
    try {
      final response = await ApiService.post('/messages/send', {
        'receiverId': receiverId,
        'content': content,
      });
      return response['success'] ?? false;
    } catch (e) {
      // Mock success for development
      return true;
    }
  }

  static Future<bool> markAsRead(String messageId) async {
    try {
      final response = await ApiService.put('/messages/$messageId/read', {});
      return response['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
} 
