import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Production backend configuration
  static const String baseUrl = 'https://nurse-mingle.com';
  static const String apiVersion = '/api';
  static const String fullBaseUrl = '$baseUrl$apiVersion';
  
  // Auth token storage
  static String? _token;
  
  // Get auth token from storage
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  // Get headers with auth token
  static Future<Map<String, String>> getHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request with comprehensive logging
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    print('🌐 API_SERVICE [GET] → $endpoint${queryParams != null ? ' with params: $queryParams' : ''}');
    
    try {
      final token = await getAuthToken();
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      print('🌐 API_SERVICE [GET] Full URL: ${uri.toString()}');
      print('🌐 API_SERVICE [GET] Headers: ${headers.keys.join(', ')}');
      
      final response = await http.get(uri, headers: headers);
      
      print('🌐 API_SERVICE [GET] Response Status: ${response.statusCode}');
      print('🌐 API_SERVICE [GET] Response Body Length: ${response.body.length} chars');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ API_SERVICE [GET] Success: $endpoint');
        return {'success': true, 'data': data};
      } else if (response.statusCode == 404) {
        print('❌ API_SERVICE [GET] 404 Not Found: $endpoint');
        return {'success': false, 'error': 'Endpoint not found', 'status': 404};
      } else {
        try {
          final errorData = json.decode(response.body);
          print('❌ API_SERVICE [GET] Error ${response.statusCode}: ${errorData['message'] ?? 'Request failed'}');
          return {'success': false, 'error': errorData['message'] ?? 'Request failed', 'status': response.statusCode};
        } catch (e) {
          print('❌ API_SERVICE [GET] HTML Response Error: ${response.statusCode}');
          return {'success': false, 'error': 'Server returned HTML instead of JSON. Check API endpoint.', 'status': response.statusCode};
        }
      }
    } catch (e) {
      print('💥 API_SERVICE [GET] Exception: ${e.toString()}');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    print('🌐 API_SERVICE [POST] → $endpoint');
    print('🌐 API_SERVICE [POST] Data Keys: ${data.keys.join(', ')}');
    
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$fullBaseUrl$endpoint');
      
      print('🌐 API_SERVICE [POST] Full URL: ${url.toString()}');
      print('🌐 API_SERVICE [POST] Headers: ${headers.keys.join(', ')}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      
      print('🌐 API_SERVICE [POST] Response Status: ${response.statusCode}');
      print('🌐 API_SERVICE [POST] Response Body Length: ${response.body.length} chars');
      
      if (response.body.startsWith('<!DOCTYPE html>')) {
        print('❌ API_SERVICE [POST] HTML Response Error: ${response.statusCode}');
        throw ApiException('Server returned HTML instead of JSON. Check API endpoint.', response.statusCode);
      }
      
      final responseData = json.decode(response.body);
      print('✅ API_SERVICE [POST] Success: $endpoint');
      return responseData;
    } catch (e) {
      print('💥 API_SERVICE [POST] Exception: ${e.toString()}');
      throw ApiException(e.toString(), 0);
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$fullBaseUrl$endpoint'),
        headers: await getHeaders(),
        body: json.encode(data),
      );
      
      if (response.body.startsWith('<!DOCTYPE html>')) {
        throw ApiException('Server returned HTML instead of JSON. Check API endpoint.', response.statusCode);
      }
      
      return json.decode(response.body);
    } catch (e) {
      throw ApiException(e.toString(), 0);
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    return await post('/auth/register', userData);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await post('/auth/login', {'email': email, 'password': password});
  }

  static Future<Map<String, dynamic>> logout() async {
    return await post('/auth/logout', {});
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/user/current');
  }

  static Future<Map<String, dynamic>> isAdmin() async {
    return await get('/user/is-admin');
  }

  static bool get isAuthenticated {
    return _token != null;
  }

  // User profile endpoints
  static Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/user/profile');
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData) async {
    // Handle file uploads separately
    if (profileData.containsKey('profile_image') && profileData['profile_image'] != null) {
      return await uploadProfileWithImage(profileData);
    } else {
      return await put('/user/profile', profileData);
    }
  }

  // New method to handle image uploads with multipart form data
  static Future<Map<String, dynamic>> uploadProfileWithImage(Map<String, dynamic> profileData) async {
    print('📸 API_SERVICE: Uploading profile with image...');
    
    try {
      final imagePath = profileData['profile_image'] as String;
      print('📸 API_SERVICE: Image path: $imagePath');
      
      // Create multipart request
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/user/profile'),
      );
      
      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });
      
      // Add authentication token if available
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      // Add text fields
      profileData.forEach((key, value) {
        if (key != 'profile_image' && value != null) {
          if (value is List) {
            request.fields[key] = jsonEncode(value);
          } else if (value is Map) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        }
      });
      
      // Add image file
      if (imagePath.isNotEmpty) {
        final file = await http.MultipartFile.fromPath(
          'profile_image',
          imagePath,
          filename: 'profile_image.jpg',
        );
        request.files.add(file);
        print('📸 API_SERVICE: Image file added to request');
      }
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📸 API_SERVICE: Upload response status: ${response.statusCode}');
      print('📸 API_SERVICE: Upload response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ API_SERVICE: Profile image uploaded successfully');
        return responseData;
      } else {
        print('❌ API_SERVICE: Upload failed with status ${response.statusCode}');
        throw Exception('Failed to upload profile image: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API_SERVICE: Error uploading profile image: $e');
      
      // Fallback to regular profile update without image
      print('🔄 API_SERVICE: Falling back to profile update without image');
      final dataWithoutImage = Map<String, dynamic>.from(profileData);
      dataWithoutImage.remove('profile_image');
      return await put('/user/profile', dataWithoutImage);
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return await updateUserProfile(profileData);
  }

  // Discovery endpoints - Fixed to match backend structure
  static Future<Map<String, dynamic>> getDiscoveryProfiles() async {
    return await get('/api/user/profiles');
  }

  static Future<Map<String, dynamic>> likeProfile(String userId) async {
    return await post('/api/user/like', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> admireProfile(String userId) async {
    return await post('/api/user/admire', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> dislikeProfile(String userId) async {
    return await post('/api/user/dislike', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> superLikeProfile(String userId) async {
    return await post('/api/user/super-like', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> getAdmirers({bool showBlurred = false}) async {
    return await get('/api/user/admirers?blurred=$showBlurred');
  }

  static Future<Map<String, dynamic>> getMyAdmirers() async {
    return await get('/api/user/my-admirers');
  }

  // Gift endpoints - Fixed to use consistent /api/ prefix
  static Future<Map<String, dynamic>> getGifts() async {
    return await get('/api/gifts');
  }

  static Future<Map<String, dynamic>> purchaseGift(String giftId) async {
    return await post('/api/gifts/purchase', {'gift_id': giftId});
  }

  static Future<Map<String, dynamic>> sendGift(String recipientId, String giftId) async {
    return await post('/api/gifts/send', {'recipient_id': recipientId, 'gift_id': giftId});
  }

  static Future<Map<String, dynamic>> claimFreeGifts() async {
    return await post('/api/gifts/claim-free', {});
  }

  // Message endpoints - Fixed to use consistent /api/ prefix
  static Future<Map<String, dynamic>> getMessages() async {
    return await get('/api/messages');
  }

  static Future<Map<String, dynamic>> getMessagesForConversation(String conversationId) async {
    return await get('/api/messages/conversations/$conversationId');
  }

  static Future<Map<String, dynamic>> sendMessage(String recipientId, String message) async {
    return await post('/api/messages/send', {
      'recipient_id': recipientId,
      'message': message,
    });
  }

  static Future<Map<String, dynamic>> getConversations() async {
    return await get('/api/messages/conversations');
  }

  // Live stream endpoints - Fixed to use /api/streaming
  static Future<Map<String, dynamic>> getLiveStreams() async {
    return await get('/api/streaming/active');
  }

  static Future<Map<String, dynamic>> createLiveStream(String title, String description) async {
    return await post('/api/streaming/create', {
      'title': title,
      'description': description,
    });
  }

  static Future<Map<String, dynamic>> joinLiveStream(String streamId) async {
    return await post('/api/streaming/$streamId/join', {});
  }

  // Subscription endpoints
  static Future<Map<String, dynamic>> getSubscription() async {
    return await get('/user/subscription');
  }

  static Future<Map<String, dynamic>> purchaseSubscription(String plan) async {
    return await post('/user/subscription', {'plan': plan});
  }

  static Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    return await post('/auth/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    return await get('/subscription/plans');
  }

  static Future<Map<String, dynamic>> getMySubscription() async {
    return await get('/user/subscription');
  }

  static Future<Map<String, dynamic>> claimFreeGift(String giftId) async {
    return await post('/gifts/claim', {'gift_id': giftId});
  }

  // Usage tracking
  static Future<Map<String, dynamic>> trackUsage(String action, {Map<String, dynamic>? metadata}) async {
    try {
      // Temporarily disable usage tracking to prevent 404 errors
      // This endpoint is not implemented on the backend yet
      return {'status': 'disabled', 'message': 'Usage tracking temporarily disabled'};
      
      /* Uncomment when backend endpoint is ready
      return await post('/usage/track', {
        'action': action,
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      */
    } catch (e) {
      // Silently fail usage tracking to prevent app crashes
      print('Usage tracking failed: $e');
      return {'status': 'failed', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> data) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      
      if (response.headers['content-type']?.contains('application/json') ?? false) {
        return jsonDecode(response.body);
      } else {
        return {'statusCode': response.statusCode, 'body': response.body};
      }
    } catch (e) {
      print('PATCH request error: $e');
      throw Exception('Failed to update resource: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    final headers = await getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final response = await http.delete(
        url,
        headers: headers,
      );
      
      if (response.statusCode == 204) {
        return {'success': true};
      } else if (response.headers['content-type']?.contains('application/json') ?? false) {
        return jsonDecode(response.body);
      } else {
        return {'statusCode': response.statusCode, 'body': response.body};
      }
    } catch (e) {
      print('DELETE request error: $e');
      throw Exception('Failed to delete resource: $e');
    }
  }

  static Future<Map<String, dynamic>> getLiveKitToken(String roomName) async {
    try {
      final response = await get('/api/live/token', queryParams: {'room': roomName});
      return response;
    } catch (e) {
      print('Error getting LiveKit token: $e');
      // Return mock token for development
      return {
        'token': 'mock-livekit-token',
        'url': 'wss://nurse-mingle.com',
      };
    }
  }

  // AdMob rewarded ad completion
  static Future<Map<String, dynamic>> completeRewardedAd(String adType, {Map<String, dynamic>? metadata}) async {
    return await post('/ads/complete', {
      'ad_type': adType,
      'metadata': metadata ?? {},
    });
  }

  // Helper methods for backward compatibility
  static Future<Map<String, dynamic>> likeUser(String userId) async {
    return await likeProfile(userId);
  }

  static Future<Map<String, dynamic>> admireUser(String userId) async {
    return await admireProfile(userId);
  }

  static Future<Map<String, dynamic>> dislikeUser(String userId) async {
    return await dislikeProfile(userId);
  }

  static Future<Map<String, dynamic>> superLikeUser(String userId) async {
    return await superLikeProfile(userId);
  }

  // File upload method
  static Future<Map<String, dynamic>> uploadFile(String endpoint, File file, {String fieldName = 'file'}) async {
    try {
      print('📤 API_SERVICE [UPLOAD] → $endpoint');
      
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      );
      request.files.add(multipartFile);
      
      print('📤 API_SERVICE [UPLOAD] File: ${file.path}');
      print('📤 API_SERVICE [UPLOAD] Field: $fieldName');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📤 API_SERVICE [UPLOAD] Response Status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        print('✅ API_SERVICE [UPLOAD] Success');
        return responseData;
      } else {
        print('❌ API_SERVICE [UPLOAD] ${response.statusCode}: $endpoint');
        return {
          'success': false,
          'error': 'Upload failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('💥 API_SERVICE [UPLOAD] Exception: $e');
      return {
        'success': false,
        'error': 'Upload failed: $e',
      };
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
} 
