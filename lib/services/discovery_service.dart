import '../models/user.dart';
import '../utils/api_service.dart';

class DiscoveryService {
  static const String baseUrl = 'https://nurse-mingle.com/api';
  
  // Main method used by the newer discovery screen - NO MOCK DATA FALLBACK
  static Future<List<User>> getDiscoverableUsers(Map<String, dynamic> filters) async {
    print('🔍 DISCOVERY_SERVICE: Getting discoverable users with filters: $filters');
    
    try {
      // Convert filters to query params
      final queryParams = <String, String>{};
      filters.forEach((key, value) {
        if (value != null) {
          queryParams[key] = value.toString();
        }
      });
      
      print('🔍 DISCOVERY_SERVICE: Calling /api/user/profiles with query params: $queryParams');
      final response = await ApiService.get('/api/user/profiles', queryParams: queryParams);
      
      print('🔍 DISCOVERY_SERVICE: Response: $response');
      
      if (response['success'] == true && response['data'] != null) {
        // Handle both array and object responses
        dynamic responseData = response['data'];
        List<dynamic> usersJson = [];
        
        if (responseData is List) {
          usersJson = responseData;
        } else if (responseData is Map && responseData['users'] != null) {
          usersJson = responseData['users'];
        } else if (responseData is Map && responseData['profiles'] != null) {
          usersJson = responseData['profiles'];
        } else {
          // If data structure is different, try to handle it
          print('🔍 DISCOVERY_SERVICE: Unexpected data structure: $responseData');
          usersJson = [];
        }
        
        print('🔍 DISCOVERY_SERVICE: Found ${usersJson.length} users from backend');
        
        List<User> users = [];
        for (var userJson in usersJson) {
          try {
            final user = User.fromJson(userJson);
            users.add(user);
          } catch (e) {
            print('⚠️ DISCOVERY_SERVICE: Failed to parse user: $e, JSON: $userJson');
            // Continue with other users instead of failing completely
          }
        }
        
        print('✅ DISCOVERY_SERVICE: Successfully parsed ${users.length} users');
        return users;
      } else {
        print('❌ DISCOVERY_SERVICE: API returned no data or failed');
        throw Exception('No users found or API error: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('💥 DISCOVERY_SERVICE: Exception: $e');
      throw Exception('Failed to load users: $e');
    }
  }
  
  static Future<List<User>> getUsers({
    int page = 1,
    int limit = 10,
    String? gender,
    int? minAge,
    int? maxAge,
    String? location,
  }) async {
    try {
      print('🔍 DISCOVERY_SERVICE: Getting users with pagination...');
      
      final response = await ApiService.get('/api/user/profiles', queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (gender != null) 'gender': gender,
        if (minAge != null) 'min_age': minAge.toString(),
        if (maxAge != null) 'max_age': maxAge.toString(),
        if (location != null) 'location': location,
      });
      
      if (response['success'] == true) {
        final List<dynamic> usersJson = response['data'] ?? [];
        List<User> users = usersJson.map((json) => User.fromJson(json)).toList();
        
        return users;
      } else {
        throw Exception(response['error'] ?? 'Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to load users: $e');
    }
  }
  
  static Future<bool> likeUser(String userId) async {
    try {
      final response = await ApiService.post('/api/user/like', {'user_id': userId});
      return response['success'] == true;
    } catch (e) {
      print('Error liking user: $e');
      throw Exception('Failed to like user: $e');
    }
  }
  
  static Future<bool> superLikeUser(String userId) async {
    try {
      final response = await ApiService.post('/api/user/super-like', {'user_id': userId});
      return response['success'] == true;
    } catch (e) {
      print('Error super liking user: $e');
      throw Exception('Failed to super like user: $e');
    }
  }
  
  static Future<bool> passUser(String userId) async {
    try {
      final response = await ApiService.post('/api/user/pass', {'user_id': userId});
      return response['success'] == true;
    } catch (e) {
      print('Error passing user: $e');
      throw Exception('Failed to pass on user: $e');
    }
  }

  static Future<bool> admireUser(String userId) async {
    try {
      final response = await ApiService.post('/api/user/admire', {'user_id': userId});
      return response['success'] == true;
    } catch (e) {
      print('Error admiring user: $e');
      throw Exception('Failed to admire user: $e');
    }
  }
  
  static Future<List<User>> getAdmirers({bool showBlurred = false}) async {
    try {
      final response = await ApiService.get('/api/user/admirers', queryParams: {
        'blurred': showBlurred.toString(),
      });
      
      if (response['success'] == true) {
        final List<dynamic> admirersJson = response['data'] ?? [];
        return admirersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to load admirers');
      }
    } catch (e) {
      print('Error fetching admirers: $e');
      throw Exception('Failed to load admirers: $e');
    }
  }
  
  static Future<List<User>> getMyAdmirers() async {
    try {
      final response = await ApiService.get('/api/user/my-admirers');
      
      if (response['success'] == true) {
        final List<dynamic> admirersJson = response['data'] ?? [];
        return admirersJson.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to load admirers');
      }
    } catch (e) {
      print('Error fetching my admirers: $e');
      throw Exception('Failed to load my admirers: $e');
    }
  }
} 
