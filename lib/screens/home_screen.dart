import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../widgets/swipe_card.dart';
import '../widgets/profile_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<User> _profiles = [];
  int _currentIndex = 0;
  final int _adsWatchedLikes = 0;
  final int _adsWatchedSuperLikes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfiles();
    });
  }

  void _loadProfiles() {
    if (!mounted) return;
    
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      setState(() {
        _profiles.clear();
        _profiles.addAll(appState.availableProfiles);
      });
    } catch (e) {
      print('Error loading profiles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading profiles')),
        );
      }
    }
  }

  void _onSwipeLeft(User profile) {
    if (!mounted) return;
    
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.dislikeProfile(profile);
      _showSnackBar('You passed on ${profile.name}');
      _nextProfile();
    } catch (e) {
      print('Error on swipe left: $e');
    }
  }

  void _onSwipeRight(User profile) {
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      
      if (authProvider.canLike) {
        appState.likeProfile(profile);
        _showSnackBar('You liked ${profile.name}! ❤️');
        _nextProfile();
      } else {
        _showLimitDialog('likes');
      }
    } catch (e) {
      print('Error on swipe right: $e');
    }
  }

  void _onSuperLike(User profile) {
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      
      if (authProvider.canSuperLike) {
        appState.superLikeProfile(profile);
        _showSnackBar('You super liked ${profile.name}! ⭐');
        _nextProfile();
      } else {
        _showLimitDialog('super likes');
      }
    } catch (e) {
      print('Error on super like: $e');
    }
  }

  void _onTapProfile(User profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileDetailScreen(user: profile),
      ),
    );
  }

  void _nextProfile() {
    if (!mounted) return;
    
    try {
      setState(() {
        if (_currentIndex < _profiles.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
          _loadProfiles();
        }
      });
    } catch (e) {
      print('Error going to next profile: $e');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      print('Error showing snackbar: $e');
    }
  }

  void _showLimitDialog(String limitType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Premium'),
        content: Text('You\'ve reached your daily $limitType limit. Upgrade to premium for unlimited $limitType!'),
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'NurseMingle',
          style: GoogleFonts.urbanist(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.onPrimary),
            onPressed: () {
              // Apply filter logic here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Notification banner
          if (appState.notifications.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.shade100,
              child: Row(
                children: [
                  Icon(Icons.notifications, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appState.notifications.first,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.orange.shade800, size: 20),
                    onPressed: () => appState.clearNotifications(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: _profiles.isEmpty
                ? _buildEmptyState()
                : Stack(
                    children: [
                      // Profile cards
                      PageView.builder(
                        itemCount: _profiles.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: SwipeCard(
                              user: _profiles[index],
                              onPass: () => _onSwipeLeft(_profiles[index]),
                              onLike: () => _onSwipeRight(_profiles[index]),
                              onTap: () => _onTapProfile(_profiles[index]),
                            ),
                          );
                        },
                      ),

                      // Action buttons
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.close,
                              color: Colors.red,
                              onPressed: () {
                                if (_currentIndex < _profiles.length) {
                                  _onSwipeLeft(_profiles[_currentIndex]);
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.favorite,
                              color: Colors.green,
                              onPressed: () {
                                if (_currentIndex < _profiles.length) {
                                  _onSwipeRight(_profiles[_currentIndex]);
                                }
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.star,
                              color: Colors.blue,
                              onPressed: () {
                                if (_currentIndex < _profiles.length) {
                                  _onSuperLike(_profiles[_currentIndex]);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No more profiles',
            style: GoogleFonts.urbanist(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Check back later for new profiles!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _loadProfiles();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 28),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
} 
