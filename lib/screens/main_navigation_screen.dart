import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state_provider.dart';
import 'home_discovery_screen.dart';
import 'messages_screen.dart';
import 'live_screen.dart';
import 'video_screen.dart';
import 'gifts_screen.dart';
import 'creator_dashboard_screen.dart';
import 'ProfileScreen/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Lazy-loaded screens - only create when needed
  final Map<int, Widget> _screenCache = {};

  Widget _getScreen(int index) {
    if (_screenCache.containsKey(index)) {
      return _screenCache[index]!;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeDiscoveryScreen();
        break;
      case 1:
        screen = const MessagesScreen();
        break;
      case 2:
        screen = const LiveScreen();
        break;
      case 3:
        screen = const VideoScreen();
        break;
      case 4:
        screen = const GiftsScreen();
        break;
      case 5:
        screen = const CreatorDashboardScreen();
        break;
      case 6:
        screen = const ProfileScreen();
        break;
      default:
        screen = const HomeDiscoveryScreen();
    }

    _screenCache[index] = screen;
    return screen;
  }

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: 'Discover',
    ),
    NavigationItem(
      icon: Icons.message_outlined,
      activeIcon: Icons.message,
      label: 'Messages',
    ),
    NavigationItem(
      icon: Icons.live_tv_outlined,
      activeIcon: Icons.live_tv,
      label: 'Live',
    ),
    NavigationItem(
      icon: Icons.dynamic_feed_outlined,
      activeIcon: Icons.dynamic_feed,
      label: 'Feed',
    ),
    NavigationItem(
      icon: Icons.card_giftcard_outlined,
      activeIcon: Icons.card_giftcard,
      label: 'Gifts',
    ),
    NavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Creator',
    ),
    NavigationItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
      
      // Always initialize app state to show dummy users
      await appStateProvider.initialize();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: _navigationItems.length,
        itemBuilder: (context, index) {
          return _getScreen(index);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navigationItems[index];
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? AppColors.primary : AppColors.iconUnselected,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.iconUnselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
} 
