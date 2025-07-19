import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../widgets/swipe_card.dart';
import '../widgets/profile_detail_screen.dart';
import 'admirers_screen.dart';
import 'filters_screen.dart';

class HomeDiscoveryScreen extends StatefulWidget {
  const HomeDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<HomeDiscoveryScreen> createState() => _HomeDiscoveryScreenState();
}

class _HomeDiscoveryScreenState extends State<HomeDiscoveryScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfiles();
    });
  }

  Future<void> _loadProfiles() async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      await appStateProvider.loadDiscoverProfiles();
    } catch (e) {
      print('Error loading profiles: $e');
      // Continue with empty state
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Consumer2<AppStateProvider, AuthProvider>(
                builder: (context, appState, auth, child) {
                  return _buildContent(appState, auth);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Text(
              'Discover',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
          
          // Filters Button
          _buildActionButton(
            icon: Icons.tune,
            onTap: () => _showFilters(),
          ),
          
          const SizedBox(width: 12),
          
          // Admirers Button
          _buildActionButton(
            icon: Icons.favorite_border,
            onTap: () => _showAdmirers(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildContent(AppStateProvider appState, AuthProvider auth) {
    if (appState.isLoadingProfiles) {
      return _buildLoadingState();
    }

    if (appState.error != null) {
      return _buildErrorState(appState.error!);
    }

    if (appState.availableProfiles.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSwipeCards(appState, auth);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Finding amazing people...',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'We\'re loading profiles just for you',
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Oops! Something went wrong',
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            error,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _loadProfiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Try Again',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'No users yet',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Be the first to find love on Nurse Mingle.',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: () {
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              appState.loadDiscoverProfiles(refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(
              'Refresh',
              style: GoogleFonts.urbanist(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCards(AppStateProvider appState, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Usage Stats
          _buildUsageStats(auth),
          
          const SizedBox(height: 20),
          
          // Swipe Cards
          Expanded(
            child: Stack(
              children: [
                for (int i = 0; i < appState.availableProfiles.length && i < 3; i++)
                  Positioned(
                    top: i * 8.0,
                    left: i * 4.0,
                    right: i * 4.0,
                    bottom: 0,
                    child: SwipeCard(
                      user: appState.availableProfiles[i],
                      onPass: () => _onSwipeLeft(appState.availableProfiles[i]),
                      onLike: () => _onSwipeRight(appState.availableProfiles[i]),
                      onSuperLike: () => _onSuperLike(appState.availableProfiles[i]),
                      onTap: () => _navigateToProfile(appState.availableProfiles[i]),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(appState, auth),
        ],
      ),
    );
  }

  Widget _buildUsageStats(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.favorite,
            count: auth.remainingLikes,
            label: 'Likes',
            color: AppColors.error,
          ),
          _buildStatItem(
            icon: Icons.star,
            count: auth.remainingSuperLikes,
            label: 'Super Likes',
            color: AppColors.warning,
          ),
          _buildStatItem(
            icon: Icons.message,
            count: auth.remainingMessages,
            label: 'Messages',
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppStateProvider appState, AuthProvider auth) {
    if (appState.availableProfiles.isEmpty) {
      return const SizedBox();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCircleButton(
          icon: Icons.close,
          color: AppColors.error,
          onTap: () => _onSwipeLeft(appState.availableProfiles.first),
          label: 'Dislike',
        ),
        _buildCircleButton(
          icon: Icons.favorite_border,
          color: AppColors.primary,
          onTap: () => _onAdmire(appState.availableProfiles.first),
          label: 'Admire',
        ),
        _buildCircleButton(
          icon: Icons.star,
          color: AppColors.warning,
          onTap: () => _onSuperLike(appState.availableProfiles.first),
          label: 'Super Like',
        ),
        _buildCircleButton(
          icon: Icons.favorite,
          color: AppColors.success,
          onTap: () => _onSwipeRight(appState.availableProfiles.first),
          label: 'Like',
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.urbanist(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSwipeLeft(User profile) async {
    try {
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      await appStateProvider.dislikeProfile(profile);
    } catch (e) {
      print('Error disliking profile: $e');
    }
  }

  Future<void> _onSwipeRight(User profile) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      
      if (!authProvider.canLike) {
        _showUsageLimitDialog();
        return;
      }

      await appStateProvider.likeProfile(profile);
    } catch (e) {
      print('Error liking profile: $e');
    }
  }

  Future<void> _onSuperLike(User profile) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      
      if (!authProvider.canSuperLike) {
        _showUsageLimitDialog();
        return;
      }

      await appStateProvider.superLikeProfile(profile);
    } catch (e) {
      print('Error super liking profile: $e');
    }
  }

  Future<void> _onAdmire(User profile) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      
      if (!authProvider.canLike) {
        _showUsageLimitDialog();
        return;
      }

      await appStateProvider.admireProfile(profile);
    } catch (e) {
      print('Error admiring profile: $e');
    }
  }

  void _navigateToProfile(User profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(user: profile),
      ),
    );
  }

  void _showUsageLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Limit Reached'),
        content: const Text('You\'ve reached your daily limit. Upgrade to premium for unlimited access!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FiltersScreen(),
      ),
    );
  }

  void _showAdmirers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdmirersScreen(),
      ),
    );
  }
} 