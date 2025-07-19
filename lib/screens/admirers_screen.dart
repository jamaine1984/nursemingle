import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/app_state_provider.dart';
import '../utils/app_colors.dart';
import '../models/user.dart';
import '../components/rewarded_ad_dialog.dart';
import '../widgets/profile_detail_screen.dart';

class AdmirersScreen extends StatefulWidget {
  const AdmirersScreen({Key? key}) : super(key: key);

  @override
  State<AdmirersScreen> createState() => _AdmirersScreenState();
}

class _AdmirersScreenState extends State<AdmirersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _adsWatchedForUnblur = 0;
  final int _adsRequiredToUnblur = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdmirers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmirers() async {
    final appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Load admirers with blurring based on subscription
    await appStateProvider.loadAdmirers(
      showBlurred: !authProvider.isGoldSubscriber && _adsWatchedForUnblur < _adsRequiredToUnblur
    );
  }

  Future<void> _watchAdToUnblur() async {
    // Show rewarded ad dialog
    showDialog(
      context: context,
      builder: (context) => RewardedAdDialog(
        giftName: 'Unblur Faces',
        giftIcon: '👁️',
        onSuccess: () {
          setState(() {
            _adsWatchedForUnblur++;
          });
          
          if (_adsWatchedForUnblur >= _adsRequiredToUnblur) {
            _loadAdmirers(); // Reload with unblurred faces
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All faces unlocked! 🎉'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_adsRequiredToUnblur - _adsWatchedForUnblur} more ads to unlock all faces'),
                backgroundColor: AppColors.info,
              ),
            );
          }
        },
        onCancel: () {
          // Dialog was cancelled
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Admirers',
          style: GoogleFonts.urbanist(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withValues(alpha: 0.7),
          tabs: [
            Tab(
              child: Text(
                'Admirers',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
              ),
            ),
            Tab(
              child: Text(
                'My Admirers',
                style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Consumer2<AuthProvider, AppStateProvider>(
        builder: (context, authProvider, appStateProvider, child) {
          if (appStateProvider.isLoadingAdmirers) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Admirers tab - Users who admired me
              _buildAdmirersTab(authProvider, appStateProvider),
              // My Admirers tab - Users I've admired
              _buildMyAdmirersTab(authProvider, appStateProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdmirersTab(AuthProvider authProvider, AppStateProvider appStateProvider) {
    final admirers = appStateProvider.admirers;
    final shouldBlur = !authProvider.isGoldSubscriber && _adsWatchedForUnblur < _adsRequiredToUnblur;

    return Column(
      children: [
        // Subscription/unlock info
        if (!authProvider.isGoldSubscriber)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      authProvider.isStarterSubscriber 
                        ? 'Upgrade to Gold to see all faces!'
                        : 'Unlock admirers faces',
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  shouldBlur
                    ? 'Watch ${_adsRequiredToUnblur - _adsWatchedForUnblur} more ads to see all faces'
                    : 'All faces unlocked for today!',
                  style: GoogleFonts.urbanist(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                if (shouldBlur) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _watchAdToUnblur,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Watch Ad to Unlock',
                      style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Admirers list
        Expanded(
          child: admirers.isEmpty
            ? _buildEmptyState('No admirers yet', 'Keep swiping to find your admirers!')
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: admirers.length,
                itemBuilder: (context, index) {
                  final admirer = admirers[index];
                  return _buildAdmirerCard(admirer, shouldBlur);
                },
              ),
        ),
      ],
    );
  }

  Widget _buildMyAdmirersTab(AuthProvider authProvider, AppStateProvider appStateProvider) {
    final myAdmirers = appStateProvider.myAdmirers;

    return myAdmirers.isEmpty
      ? _buildEmptyState('No admirers yet', 'Start liking profiles to see them here!')
      : GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: myAdmirers.length,
          itemBuilder: (context, index) {
            final admirer = myAdmirers[index];
            return _buildAdmirerCard(admirer, false); // Never blur my admirers
          },
        );
  }

  Widget _buildAdmirerCard(User admirer, bool shouldBlur) {
    return GestureDetector(
      onTap: () {
        if (!shouldBlur) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileDetailScreen(user: admirer),
            ),
          );
        } else {
          _showUnlockDialog();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Profile image
              admirer.profilePictureUrl.isNotEmpty
                ? Image.network(
                    admirer.profilePictureUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.background,
                        child: const Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppColors.background,
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.textSecondary,
                    ),
                  ),

              // Blur overlay
              if (shouldBlur)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),

              // Profile info
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shouldBlur ? '****' : admirer.name,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (admirer.profession != null)
                      Text(
                        shouldBlur ? '****' : admirer.profession!,
                        style: GoogleFonts.urbanist(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              // Verification badge
              if (admirer.isVerified && !shouldBlur)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: Icon(
                    Icons.verified,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.urbanist(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Admirers'),
        content: Text(
          'Watch ${_adsRequiredToUnblur - _adsWatchedForUnblur} more ads to see all admirers faces, or upgrade to Gold for unlimited access!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _watchAdToUnblur();
            },
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }
} 