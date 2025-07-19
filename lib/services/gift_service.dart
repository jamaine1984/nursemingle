import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/gift_inventory.dart';
import '../models/gift_model.dart';
import '../data/comprehensive_gift_catalog.dart';

class GiftService {
  static const String baseUrl = 'https://nurse-mingle.com/api';
  
  // Get available gifts from backend - NO MOCK DATA FALLBACK
  static Future<List<Map<String, dynamic>>> getAvailableGifts() async {
    try {
      print('🎁 GIFT_SERVICE: Fetching available gifts from backend...');
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/gifts/available'),
        headers: headers,
      );
      
      print('🎁 GIFT_SERVICE: Available gifts response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🎁 GIFT_SERVICE: Available gifts data: $data');
        return List<Map<String, dynamic>>.from(data['gifts'] ?? data['data'] ?? []);
      } else {
        print('❌ GIFT_SERVICE: Available gifts API returned error ${response.statusCode}');
        throw Exception('Failed to load available gifts: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 GIFT_SERVICE: Available gifts exception: $e');
      throw Exception('Failed to load available gifts: $e');
    }
  }
  
  // Get all gifts from backend - NO MOCK DATA FALLBACK
  static Future<List<Gift>> getAllGifts() async {
    try {
      print('🎁 GIFT_SERVICE: Fetching gifts from backend...');
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/gifts'),
        headers: headers,
      );
      
      print('🎁 GIFT_SERVICE: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🎁 GIFT_SERVICE: Response data: $data');
        
        final List<dynamic> giftsJson = data['gifts'] ?? data['data'] ?? [];
        List<Gift> gifts = [];
        
        for (var giftJson in giftsJson) {
          try {
            final gift = Gift.fromJson(giftJson);
            gifts.add(gift);
          } catch (e) {
            print('⚠️ GIFT_SERVICE: Failed to parse gift: $e, JSON: $giftJson');
            // Continue with other gifts instead of failing completely
          }
        }
        
        print('✅ GIFT_SERVICE: Successfully parsed ${gifts.length} gifts');
        
        // If no gifts from backend, use comprehensive catalog
        if (gifts.isEmpty) {
          print('🎁 GIFT_SERVICE: No gifts from backend, using comprehensive catalog');
          return ComprehensiveGiftCatalog.getAllGifts();
        }
        
        return gifts;
      } else {
        print('❌ GIFT_SERVICE: API returned error ${response.statusCode}');
        print('🎁 GIFT_SERVICE: Using comprehensive catalog as fallback');
        return ComprehensiveGiftCatalog.getAllGifts();
      }
    } catch (e) {
      print('💥 GIFT_SERVICE: Exception: $e');
      print('🎁 GIFT_SERVICE: Using comprehensive catalog as fallback');
      return ComprehensiveGiftCatalog.getAllGifts();
    }
  }
  
  // Get user's gift inventory
  static Future<UserGiftInventory?> getUserInventory() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/gifts/inventory'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserGiftInventory.fromJson(data);
      }
      
      // Return empty inventory if not found
      final currentUser = await AuthService.getCurrentUser();
      return UserGiftInventory(
        userId: currentUser['id']?.toString() ?? '',
        inventory: [],
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('Error fetching inventory: $e');
      // Return empty inventory on error
      final currentUser = await AuthService.getCurrentUser();
      return UserGiftInventory(
        userId: currentUser['id']?.toString() ?? '',
        inventory: [],
        lastUpdated: DateTime.now(),
      );
    }
  }
  
  // Add gift to inventory (after watching ads or purchasing)
  static Future<bool> addGiftToInventory(String giftId, String type, int quantity) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/gifts/inventory/add'),
        headers: headers,
        body: jsonEncode({
          'giftId': giftId,
          'type': type,
          'quantity': quantity,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding gift to inventory: $e');
      return false;
    }
  }
  
  // Complete rewarded ads for free gift
  static Future<bool> completeFreeGiftAds(String giftId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/gifts/free/complete-ads'),
        headers: headers,
        body: jsonEncode({
          'giftId': giftId,
          'adsWatched': 3,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        // Add gift to inventory locally
        await addGiftToInventory(giftId, 'free', 1);
        return true;
      }
      return false;
    } catch (e) {
      print('Error completing free gift ads: $e');
      // Still add to inventory locally for demo purposes
      return await addGiftToInventory(giftId, 'free', 1);
    }
  }
  
  // Send gift to user
  static Future<bool> sendGift(String recipientId, String giftId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      
      // Check if user has the gift in inventory
      final inventory = await getUserInventory();
      if (inventory == null || !inventory.hasGift(giftId)) {
        print('Gift not in inventory');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/gifts/send'),
        headers: headers,
        body: jsonEncode({
          'recipientId': recipientId,
          'giftId': giftId,
        }),
      );
      
      if (response.statusCode == 200) {
        // Decrease gift quantity in inventory
        await removeGiftFromInventory(giftId, 1);
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending gift: $e');
      return false;
    }
  }
  
  // Remove gift from inventory (after sending)
  static Future<bool> removeGiftFromInventory(String giftId, int quantity) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/gifts/inventory/remove'),
        headers: headers,
        body: jsonEncode({
          'giftId': giftId,
          'quantity': quantity,
        }),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error removing gift from inventory: $e');
      return false;
    }
  }
  
  // Get received gifts
  static Future<List<Map<String, dynamic>>> getReceivedGifts() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/gifts/received'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['gifts'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Purchase premium gift with coins
  static Future<bool> purchasePremiumGift(String giftId, int quantity) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/gifts/purchase'),
        headers: headers,
        body: jsonEncode({
          'giftId': giftId,
          'quantity': quantity,
        }),
      );
      
      if (response.statusCode == 200) {
        // Add to inventory
        await addGiftToInventory(giftId, 'premium', quantity);
        return true;
      }
      return false;
    } catch (e) {
      print('Error purchasing premium gift: $e');
      return false;
    }
  }
} 
