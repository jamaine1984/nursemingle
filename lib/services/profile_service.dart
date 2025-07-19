import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../api_config.dart';
import 'auth_service.dart';

class ProfileService {
  // Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      headers.remove('Content-Type'); // Remove for multipart

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/users/profile/photo'),
      );

      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          imageFile.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(responseData)};
      } else {
        return {'success': false, 'message': 'Failed to upload photo'};
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Upload profile photo exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Create/update user profile
  Future<Map<String, dynamic>> uploadProfile({
    required File image,
    required String displayName,
    required String state,
    required int age,
    required String jobTitle,
    required String bio,
  }) async {
    try {
      // First upload the photo
      final photoResult = await uploadProfilePhoto(image);
      if (!photoResult['success']) {
        return photoResult;
      }

      final photoUrl = photoResult['data']['photoUrl'];

      // Then create/update the profile
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: jsonEncode({
          'displayName': displayName,
          'state': state,
          'age': age,
          'jobTitle': jobTitle,
          'bio': bio,
          'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Failed to save profile'};
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Upload profile exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user gender
  Future<Map<String, dynamic>> updateGender(String gender) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/gender'),
        headers: headers,
        body: jsonEncode({'gender': gender}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Failed to update gender'};
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Update gender exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Failed to get user profile'};
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Get user profile exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? state,
    int? age,
    String? jobTitle,
    String? bio,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final updateData = <String, dynamic>{};
      
      if (displayName != null) updateData['displayName'] = displayName;
      if (state != null) updateData['state'] = state;
      if (age != null) updateData['age'] = age;
      if (jobTitle != null) updateData['jobTitle'] = jobTitle;
      if (bio != null) updateData['bio'] = bio;

      final response = await http.patch(
        Uri.parse('$baseUrl/users/profile'),
        headers: headers,
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'message': errorData['message'] ?? 'Failed to update profile'};
      }
    } catch (e) {
      debugPrint('🔍 DEBUG: Update profile exception: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
} 
