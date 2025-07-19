import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/discovery_service.dart';
import '../../models/user.dart';
import '../../utils/app_colors.dart';
import '../../widgets/swipe_card.dart';
import '../../widgets/profile_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<User> _discoveredUsers = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _viewedOwnProfile = {}; // Track if user has seen their own profile
  
  // Filter properties
  RangeValues _ageRange = const RangeValues(22, 65);
  double _maxDistance = 50.0;
  String? _selectedSpecialty;
  String? _selectedGender;
  bool _verifiedOnly = false;
  bool _onlineOnly = false;

  final List<String> _nursingSpecialties = [
    'All Specialties',
    'Emergency Nursing',
    'ICU Nursing',
    'Pediatric Nursing',
    'Surgical Nursing',
    'Medical-Surgical Nursing',
    'Psychiatric Nursing',
    'Oncology Nursing',
    'Cardiac Nursing',
    'Other'
  ];

  final List<String> _genderOptions = [
    'All Genders',
    'Male',
    'Female',
    'Non-binary'
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 DISCOVERY_SCREEN: Screen initialized');
    _loadDiscoveredUsers();
  }

  Future<void> _loadDiscoveredUsers() async {
    print('🔍 DISCOVERY_SCREEN: Loading discoverable users...');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filters = _buildFilters();
      print('🔍 DISCOVERY_SCREEN: Using filters: $filters');
      
      final users = await DiscoveryService.getDiscoverableUsers(filters);
      print('🔍 DISCOVERY_SCREEN: Loaded ${users.length} users');
      
      // Log first few users for debugging
      for (int i = 0; i < users.length && i < 3; i++) {
        final user = users[i];
        print('🔍 DISCOVERY_SCREEN: User ${i + 1}: ${user.firstName} ${user.lastName} (ID: ${user.id})');
      }
      
      setState(() {
        _discoveredUsers = users;
        _isLoading = false;
      });
      
      print('✅ DISCOVERY_SCREEN: Successfully loaded ${users.length} users');
    } catch (e) {
      print('❌ DISCOVERY_SCREEN: Error loading users: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildFilters() {
    return {
      'minAge': _ageRange.start.round(),
      'maxAge': _ageRange.end.round(),
      'maxDistance': _maxDistance.round(),
      if (_selectedSpecialty != null && _selectedSpecialty != 'All Specialties')
        'nursingSpecialty': _selectedSpecialty,
      if (_selectedGender != null && _selectedGender != 'All Genders')
        'gender': _selectedGender,
      'verifiedOnly': _verifiedOnly,
      'onlineOnly': _onlineOnly,
    };
  }

  bool _isOwnProfile(User user) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return user.id == authProvider.user?.id || 
           user.id == 'current_user' ||
           user.firstName == 'You';
  }

  void _handleTap(User user) {
    print('👆 DISCOVERY_SCREEN: Card tapped for ${user.firstName} ${user.lastName}');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(user: user),
      ),
    );
  }

  Future<void> _handleLike(User user) async {
    print('❤️ DISCOVERY_SCREEN: User liked ${user.firstName} ${user.lastName} (ID: ${user.id})');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Handle user's own profile
    if (_isOwnProfile(user)) {
      print('❤️ DISCOVERY_SCREEN: User liked their own profile');
      _viewedOwnProfile.add(user.id);
      setState(() {
        _discoveredUsers.removeWhere((u) => u.id == user.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Great! Your profile looks good. Other users will see this when they discover you!'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (!authProvider.canUseLikes) {
      print('❌ DISCOVERY_SCREEN: Like blocked - reached daily limit');
      _showUpgradeDialog('You\'ve reached your daily like limit. Upgrade to premium for unlimited likes!');
      return;
    }

    try {
      print('❤️ DISCOVERY_SCREEN: Sending like request to backend...');
      final success = await DiscoveryService.likeUser(user.id);
      if (!mounted) return;
      
      if (success) {
        print('✅ DISCOVERY_SCREEN: Like successful');
        authProvider.useLike();
        
        setState(() {
          _discoveredUsers.removeWhere((u) => u.id == user.id);
        });
        
        print('💳 DISCOVERY_SCREEN: Card removed. ${_discoveredUsers.length} cards remaining');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You liked ${user.firstName}!'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ DISCOVERY_SCREEN: Like failed - backend returned false');
      }
    } catch (e) {
      print('💥 DISCOVERY_SCREEN: Like exception: $e');
      _showError('Failed to like user: $e');
    }
  }

  Future<void> _handlePass(User user) async {
    print('👎 DISCOVERY_SCREEN: User passed ${user.firstName} ${user.lastName} (ID: ${user.id})');
    
    // Handle user's own profile
    if (_isOwnProfile(user)) {
      print('👎 DISCOVERY_SCREEN: User passed their own profile');
      _viewedOwnProfile.add(user.id);
      setState(() {
        _discoveredUsers.removeWhere((u) => u.id == user.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No worries! Keep exploring to find other nurses.'),
          backgroundColor: AppColors.textSecondary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    try {
      print('👎 DISCOVERY_SCREEN: Sending pass request to backend...');
      await DiscoveryService.passUser(user.id);
      if (!mounted) return;
      
      print('✅ DISCOVERY_SCREEN: Pass successful');
      setState(() {
        _discoveredUsers.removeWhere((u) => u.id == user.id);
      });
      
      print('💳 DISCOVERY_SCREEN: Card removed. ${_discoveredUsers.length} cards remaining');
    } catch (e) {
      print('💥 DISCOVERY_SCREEN: Pass exception: $e');
      _showError('Failed to pass user: $e');
    }
  }

  Future<void> _handleSuperLike(User user) async {
    print('⭐ DISCOVERY_SCREEN: User super liked ${user.firstName} ${user.lastName} (ID: ${user.id})');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Handle user's own profile
    if (_isOwnProfile(user)) {
      print('⭐ DISCOVERY_SCREEN: User super liked their own profile');
      _viewedOwnProfile.add(user.id);
      setState(() {
        _discoveredUsers.removeWhere((u) => u.id == user.id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You really love yourself! That\'s the confidence we like to see! 💪'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    if (!authProvider.isPaidUser && authProvider.giftPoints < 10) {
      print('❌ DISCOVERY_SCREEN: Super like blocked - insufficient gift points');
      _showUpgradeDialog('Super likes require 10 gift points or a premium subscription!');
      return;
    }

    try {
      print('⭐ DISCOVERY_SCREEN: Sending super like request to backend...');
      final success = await DiscoveryService.superLikeUser(user.id);
      if (!mounted) return;
      
      if (success) {
        print('✅ DISCOVERY_SCREEN: Super like successful');
        if (!authProvider.isPaidUser) {
          authProvider.spendGiftPoints(10);
        }
        
        setState(() {
          _discoveredUsers.removeWhere((u) => u.id == user.id);
        });
        
        print('💳 DISCOVERY_SCREEN: Card removed. ${_discoveredUsers.length} cards remaining');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You super liked ${user.firstName}! ⭐'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ DISCOVERY_SCREEN: Super like failed - backend returned false');
      }
    } catch (e) {
      print('💥 DISCOVERY_SCREEN: Super like exception: $e');
      _showError('Failed to super like user: $e');
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => _buildFiltersSheet(scrollController),
      ),
    );
  }

  Widget _buildFiltersSheet(ScrollController scrollController) {
    return StatefulBuilder(
      builder: (context, setModalState) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Discovery Filters',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  // Age Range
                  _buildFilterSection(
                    'Age Range',
                    RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 80,
                      divisions: 62,
                      labels: RangeLabels(
                        _ageRange.start.round().toString(),
                        _ageRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setModalState(() {
                          _ageRange = values;
                        });
                      },
                    ),
                  ),
                  
                  // Max Distance
                  _buildFilterSection(
                    'Max Distance: ${_maxDistance.round()} miles',
                    Slider(
                      value: _maxDistance,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      onChanged: (value) {
                        setModalState(() {
                          _maxDistance = value;
                        });
                      },
                    ),
                  ),
                  
                  // Nursing Specialty
                  _buildFilterSection(
                    'Nursing Specialty',
                    DropdownButton<String>(
                      value: _selectedSpecialty ?? 'All Specialties',
                      isExpanded: true,
                      onChanged: (value) {
                        setModalState(() {
                          _selectedSpecialty = value;
                        });
                      },
                      items: _nursingSpecialties.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(specialty),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Gender
                  _buildFilterSection(
                    'Gender',
                    DropdownButton<String>(
                      value: _selectedGender ?? 'All Genders',
                      isExpanded: true,
                      onChanged: (value) {
                        setModalState(() {
                          _selectedGender = value;
                        });
                      },
                      items: _genderOptions.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  // Toggle filters
                  _buildToggleFilter(
                    'Verified profiles only',
                    _verifiedOnly,
                    (value) => setModalState(() => _verifiedOnly = value),
                  ),
                  
                  _buildToggleFilter(
                    'Online now',
                    _onlineOnly,
                    (value) => setModalState(() => _onlineOnly = value),
                  ),
                ],
              ),
            ),
            
            // Apply button
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.urbanist(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleFilter(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    _loadDiscoveredUsers();
  }

  void _showUpgradeDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to subscription page
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              'Discover',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Issue',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load profiles from the server. Please check your internet connection.',
              style: GoogleFonts.urbanist(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDiscoveredUsers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_discoveredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_outline,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve seen everyone!',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new profiles or adjust your filters to see more people.',
              style: GoogleFonts.urbanist(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showFilters,
              child: const Text('Adjust Filters'),
            ),
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background cards (next 2 cards)
          for (int i = 0; i < _discoveredUsers.length && i < 3; i++)
            Positioned(
              top: i * 5.0,
              left: i * 2.0,
              right: i * 2.0,
              child: Transform.scale(
                scale: 1.0 - (i * 0.05),
                child: SwipeCard(
                  user: _discoveredUsers[i],
                  isTopCard: i == 0,
                  onTap: () => _handleTap(_discoveredUsers[i]),
                  onLike: () => _handleLike(_discoveredUsers[i]),
                  onPass: () => _handlePass(_discoveredUsers[i]),
                  onSuperLike: () => _handleSuperLike(_discoveredUsers[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
