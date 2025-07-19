import 'dart:convert';
import 'dart:io';
import '../utils/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class MessagesService {
  static final MessagesService _instance = MessagesService._internal();
  factory MessagesService() => _instance;
  MessagesService._internal();
  WebSocketChannel? _channel;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  /// Connects to the chat WebSocket for a match. Calls [onMessage] for each incoming message.
  void connectWebSocket(String matchId, void Function(Map<String, dynamic>) onMessage) {
    disconnectWebSocket();
    try {
      // Use the production URL for WebSocket
      _channel = WebSocketChannel.connect(Uri.parse('wss://nurse-mingle.com/ws/chat/$matchId'));
      _channel!.stream.listen((data) {
        final msg = jsonDecode(data);
        onMessage(msg);
        _reconnectAttempts = 0; // Reset on success
      }, onError: (e) {
        debugPrint('🛑 WEBSOCKET: WebSocket error: $e');
        _tryReconnect(matchId, onMessage);
      }, onDone: () {
        debugPrint('🛑 WEBSOCKET: WebSocket closed.');
        _tryReconnect(matchId, onMessage);
      });
    } catch (e, stack) {
      debugPrint('🛑 WEBSOCKET: Exception in connectWebSocket: $e\n$stack');
      _tryReconnect(matchId, onMessage);
    }
  }

  void _tryReconnect(String matchId, void Function(Map<String, dynamic>) onMessage) {
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      Future.delayed(Duration(seconds: 2 * _reconnectAttempts), () {
        debugPrint('🔄 WEBSOCKET: Attempting WebSocket reconnect ($_reconnectAttempts)...');
        connectWebSocket(matchId, onMessage);
      });
    } else {
      debugPrint('❌ WEBSOCKET: Max WebSocket reconnect attempts reached.');
    }
  }

  /// Sends a message or typing status via WebSocket. If [file] is provided, encodes as base64 (for small files).
  Future<void> sendWebSocketMessage(Map<String, dynamic> message, {File? file, String? fileType}) async {
    if (file != null && fileType != null) {
      // For small files, send as base64. For large, fallback to HTTP.
      final bytes = await file.readAsBytes();
      if (bytes.length < 2 * 1024 * 1024) { // <2MB
        message['fileData'] = base64Encode(bytes);
        message['fileType'] = fileType;
        message['fileName'] = file.path.split('/').last;
      } else {
        // Fallback to HTTP upload, then send fileUrl via WebSocket
        final uploadResult = await sendMessage(matchId: message['matchId'], message: message['message'] ?? '', file: file, fileType: fileType);
        if (uploadResult['success'] && uploadResult['data']?['fileUrl'] != null) {
          message['fileUrl'] = uploadResult['data']['fileUrl'];
          message['fileType'] = fileType;
        }
      }
    }
    _channel?.sink.add(jsonEncode(message));
  }

  void disconnectWebSocket() {
    _channel?.sink.close();
    _channel = null;
  }

  // Get conversations/matches using ApiService - NO MOCK FALLBACK
  Future<Map<String, dynamic>> getMatches() async {
    try {
      print('💬 MESSAGES_SERVICE: Loading matches/conversations...');
      final response = await ApiService.get('/api/messages/conversations');
      
      if (response['success'] == true) {
        final conversations = response['data'] ?? [];
        print('✅ MESSAGES_SERVICE: Loaded ${conversations.length} conversations');
        
        return {
          'success': true,
          'data': {
            'matches': conversations,
          }
        };
      } else {
        print('❌ MESSAGES_SERVICE: Failed to load conversations');
        throw Exception(response['error'] ?? 'Failed to load conversations');
      }
    } catch (e) {
      print('💥 MESSAGES_SERVICE: Exception getting matches: $e');
      // Return empty list instead of mock data
      return {
        'success': true,
        'data': {
          'matches': [],
        },
        'message': 'No conversations yet',
      };
    }
  }

  // Get messages for a specific conversation - NO MOCK FALLBACK
  Future<Map<String, dynamic>> getMessages(String matchId) async {
    try {
      print('💬 MESSAGES_SERVICE: Loading messages for match: $matchId');
      final response = await ApiService.get('/api/messages/conversations/$matchId');
      
      if (response['success'] == true) {
        final messages = response['data'] ?? [];
        print('✅ MESSAGES_SERVICE: Loaded ${messages.length} messages');
        
        return {
          'success': true,
          'data': {
            'messages': messages,
          }
        };
      } else {
        print('❌ MESSAGES_SERVICE: Failed to load messages for $matchId');
        throw Exception(response['error'] ?? 'Failed to load messages');
      }
    } catch (e) {
      print('💥 MESSAGES_SERVICE: Exception getting messages: $e');
      // Return empty list instead of mock data
      return {
        'success': true,
        'data': {
          'messages': [],
        },
        'message': 'No messages in this conversation yet',
      };
    }
  }

  /// Sends a message via ApiService - supports text, image, or video file.
  Future<Map<String, dynamic>> sendMessage({required String matchId, required String message, File? file, String? fileType}) async {
    try {
      print('💬 MESSAGES_SERVICE: Sending message to match: $matchId');
      
      Map<String, dynamic> response;
      
      if (file != null) {
        // Send file message using multipart upload
        response = await ApiService.uploadFile('/api/messages/send-file', file, fieldName: 'file');
        if (response['success'] == true) {
          // Add message text and match ID
          final fileResponse = await ApiService.post('/api/messages/send', {
            'match_id': matchId,
            'message': message,
            'file_url': response['data']['url'],
            'file_type': fileType,
          });
          response = fileResponse;
        }
      } else {
        // Send text message
        response = await ApiService.post('/api/messages/send', {
          'match_id': matchId,
          'message': message,
        });
      }
      
      if (response['success'] == true) {
        print('✅ MESSAGES_SERVICE: Message sent successfully');
        return {'success': true, 'data': response['data']};
      } else {
        print('❌ MESSAGES_SERVICE: Failed to send message');
        throw Exception(response['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('💥 MESSAGES_SERVICE: Exception sending message: $e');
      return {'success': false, 'message': 'Failed to send message: $e'};
    }
  }

  /// Sends typing status via ApiService
  Future<void> sendTypingStatus(String matchId, bool isTyping) async {
    try {
      await ApiService.post('/api/messages/typing', {
        'match_id': matchId,
        'typing': isTyping,
      });
    } catch (e) {
      print('⚠️ MESSAGES_SERVICE: Failed to send typing status: $e');
      // Don't throw - typing status is non-critical
    }
  }
} 
