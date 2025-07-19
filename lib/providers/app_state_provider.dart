import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/gift_model.dart';
import '../models/live_stream.dart';
import '../models/message.dart';
import '../utils/api_service.dart';

class AppStateProvider with ChangeNotifier {
  // Discovery state
  List<User> _availableProfiles = [];
  final List<User> _likedProfiles = [];
  final List<User> _dislikedProfiles = [];
  final List<User> _superLikedProfiles = [];
  bool _isLoadingProfiles = false;
  int _currentProfileIndex = 0;
  
  // Admirers state
  List<User> _admirers = [];
  List<User> _myAdmirers = [];
  final bool _isLoadingAdmirers = false;
  
  // Gifts state
  List<Gift> _availableGifts = [];
  final List<Gift> _myGifts = [];
  final List<Gift> _giftInventory = []; // User's purchased gifts
  final List<Gift> _receivedGifts = [];
  final List<Gift> _sentGifts = [];
  final bool _isLoadingGifts = false;
  
  // Live streams state
  List<LiveStream> _liveStreams = [];
  final bool _isLoadingStreams = false;
  
  // Messages state
  List<Map<String, dynamic>> _conversations = [];
  final Map<String, List<Message>> _conversationMessages = {};
  final bool _isLoadingMessages = false;
  
  // Search/Filter state
  String? _genderFilter;
  int? _minAgeFilter;
  int? _maxAgeFilter;
  String? _countryFilter;
  String? _professionFilter;
  double? _maxDistanceFilter;
  
  // Notifications
  final List<String> _notifications = [];
  
  // Error handling
  String? _error;
  
  // Getters - Discovery
  List<User> get availableProfiles => _availableProfiles;
  List<User> get likedProfiles => _likedProfiles;
  List<User> get dislikedProfiles => _dislikedProfiles;
  List<User> get superLikedProfiles => _superLikedProfiles;
  bool get isLoadingProfiles => _isLoadingProfiles;
  int get currentProfileIndex => _currentProfileIndex;
  User? get currentProfile => _availableProfiles.isNotEmpty && _currentProfileIndex < _availableProfiles.length
      ? _availableProfiles[_currentProfileIndex]
      : null;
  
  // Getters - Admirers
  List<User> get admirers => _admirers;
  List<User> get myAdmirers => _myAdmirers;
  bool get isLoadingAdmirers => _isLoadingAdmirers;
  
  // Getters - Gifts
  List<Gift> get availableGifts => _availableGifts;
  List<Gift> get gifts => _availableGifts; // Alias for compatibility
  List<Gift> get myGifts => _myGifts;
  List<Gift> get giftInventory => _giftInventory;
  List<Gift> get receivedGifts => _receivedGifts;
  List<Gift> get sentGifts => _sentGifts;
  bool get isLoadingGifts => _isLoadingGifts;
  
  // Getters - Live streams
  List<LiveStream> get liveStreams => _liveStreams;
  bool get isLoadingStreams => _isLoadingStreams;
  
  // Getters - Messages
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoadingMessages => _isLoadingMessages;
  
  // Getters - Filters
  String? get genderFilter => _genderFilter;
  int? get minAgeFilter => _minAgeFilter;
  int? get maxAgeFilter => _maxAgeFilter;
  String? get countryFilter => _countryFilter;
  String? get professionFilter => _professionFilter;
  double? get maxDistanceFilter => _maxDistanceFilter;
  
  // Getters - Notifications
  List<String> get notifications => _notifications;
  String? get error => _error;

  // Discovery methods
  Future<void> loadDiscoverProfiles({bool refresh = false}) async {
    if (_isLoadingProfiles && !refresh) return;
    
    _isLoadingProfiles = true;
    _error = null;
    notifyListeners();
    
    try {
      // Load profiles from backend API
      final response = await ApiService.getDiscoveryProfiles();
      
      if (response['success'] == true) {
        final List<dynamic> profilesData = response['data'] ?? [];
        if (profilesData.isNotEmpty) {
          _availableProfiles = profilesData.map((data) => User.fromJson(data)).toList();
        } else {
          // No profiles available - show empty state
          _availableProfiles = [];
        }
      } else {
        // Handle API error - don't show error to user, just empty state
        print('⚠️ APP_STATE: API returned error: ${response['error']}');
        _error = null; // Don't show error to user
        _availableProfiles = [];
      }
      
      _isLoadingProfiles = false;
      notifyListeners();
    } catch (e) {
      print('💥 APP_STATE: Exception loading profiles: $e');
      _error = null; // Don't show error to user, just empty state
      _isLoadingProfiles = false;
      _availableProfiles = [];
      notifyListeners();
    }
  }

  Future<void> likeProfile(User profile) async {
    try {
      await ApiService.likeProfile(profile.id);
      
      // Remove from available profiles
      _availableProfiles.removeWhere((p) => p.id == profile.id);
      
      await ApiService.trackUsage('profile_liked', metadata: {
        'profile_id': profile.id
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> admireProfile(User profile) async {
    try {
      await ApiService.admireProfile(profile.id);
      
      // Remove from available profiles
      _availableProfiles.removeWhere((p) => p.id == profile.id);
      
      await ApiService.trackUsage('profile_admired', metadata: {
        'profile_id': profile.id
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> dislikeProfile(User profile) async {
    try {
      await ApiService.dislikeProfile(profile.id);
      
      // Remove from available profiles
      _availableProfiles.removeWhere((p) => p.id == profile.id);
      
      await ApiService.trackUsage('profile_disliked', metadata: {
        'profile_id': profile.id
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> superLikeProfile(User profile) async {
    try {
      await ApiService.superLikeUser(profile.id);
      
      _superLikedProfiles.add(profile);
      _removeCurrentProfile();
      
      await ApiService.trackUsage('profile_super_liked', metadata: {
        'profile_id': profile.id,
        'total_super_likes': _superLikedProfiles.length
      });
      
      _addNotification('Super liked ${profile.name}! ⭐');
      
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void _removeCurrentProfile() {
    if (_availableProfiles.isNotEmpty && _currentProfileIndex < _availableProfiles.length) {
      _availableProfiles.removeAt(_currentProfileIndex);
      
      // Adjust index if needed
      if (_currentProfileIndex >= _availableProfiles.length && _availableProfiles.isNotEmpty) {
        _currentProfileIndex = _availableProfiles.length - 1;
      }
      
      // Load more profiles if running low
      if (_availableProfiles.length < 3) {
        loadDiscoverProfiles();
      }
    }
  }

  // Admirers methods
  Future<void> loadAdmirers({bool showBlurred = false}) async {
    try {
      final response = await ApiService.getAdmirers(showBlurred: showBlurred);
      final myAdmirersResponse = await ApiService.getMyAdmirers();
      
      if (response['success'] == true && response['data'] != null) {
        _admirers = (response['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      
      if (myAdmirersResponse['success'] == true && myAdmirersResponse['data'] != null) {
        _myAdmirers = (myAdmirersResponse['data'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      }
      
      await ApiService.trackUsage('admirers_loaded', metadata: {
        'admirers_count': _admirers.length,
        'my_admirers_count': _myAdmirers.length,
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Gifts methods
  Future<void> claimFreeGiftWithAds(String giftId) async {
    try {
      final gift = _availableGifts.firstWhere((g) => g.id == giftId);
      
      if (gift.price != 0) {
        throw Exception('This is not a free gift');
      }
      
      // Show rewarded ad requirement dialog
      _showRewardedAdDialog(giftId);
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _showRewardedAdDialog(String giftId) {
    // This will be called from the UI to show the rewarded ad dialog
    // The UI will handle showing 3 ads sequentially
  }

  Future<void> completeRewardedAdsForGift(String giftId) async {
    try {
      // Notify backend that rewarded ads were watched
      final response = await ApiService.completeRewardedAd('free_gift_unlock', metadata: {
        'gift_id': giftId,
        'ads_watched': 3,
      });
      
      if (response['success'] == true) {
        // Claim the free gift from backend
        final claimResponse = await ApiService.claimFreeGift(giftId);
        
        if (claimResponse['success'] == true) {
          // Add to inventory
          final gift = _availableGifts.firstWhere((g) => g.id == giftId);
          _giftInventory.add(gift);
          
          _addNotification('Free gift claimed! Added to inventory 🎁');
          notifyListeners();
        } else {
          throw Exception(claimResponse['error'] ?? 'Failed to claim gift');
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to complete rewarded ads');
      }
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> purchaseGift(String giftId) async {
    try {
      final gift = _availableGifts.firstWhere((g) => g.id == giftId);
      
      // For free gifts, require watching 3 rewarded ads
      if (gift.price == 0) {
        await claimFreeGiftWithAds(giftId);
        return;
      }
      
      // For paid gifts, process payment
      final response = await ApiService.purchaseGift(giftId);
      
      if (response['success'] == true) {
        // Add to inventory
        _giftInventory.add(gift);
        
        await ApiService.trackUsage('gift_purchased', metadata: {
          'gift_id': giftId,
          'price': gift.price
        });
        
        _addNotification('Gift purchased! Added to inventory 🎁');
        notifyListeners();
      } else {
        throw Exception(response['error'] ?? 'Failed to purchase gift');
      }
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> claimFreeGifts() async {
    try {
      await ApiService.claimFreeGifts();
      
      // Refresh gifts to show new inventory
      await loadGifts();
      
      await ApiService.trackUsage('free_gifts_claimed');
      
      _addNotification('Free gifts claimed! 🎁');
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load gifts from API
  Future<void> loadGifts() async {
    try {
      final response = await ApiService.get('/api/gifts');
      if (response['success'] == true && response['data'] != null) {
        _availableGifts = List<Gift>.from(response['data'].map((data) => Gift.fromJson(data)));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading gifts: $e');
    }
  }

  // Live streams methods
  Future<void> loadLiveStreams() async {
    try {
      final response = await ApiService.getLiveStreams();
      
      if (response['success'] == true && response['data'] != null) {
        _liveStreams = (response['data'] as List)
            .map((json) => LiveStream.fromJson(json))
            .toList();
      }
      
      await ApiService.trackUsage('live_streams_loaded', metadata: {
        'count': _liveStreams.length,
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<LiveStream?> createLiveStream(String title, String description) async {
    try {
      final response = await ApiService.createLiveStream(title, description);
      
      if (response['success'] == true && response['data'] != null) {
        final stream = LiveStream.fromJson(response['data']);
        _liveStreams.insert(0, stream);
        
        await ApiService.trackUsage('live_stream_created', metadata: {
          'stream_id': stream.id,
          'title': title,
        });
        
        notifyListeners();
        return stream;
      }
      
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> joinLiveStream(String streamId) async {
    try {
      final joinData = await ApiService.joinLiveStream(streamId);
      
      await ApiService.trackUsage('live_stream_joined', metadata: {
        'stream_id': streamId
      });
      
      return joinData;
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Messages methods
  Future<void> loadConversations() async {
    try {
      final response = await ApiService.getConversations();
      
      if (response['success'] == true && response['data'] != null) {
        _conversations = List<Map<String, dynamic>>.from(response['data']);
      }
      
      await ApiService.trackUsage('conversations_loaded', metadata: {
        'count': _conversations.length,
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId) async {
    try {
      final response = await ApiService.getMessagesForConversation(conversationId);
      if (response['success'] == true && response['data'] != null) {
        final messages = (response['data'] as List)
            .map((json) => Message.fromJson(json))
            .toList();
        _conversationMessages[conversationId] = messages;
      }
      
      await ApiService.trackUsage('messages_loaded', metadata: {
        'conversation_id': conversationId,
        'count': _conversationMessages[conversationId]?.length ?? 0,
      });
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String recipientId, String content) async {
    try {
      final response = await ApiService.sendMessage(recipientId, content);
      
      // Add to local messages if conversation exists
      final conversationId = _getConversationId(recipientId);
      if (conversationId != null && _conversationMessages[conversationId] != null && response['data'] != null) {
        final message = Message.fromJson(response['data']);
        _conversationMessages[conversationId]!.add(message);
      }
      
      await ApiService.trackUsage('message_sent', metadata: {
        'recipient_id': recipientId,
        'content_length': content.length
      });
      
      notifyListeners();
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String? _getConversationId(String recipientId) {
    for (final conversation in _conversations) {
      if (conversation['participants'].contains(recipientId)) {
        return conversation['id'];
      }
    }
    return null;
  }

  List<Message> getConversationMessages(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  // Filter methods
  void setGenderFilter(String? gender) {
    _genderFilter = gender;
    notifyListeners();
  }

  void setAgeFilter(int? minAge, int? maxAge) {
    _minAgeFilter = minAge;
    _maxAgeFilter = maxAge;
    notifyListeners();
  }

  void setCountryFilter(String? country) {
    _countryFilter = country;
    notifyListeners();
  }

  void setProfessionFilter(String? profession) {
    _professionFilter = profession;
    notifyListeners();
  }

  void setDistanceFilter(double? maxDistance) {
    _maxDistanceFilter = maxDistance;
    notifyListeners();
  }

  void clearFilters() {
    _genderFilter = null;
    _minAgeFilter = null;
    _maxAgeFilter = null;
    _countryFilter = null;
    _professionFilter = null;
    _maxDistanceFilter = null;
    notifyListeners();
  }

  bool _hasFiltersApplied() {
    return _genderFilter != null ||
        _minAgeFilter != null ||
        _maxAgeFilter != null ||
        _countryFilter != null ||
        _professionFilter != null ||
        _maxDistanceFilter != null;
  }

  // Notification methods
  void _addNotification(String message) {
    _notifications.add(message);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // Match generation (mock for now, would come from backend)
  void generateMatch() {
    _addNotification('It\'s a match! 🎉');
  }

  // Error handling
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDiscoverProfiles(refresh: true),
      loadAdmirers(),
      loadGifts(),
      loadLiveStreams(),
      loadConversations(),
    ]);
  }

  // Initialize app state
  Future<void> initialize() async {
    try {
      await Future.wait([
        loadDiscoverProfiles(refresh: true),
        loadGifts(),
        loadLiveStreams(),
        loadConversations(),
      ]);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 
