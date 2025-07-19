import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../api_config.dart' as config;

class AuthService {
  static const String baseUrl = config.baseUrl;
  
  // Production test accounts for easy testing
  static const List<Map<String, String>> testAccounts = [
    {
      'email': 'sarah.nurse@test.com',
      'password': 'test123456',
      'name': 'Sarah Johnson',
      'role': 'Registered Nurse'
    },
    {
      'email': 'mike.doctor@test.com', 
      'password': 'test123456',
      'name': 'Dr. Mike Wilson',
      'role': 'Emergency Medicine'
    },
    {
      'email': 'lisa.admin@test.com',
      'password': 'test123456', 
      'name': 'Lisa Chen',
      'role': 'Nurse Practitioner'
    }
  ];
  
  // Debug logging helper
  static void _debugLog(String message) {
    if (kDebugMode) {
      print('[AUTH_SERVICE] $message');
    }
  }
  
  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    _debugLog('Attempting login for: $email');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signin'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      _debugLog('Login response status: ${response.statusCode}');
      _debugLog('Login response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html') || 
          response.body.trim().startsWith('<html')) {
        _debugLog('ERROR: Server returned HTML instead of JSON');
        return {
          'success': false, 
          'error': 'Server returned HTML instead of JSON. Check if API endpoint is correct: $baseUrl/api/auth/signin'
        };
      }
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          _debugLog('Login success data: $data');
          if (data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', data['token']);
            await prefs.setString('user_data', jsonEncode(data['user']));
            _debugLog('Login successful - token saved');
          }
          // Return data in the format expected by the app
          return {
            'success': true,
            'data': {
              'token': data['token'],
              'user': data['user'],
              'message': data['message']
            }
          };
        } catch (jsonError) {
          _debugLog('ERROR: Invalid JSON response - $jsonError');
          return {
            'success': false, 
            'error': 'Invalid JSON response from server: $jsonError'
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _debugLog('Login failed: ${errorData['message']}');
          return {'success': false, 'error': errorData['message'] ?? 'Login failed'};
        } catch (jsonError) {
          _debugLog('ERROR: Server error ${response.statusCode} - ${response.body}');
          return {
            'success': false, 
            'error': 'Server error (${response.statusCode}): ${response.body}'
          };
        }
      }
    } catch (e) {
      _debugLog('ERROR: Network error - $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
  
  // Register method (updated from signUp to match backend)
  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _debugLog('Starting registration method...');
    _debugLog('User data received: $userData');
    _debugLog('API endpoint: $baseUrl/api/auth/signup');
    
    try {
      _debugLog('Making HTTP POST request...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': userData['email'],
          'password': userData['password'],
          'firstName': userData['first_name'],
          'lastName': userData['last_name'],
        }),
      );
      
      _debugLog('Register response status: ${response.statusCode}');
      _debugLog('Register response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      
      // Check if response is HTML instead of JSON
      if (response.body.trim().startsWith('<!DOCTYPE html') || 
          response.body.trim().startsWith('<html')) {
        _debugLog('ERROR: Server returned HTML instead of JSON');
        return {
          'success': false, 
          'error': 'Server returned HTML instead of JSON. Check if API endpoint is correct: $baseUrl/api/auth/signup'
        };
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          _debugLog('Registration success data: $data');
          if (data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', data['token']);
            await prefs.setString('user_data', jsonEncode(data['user']));
            _debugLog('Registration successful - token saved');
          }
          // Return data in the format expected by the app
          return {
            'success': true, 
            'data': {
              'token': data['token'],
              'user': data['user'],
              'message': data['message']
            }
          };
        } catch (jsonError) {
          _debugLog('ERROR: Invalid JSON response - $jsonError');
          _debugLog('Response body: ${response.body}');
          return {
            'success': false, 
            'error': 'Invalid JSON response from server: $jsonError'
          };
        }
      } else {
        _debugLog('Registration failed with status: ${response.statusCode}');
        _debugLog('Raw response body: ${response.body}');
        
        try {
          final errorData = jsonDecode(response.body);
          _debugLog('Parsed error data: $errorData');
          return {'success': false, 'error': errorData['message'] ?? errorData['error'] ?? 'Registration failed'};
        } catch (jsonError) {
          _debugLog('Error parsing response: $jsonError');
          return {'success': false, 'error': 'Server error ${response.statusCode}: ${response.body}'};
        }
      }
    } catch (e) {
      _debugLog('ERROR: Network error - $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
  
  // Legacy signUp method for backwards compatibility
  static Future<Map<String, dynamic>> signUp(Map<String, dynamic> userData) async {
    return register(userData);
  }
  
  // Logout method
  static Future<Map<String, dynamic>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        
        // Clear local storage regardless of API response
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
        
        return {'success': true};
      } else {
        return {'success': false, 'error': 'No auth token found'};
      }
    } catch (e) {
      // Still clear local storage on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get current user
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        return {'success': false, 'error': 'No auth token found'};
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': 'Failed to get user data'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return token != null;
    } catch (e) {
      return false;
    }
  }
  
  // Get stored user data
  static Future<Map<String, dynamic>?> getStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get auth headers with token
  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
} 
