import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/gift_tile.dart';
import '../../models/gift_model.dart';
import '../../services/gift_service.dart';
import '../../providers/auth_provider.dart';
import '../../components/rewarded_ad_dialog.dart';

class GiftsScreen extends StatefulWidget {
  const GiftsScreen({super.key});

  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> {
  List<Gift> _allGifts = [];
  List<Gift> _freeGifts = [];
  List<Gift> _premiumGifts = [];
  bool _isLoading = true;
  String? _error;
  final int _selectedTabIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadGifts();
  }
  
  Future<void> _loadGifts() async {
    print('🎁 GIFTS_SCREEN: Loading gifts...');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final gifts = await GiftService.getAllGifts();
      print('🎁 GIFTS_SCREEN: Loaded ${gifts.length} gifts');
      
      setState(() {
        _allGifts = gifts;
        _freeGifts = gifts.where((gift) => gift.isFree).toList();
        _premiumGifts = gifts.where((gift) => !gift.isFree).toList();
        _isLoading = false;
      });
      
      print('🎁 GIFTS_SCREEN: ${_freeGifts.length} free gifts, ${_premiumGifts.length} premium gifts');
    } catch (e) {
      print('❌ GIFTS_SCREEN: Error loading gifts: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _handleFreeGiftTap(Gift gift) {
    print('🎁 GIFTS_SCREEN: Free gift tapped: ${gift.name}');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user has admin access
    if (authProvider.isAdminOrDev) {
      print('🎁 GIFTS_SCREEN: Admin user - sending gift directly');
      _sendGift(gift);
      return;
    }
    
    // For free users, show rewarded ad dialog
    showDialog(
      context: context,
      builder: (context) => RewardedAdDialog(
        giftName: gift.name,
        giftIcon: gift.icon,
        adType: 'free_gift_rewarded',
        onAdCompleted: () {
          print('🎁 GIFTS_SCREEN: Rewarded ad completed for ${gift.name}');
          _sendGift(gift);
        },
        onAdFailed: (error) {
          print('❌ GIFTS_SCREEN: Rewarded ad failed: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to show ad: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }
  
  void _handlePremiumGiftTap(Gift gift) {
    print('🎁 GIFTS_SCREEN: Premium gift tapped: ${gift.name}');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user has admin access
    if (authProvider.isAdminOrDev) {
      print('🎁 GIFTS_SCREEN: Admin user - sending premium gift directly');
      _sendGift(gift);
      return;
    }
    
    // Check subscription plan
    if (authProvider.canUsePremiumFeatures) {
      _sendGift(gift);
    } else {
      _showSubscriptionRequiredDialog(gift);
    }
  }
  
  void _sendGift(Gift gift) {
    print('🎁 GIFTS_SCREEN: Sending gift: ${gift.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gift.name} sent successfully!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Implement actual gift sending logic
    // This would typically call an API to send the gift
  }
  
  void _showSubscriptionRequiredDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Gift'),
        content: Text('${gift.name} is a premium gift. Upgrade to Gold or Platinum plan to send premium gifts!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription screen
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Gift Shop', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: const Color(0xFFFFE5B4),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error loading gifts', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(_error!, style: GoogleFonts.urbanist(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGifts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.card_giftcard, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Free (${_freeGifts.length})', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Premium (${_premiumGifts.length})', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Admin badge
                      if (authProvider.isAdminOrDev)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          color: AppColors.success,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text('Admin Access - All Gifts Unlocked', style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      
                      // Info banner for free users
                      if (!authProvider.isAdminOrDev)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          color: AppColors.info.withValues(alpha: 0.1),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.info_outline, color: AppColors.info, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Free gifts require watching 3 ads', style: GoogleFonts.urbanist(color: AppColors.info, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Premium gifts require Gold+ subscription', style: GoogleFonts.urbanist(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      
                      // Tab content
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Free gifts tab
                            _buildGiftGrid(_freeGifts, _handleFreeGiftTap, isFreeTier: true),
                            
                            // Premium gifts tab
                            _buildGiftGrid(_premiumGifts, _handlePremiumGiftTap, isFreeTier: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildGiftGrid(List<Gift> gifts, Function(Gift) onTap, {required bool isFreeTier}) {
    if (gifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text('No ${isFreeTier ? 'free' : 'premium'} gifts available', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Check back later for new gifts!', style: GoogleFonts.urbanist(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return GiftTile(
            gift: gift,
            onTap: () => onTap(gift),
            isLocked: !isFreeTier && !Provider.of<AuthProvider>(context, listen: false).canUsePremiumFeatures && !Provider.of<AuthProvider>(context, listen: false).isAdminOrDev,
          );
        },
      ),
    );
  }
               }
 } 
