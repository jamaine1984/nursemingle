import '../models/live_stream.dart';
import '../utils/api_service.dart';

class LiveStreamService {
  static const String baseUrl = 'https://nurse-mingle.com/api';

  static Future<List<LiveStream>> getActiveStreams() async {
    try {
      print('📺 LIVE_STREAM_SERVICE: Fetching active streams...');
      final response = await ApiService.get('/api/streaming/active');
      
      print('📺 LIVE_STREAM_SERVICE: Active streams response: $response');
      
      if (response['success'] == true) {
        final List<dynamic> streamsData = response['data'] ?? [];
        print('✅ LIVE_STREAM_SERVICE: Found ${streamsData.length} active streams');
        return streamsData.map((data) => LiveStream.fromJson(data)).toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to load streams');
      }
    } catch (e) {
      print('❌ LIVE_STREAM_SERVICE: Error loading active streams: $e');
      throw Exception('Failed to load active streams: $e');
    }
  }

  static Future<LiveStream> createStream(String title, String description, {String? category}) async {
    try {
      print('📺 LIVE_STREAM_SERVICE: Creating stream with title: $title');
      final response = await ApiService.post('/api/streaming/start', {
        'title': title,
        'description': description,
        'category': category ?? 'general',
      });
      
      print('📺 LIVE_STREAM_SERVICE: Create stream response: $response');
      
      if (response['success'] == true) {
        print('✅ LIVE_STREAM_SERVICE: Stream created successfully');
        return LiveStream.fromJson(response['data']);
      } else {
        print('❌ LIVE_STREAM_SERVICE: Failed to create stream: ${response['error']}');
        throw Exception(response['error'] ?? 'Failed to create stream');
      }
    } catch (e) {
      print('💥 LIVE_STREAM_SERVICE: Exception creating stream: $e');
      throw Exception('Failed to create stream: $e');
    }
  }

  static Future<void> endStream(String streamId) async {
    try {
      print('📺 LIVE_STREAM_SERVICE: Ending stream: $streamId');
      final response = await ApiService.post('/api/streaming/end', {
        'streamId': streamId,
      });
      
      print('📺 LIVE_STREAM_SERVICE: End stream response: $response');
      
      if (response['success'] != true) {
        print('❌ LIVE_STREAM_SERVICE: Failed to end stream: ${response['error']}');
        throw Exception(response['error'] ?? 'Failed to end stream');
      }
      
      print('✅ LIVE_STREAM_SERVICE: Stream ended successfully');
    } catch (e) {
      print('💥 LIVE_STREAM_SERVICE: Exception ending stream: $e');
      throw Exception('Failed to end stream: $e');
    }
  }

  static Future<String> joinStream(String streamId) async {
    try {
      final response = await ApiService.post('/livestreams/$streamId/join', {});
      
      if (response['success'] == true) {
        return response['data']['token'];
      } else {
        throw Exception(response['error'] ?? 'Failed to join stream');
      }
    } catch (e) {
      throw Exception('Failed to join stream: $e');
    }
  }
} 

