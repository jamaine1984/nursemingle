import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../utils/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  
  // Usage tracking
  int _dailyLikes = 0;
  int _dailyMessages = 0;
  int _dailySuperLikes = 0;
  int _videoCallMinutes = 0;
  int _phoneCallMinutes = 0;
  int _giftPoints = 100;
  DateTime? _lastResetDate;
  
  // Subscription info
  String _subscriptionPlan = 'free';
  DateTime? _subscriptionExpiry;
  Map<String, dynamic> _subscriptionLimits = {};
  
  // Getters
  User? get user => _user;
  User? get currentUser => _user; // Add this getter
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  
  // Usage getters
  int get dailyLikes => _dailyLikes;
  int get dailyMessages => _dailyMessages;
  int get dailySuperLikes => _dailySuperLikes;
  int get videoCallMinutes => _videoCallMinutes;
  int get phoneCallMinutes => _phoneCallMinutes;
  int get giftPoints => _giftPoints;
  
  // Gift system getters
  bool get canSendPremiumGifts => isGoldSubscriber || isStarterSubscriber;
  String get currentPlan => _subscriptionPlan;
  
  // Gift points setter
  set giftPoints(int points) {
    _giftPoints = points;
    notifyListeners();
  }
  
  // Spend gift points
  void spendGiftPoints(int points) {
    if (_giftPoints >= points) {
      _giftPoints -= points;
      notifyListeners();
    }
  }
  
  // Use a like (increment daily like count)
  void useLike() {
    _dailyLikes++;
    notifyListeners();
  }
  
  // Subscription getters
  String get subscriptionPlan => _subscriptionPlan;
  DateTime? get subscriptionExpiry => _subscriptionExpiry;
  bool get isGoldSubscriber => _subscriptionPlan == 'gold' && 
    (_subscriptionExpiry?.isAfter(DateTime.now()) ?? false);
  bool get isStarterSubscriber => _subscriptionPlan == 'starter' && 
    (_subscriptionExpiry?.isAfter(DateTime.now()) ?? false);
  bool get isPlatinumSubscriber => _subscriptionPlan == 'platinum' && 
    (_subscriptionExpiry?.isAfter(DateTime.now()) ?? false);
  bool get isFreeUser => _subscriptionPlan == 'free' ||
    (_subscriptionExpiry?.isBefore(DateTime.now()) ?? true);
  
  bool get isPaidUser => !isFreeUser;
  
  // Admin/Dev bypass check
  bool get isAdminOrDev => _user?.email == 'jamaine@nurse-mingle.com' || _user?.email == 'koikes2021@gmail.com' || 
                           _user?.email.contains('@nurse-mingle.com') == true;
  
  // Feature access based on subscription plan (with admin bypass)
  // Removed duplicate canLiveStream - using the one with maxLiveStreamHours check
  bool get canUsePremiumGifts => isAdminOrDev || isGoldSubscriber || isPlatinumSubscriber;
  bool get hasUnlimitedLikes => isAdminOrDev || isGoldSubscriber || isPlatinumSubscriber;
  bool get hasUnlimitedSuperLikes => isAdminOrDev || isPlatinumSubscriber;
  bool get hasReadReceipts => isAdminOrDev || isGoldSubscriber || isPlatinumSubscriber;
  bool get hasVipBadge => isAdminOrDev || isPlatinumSubscriber;
  bool get hasAdvancedFilters => isAdminOrDev || isGoldSubscriber || isPlatinumSubscriber;
  

  
  // Usage limits based on subscription - Updated to match production backend
  int get maxDailyLikes {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 999999; // Unlimited
    if (isGoldSubscriber) return 100;
    if (isStarterSubscriber) return 50;
    return 20; // Free plan
  }
  
  int get maxDailyMessages {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 999999; // Unlimited
    if (isGoldSubscriber) return 200;
    if (isStarterSubscriber) return 50;
    return 10; // Free plan
  }
  
  int get maxDailySuperLikes {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 20;
    if (isGoldSubscriber) return 5;
    if (isStarterSubscriber) return 0;
    return 0; // Free plan
  }
  
  int get maxVideoCallMinutes {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 2000;
    if (isGoldSubscriber) return 500;
    if (isStarterSubscriber) return 100;
    return 0; // Free plan - no video calls
  }
  
  int get maxPhoneCallMinutes {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 2000;
    if (isGoldSubscriber) return 500;
    if (isStarterSubscriber) return 100;
    return 0; // Free plan - no phone calls
  }
  
  int get maxLiveStreamHours {
    if (isAdminOrDev) return 999999; // Unlimited for admin/dev
    if (isPlatinumSubscriber) return 200;
    if (isGoldSubscriber) return 90;
    if (isStarterSubscriber) return 20;
    return 0; // Free plan - no live streaming
  }
  
  // Usage checks (with admin bypass)
  bool get canLike => isAdminOrDev || _dailyLikes < maxDailyLikes;
  bool get canUseLikes => canLike; // Alias for compatibility
  bool get canMessage => isAdminOrDev || _dailyMessages < maxDailyMessages;
  bool get canSuperLike => isAdminOrDev || _dailySuperLikes < maxDailySuperLikes;
  bool get canVideoCall => isAdminOrDev || maxVideoCallMinutes > 0;
  bool get canPhoneCall => isAdminOrDev || maxPhoneCallMinutes > 0;
  bool get canLiveStream => isAdminOrDev || maxLiveStreamHours > 0;
  
  // Rewarded ads - unlimited for all plans
  bool get canWatchRewardedAds => true;
  
  // Watch rewarded ad and get rewards
  Future<bool> watchRewardedAd(String adType) async {
    try {
      print('🎬 AUTH_PROVIDER: Watching rewarded ad of type: $adType');
      
      // Call backend to track ad view
      final response = await ApiService.post('/api/rewards/watch-ad', {
        'adType': adType,
        'userId': _user?.id,
      });
      
      if (response['success'] == true) {
        print('✅ AUTH_PROVIDER: Rewarded ad watched successfully');
        
        // Apply rewards based on ad type
        switch (adType) {
          case 'free_gift_rewarded':
            // Give user ability to send 1 free gift
            break;
          case 'unlock_message':
            // Give user 1 extra message
            break;
          case 'unlock_like':
            // Give user 1 extra like
            break;
          case 'unlock_superlike':
            // Give user 1 extra superlike
            break;
        }
        
        await _saveUserData();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ AUTH_PROVIDER: Error watching rewarded ad: $e');
      return false;
    }
  }
  
  // Check if user can upgrade to a plan
  bool canUpgradeToStarter() => _subscriptionPlan == 'free';
  bool canUpgradeToGold() => _subscriptionPlan == 'free' || _subscriptionPlan == 'starter';
  bool canUpgradeToPlatinum() => _subscriptionPlan != 'platinum';
  
  // Remaining usage
  int get remainingLikes => maxDailyLikes - _dailyLikes;
  int get remainingMessages => maxDailyMessages - _dailyMessages;
  int get remainingSuperLikes => maxDailySuperLikes - _dailySuperLikes;
  int get remainingVideoMinutes => maxVideoCallMinutes - _videoCallMinutes;
  int get remainingPhoneMinutes => maxPhoneCallMinutes - _phoneCallMinutes;

  AuthProvider() {
    initialize();
  }

  // Initialize authentication state
  Future<void> initialize() async {
    try {
      // Check if user is authenticated
      final isAuth = await AuthService.isAuthenticated();
      
      if (isAuth) {
        // Get stored user data
        final userData = await AuthService.getStoredUserData();
        if (userData != null) {
          _user = User.fromJson(userData);
          _isAuthenticated = true;
        } else {
          // Try to get current user from API
          final response = await AuthService.getCurrentUser();
          if (response['success'] == true) {
            _user = User.fromJson(response['data']);
            _isAuthenticated = true;
          }
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await AuthService.login(email, password);
      
      if (response['success'] == true) {
        // Handle the user data - it might be in 'data.user' or directly in 'data'
        final userData = response['data']['user'] ?? response['data'];
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register method
  Future<bool> register(Map<String, dynamic> userData) async {
    print('[AUTH_PROVIDER] Starting registration with userData: $userData');
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('[AUTH_PROVIDER] Calling AuthService.register...');
      final response = await AuthService.register(userData);
      print('[AUTH_PROVIDER] AuthService.register response: $response');
      
      if (response['success'] == true) {
        print('[AUTH_PROVIDER] Registration successful, response data: ${response['data']}');
        // Handle the user data - it might be in 'data.user' or directly in 'data'
        final userData = response['data']['user'] ?? response['data'];
        print('[AUTH_PROVIDER] Creating user from userData: $userData');
        _user = User.fromJson(userData);
        _isAuthenticated = true;
        
        // Set default subscription plan to Free for new users
        _subscriptionPlan = 'free';
        _subscriptionExpiry = null;
        await _saveSubscriptionData();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print('[AUTH_PROVIDER] Registration failed: ${response['error']}');
        _error = response['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('[AUTH_PROVIDER] Registration exception: $e');
      print('[AUTH_PROVIDER] Stack trace: ${StackTrace.current}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await ApiService.logout();
      await _clearLocalData();
      
      _user = null;
      _error = null;
      _resetUsageData();
      _resetSubscriptionData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await ApiService.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await ApiService.updateProfile(profileData);
      if (response['success'] == true && response['data'] != null) {
        _user = User.fromJson(response['data']);
      }
      await _saveUserData();
      
      // Track profile update
      await ApiService.trackUsage('profile_update');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      
      // For development - update mock user if API fails
      if (e.toString().contains('Server returned HTML') || 
          e.toString().contains('Failed to parse server response') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException')) {
        
        if (_user != null) {
          // Update existing user with new profile data
          _user = User(
            id: _user!.id,
            email: _user!.email,
            firstName: _user!.firstName,
            lastName: _user!.lastName,
            displayName: profileData['display_name'] ?? _user!.displayName,
            age: profileData['age'] ?? _user!.age,
            gender: profileData['gender'] ?? _user!.gender,
            bio: profileData['bio'] ?? _user!.bio,
            location: profileData['location'] ?? _user!.location,
            city: profileData['city'] ?? _user!.city,
            profession: profileData['profession'] ?? _user!.profession,
            jobTitle: profileData['job_title'] ?? _user!.jobTitle,
            workLocation: profileData['work_location'] ?? _user!.workLocation,
            nursingSpecialty: profileData['nursing_specialty'] ?? _user!.nursingSpecialty,
            profileImageUrl: profileData['profile_image'] ?? _user!.profileImageUrl,
            interests: profileData['interests'] is List<String> 
                ? profileData['interests'] 
                : _user!.interests,
            preferences: _convertPreferencesToList(profileData['preferences']) ?? _user!.preferences,
            isOnline: _user!.isOnline,
            lastSeen: _user!.lastSeen,
            isVerified: _user!.isVerified,
            subscriptionPlan: _user!.subscriptionPlan,
            subscriptionExpiry: _user!.subscriptionExpiry,
            createdAt: _user!.createdAt,
            updatedAt: DateTime.now(),
          );
          
          await _saveUserData();
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add missing methods
  Future<void> checkAuthStatus() async {
    if (ApiService.isAuthenticated) {
      try {
        final response = await ApiService.getCurrentUser();
        if (response['success'] == true && response['data'] != null) {
          _user = User.fromJson(response['data']);
          _isAuthenticated = true;
        }
      } catch (e) {
        _isAuthenticated = false;
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<bool> checkVerificationStatus(String email) async {
    // Mock implementation - in production this would check email verification
    return true;
  }

  Future<void> sendVerificationEmail(String email) async {
    // Mock implementation - in production this would send verification email
    await Future.delayed(const Duration(seconds: 1));
  }

  // Usage tracking methods

  Future<void> useMessage() async {
    if (!canMessage) return;
    
    _dailyMessages++;
    await _saveUsageData();
    await ApiService.trackUsage('message_used', metadata: {'remaining': remainingMessages});
    notifyListeners();
  }

  Future<void> useSuperLike() async {
    if (!canSuperLike) return;
    
    _dailySuperLikes++;
    await _saveUsageData();
    await ApiService.trackUsage('super_like_used', metadata: {'remaining': remainingSuperLikes});
    notifyListeners();
  }

  Future<void> useVideoCallMinutes(int minutes) async {
    _videoCallMinutes += minutes;
    await _saveUsageData();
    await ApiService.trackUsage('video_call_used', metadata: {
      'minutes': minutes,
      'remaining': remainingVideoMinutes
    });
    notifyListeners();
  }

  Future<void> usePhoneCallMinutes(int minutes) async {
    _phoneCallMinutes += minutes;
    await _saveUsageData();
    await ApiService.trackUsage('phone_call_used', metadata: {
      'minutes': minutes,
      'remaining': remainingPhoneMinutes
    });
    notifyListeners();
  }

  // Rewarded ad methods to unlock extra usage
  Future<void> addExtraLikes(int count) async {
    _dailyLikes = (_dailyLikes - count).clamp(0, maxDailyLikes);
    await _saveUsageData();
    await ApiService.trackUsage('extra_likes_earned', metadata: {'count': count});
    notifyListeners();
  }

  Future<void> addExtraSuperLikes(int count) async {
    _dailySuperLikes = (_dailySuperLikes - count).clamp(0, maxDailySuperLikes);
    await _saveUsageData();
    await ApiService.trackUsage('extra_super_likes_earned', metadata: {'count': count});
    notifyListeners();
  }

  Future<void> addExtraMessages(int count) async {
    _dailyMessages = (_dailyMessages - count).clamp(0, maxDailyMessages);
    await _saveUsageData();
    await ApiService.trackUsage('extra_messages_earned', metadata: {'count': count});
    notifyListeners();
  }

  // Subscription management
  Future<void> purchaseSubscription(String planId, String purchaseToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await ApiService.purchaseSubscription(planId);
      await _loadSubscriptionData();
      
      // Track subscription purchase
      await ApiService.trackUsage('subscription_purchased', metadata: {'plan': planId});
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      return await ApiService.getSubscriptionPlans();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  // Daily reset functionality
  Future<void> checkAndResetDailyLimits() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastResetDate == null || _lastResetDate!.isBefore(today)) {
      await resetDailyLimits();
    }
  }

  Future<void> resetDailyLimits() async {
    _dailyLikes = 0;
    _dailyMessages = 0;
    _dailySuperLikes = 0;
    _lastResetDate = DateTime.now();
    
    await _saveUsageData();
    await ApiService.trackUsage('daily_limits_reset');
    notifyListeners();
  }

  // Admin check
  Future<bool> checkAdminStatus() async {
    try {
      final response = await ApiService.isAdmin();
      return response['isAdmin'] == true;
    } catch (e) {
      return false;
    }
  }

  // Data persistence methods
  Future<void> _loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    _dailyLikes = prefs.getInt('daily_likes') ?? 0;
    _dailyMessages = prefs.getInt('daily_messages') ?? 0;
    _dailySuperLikes = prefs.getInt('daily_super_likes') ?? 0;
    _videoCallMinutes = prefs.getInt('video_call_minutes') ?? 0;
    _phoneCallMinutes = prefs.getInt('phone_call_minutes') ?? 0;
    
    final lastResetString = prefs.getString('last_reset_date');
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }
    
    // Check if we need to reset daily limits
    await checkAndResetDailyLimits();
  }

  Future<void> _saveUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_likes', _dailyLikes);
    await prefs.setInt('daily_messages', _dailyMessages);
    await prefs.setInt('daily_super_likes', _dailySuperLikes);
    await prefs.setInt('video_call_minutes', _videoCallMinutes);
    await prefs.setInt('phone_call_minutes', _phoneCallMinutes);
    
    if (_lastResetDate != null) {
      await prefs.setString('last_reset_date', _lastResetDate!.toIso8601String());
    }
  }

  Future<void> _loadSubscriptionData() async {
    try {
      final subscriptionData = await ApiService.getMySubscription();
      _subscriptionPlan = subscriptionData['plan'] ?? 'free';
      
      if (subscriptionData['expiry'] != null) {
        _subscriptionExpiry = DateTime.parse(subscriptionData['expiry']);
      }
      
      _subscriptionLimits = subscriptionData['limits'] ?? {};
      
      // Update user subscription info
      if (_user != null) {
        _user = _user!.copyWith(
          subscriptionPlan: _subscriptionPlan,
          subscriptionExpiry: _subscriptionExpiry,
        );
      }
    } catch (e) {
      // Handle error silently, use defaults
      _subscriptionPlan = 'free';
      _subscriptionExpiry = null;
      _subscriptionLimits = {};
    }
  }

  Future<void> _saveSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('subscription_plan', _subscriptionPlan);
      if (_subscriptionExpiry != null) {
        await prefs.setString('subscription_expiry', _subscriptionExpiry!.toIso8601String());
      } else {
        await prefs.remove('subscription_expiry');
      }
    } catch (e) {
      print('Error saving subscription data: $e');
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      await prefs.setString('user_data', _user!.toJson().toString());
    }
  }

  Future<void> _clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('daily_likes');
    await prefs.remove('daily_messages');
    await prefs.remove('daily_super_likes');
    await prefs.remove('video_call_minutes');
    await prefs.remove('phone_call_minutes');
    await prefs.remove('last_reset_date');
  }

  void _resetUsageData() {
    _dailyLikes = 0;
    _dailyMessages = 0;
    _dailySuperLikes = 0;
    _videoCallMinutes = 0;
    _phoneCallMinutes = 0;
    _lastResetDate = null;
  }

  void _resetSubscriptionData() {
    _subscriptionPlan = 'free';
    _subscriptionExpiry = null;
    _subscriptionLimits = {};
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh user data from server
  Future<void> refreshUser() async {
    if (!isAuthenticated) return;
    
    try {
      final response = await ApiService.getCurrentUser();
      if (response['success'] == true && response['data'] != null) {
        _user = User.fromJson(response['data']);
      }
      await _loadSubscriptionData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update current user data and persist to storage
  void updateCurrentUser(User updatedUser) {
    _user = updatedUser;
    _saveUserData(); // Persist to local storage
    notifyListeners();
    print('[AUTH_PROVIDER] User data updated: ${updatedUser.firstName} ${updatedUser.lastName}');
  }

  // Update subscription plan
  void updateSubscriptionPlan(String newPlan) {
    _subscriptionPlan = newPlan;
    _resetUsageData(); // Reset usage counters when plan changes
    _saveSubscriptionData();
    notifyListeners();
    print('[AUTH_PROVIDER] Subscription plan updated to: $newPlan');
  }

  // Helper method to convert preferences Map to List
  List<String>? _convertPreferencesToList(dynamic preferences) {
    if (preferences == null) return null;
    
    if (preferences is Map<String, bool>) {
      return preferences.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    }
    
    if (preferences is List<String>) {
      return preferences;
    }
    
    return null;
  }
  
  // Upgrade subscription plan
  Future<bool> upgradePlan(String planId) async {
    try {
      print('🔄 AUTH_PROVIDER: Upgrading to plan: $planId');
      
      final response = await ApiService.post('/api/subscription/upgrade', {
        'plan': planId,
        'userId': _user?.id,
      });
      
      if (response['success'] == true) {
        print('✅ AUTH_PROVIDER: Plan upgraded successfully');
        
        // Update local subscription data
        _subscriptionPlan = planId;
        
        // Set expiry based on plan
        if (planId != 'free') {
          _subscriptionExpiry = DateTime.now().add(const Duration(days: 30));
        } else {
          _subscriptionExpiry = null;
        }
        
        // Update user data
        if (_user != null) {
          _user = _user!.copyWith(
            subscriptionPlan: planId,
            subscriptionExpiry: _subscriptionExpiry,
          );
        }
        
        await _saveSubscriptionData();
        notifyListeners();
        
        // Track plan upgrade
        await ApiService.trackUsage('plan_upgraded', metadata: {'plan': planId});
        
        return true;
      }
      
      print('❌ AUTH_PROVIDER: Plan upgrade failed');
      return false;
    } catch (e) {
      print('❌ AUTH_PROVIDER: Error upgrading plan: $e');
      return false;
    }
  }
} 
