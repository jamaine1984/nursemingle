import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_model.dart';
import '../models/gift_inventory.dart';
import '../services/gift_service.dart';
import '../providers/auth_provider.dart';
import '../components/rewarded_ad_dialog.dart';
import '../data/gift_catalog.dart';
import 'gift_inventory_screen.dart';

class GiftShelfScreen extends StatefulWidget {
  const GiftShelfScreen({super.key});

  @override
  State<GiftShelfScreen> createState() => _GiftShelfScreenState();
}

class _GiftShelfScreenState extends State<GiftShelfScreen> with SingleTickerProviderStateMixin {
  List<Gift> _allGifts = [];
  UserGiftInventory? _userInventory;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load gifts from service (with fallback to catalog)
      final gifts = await GiftService.getAllGifts();
      
      // Load user inventory
      final inventory = await GiftService.getUserInventory();
      
      setState(() {
        _allGifts = gifts;
        _userInventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading gifts: $e');
      // Use catalog as fallback
      setState(() {
        _allGifts = GiftCatalog.getAllGifts();
        _isLoading = false;
      });
    }
  }

  List<Gift> _getFreeGifts() {
    return _allGifts.where((gift) => gift.category == 'free').toList();
  }

  List<Gift> _getPremiumGifts() {
    return _allGifts.where((gift) => gift.category == 'premium').toList();
  }

  void _onGiftTap(Gift gift) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (gift.category == 'free' && authProvider.isFreeUser) {
      // Free user tapping free gift - show rewarded ad dialog
      _showRewardedAdDialog(gift);
    } else if (gift.category == 'premium' && authProvider.isFreeUser) {
      // Free user tapping premium gift - show upgrade dialog
      _showUpgradeDialog(gift);
    } else if (gift.category == 'premium' && !authProvider.isFreeUser) {
      // Premium user tapping premium gift - check if they have coins
      _showPurchaseDialog(gift);
    } else {
      // Gift already accessible
      _showGiftDetails(gift);
    }
  }

  void _showRewardedAdDialog(Gift gift) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RewardedAdDialog(
        giftName: gift.name,
        giftIcon: gift.icon ?? '🎁',
        onSuccess: () async {
          // Add gift to inventory
          final success = await GiftService.completeFreeGiftAds(gift.id);
          
          if (success) {
            // Reload inventory
            await _loadGifts();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${gift.name} added to your inventory!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          }
        },
        onCancel: () {
          // User cancelled
        },
      ),
    );
  }

  void _showUpgradeDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Premium Gift',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gift.icon ?? '🎁',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              '${gift.name} is a premium gift',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade to Starter or Gold plan to access premium gifts!',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.urbanist(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to subscription screen
              Navigator.pushNamed(context, '/subscription');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: Text(
              'Upgrade Now',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Purchase ${gift.name}',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gift.icon ?? '🎁',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              gift.description,
              style: GoogleFonts.urbanist(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${gift.price} coins',
                    style: GoogleFonts.urbanist(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.urbanist(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Purchase gift
              final success = await GiftService.purchasePremiumGift(gift.id, 1);
              
              if (success) {
                await _loadGifts();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${gift.name} purchased successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient coins or purchase failed'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: Text(
              'Purchase',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showGiftDetails(Gift gift) {
    final inventoryQuantity = _userInventory?.getGiftQuantity(gift.id) ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          gift.name,
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              gift.icon ?? '🎁',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              gift.description,
              style: GoogleFonts.urbanist(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'You have: $inventoryQuantity',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.urbanist(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gift Shelf',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GiftInventoryScreen(),
                ),
              ).then((_) => _loadGifts());
            },
            tooltip: 'My Inventory',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          tabs: [
            Tab(
              text: 'Free Gifts (${_getFreeGifts().length})',
              icon: const Icon(Icons.volunteer_activism),
            ),
            Tab(
              text: 'Premium Gifts (${_getPremiumGifts().length})',
              icon: const Icon(Icons.diamond),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User status banner
                Container(
                  padding: const EdgeInsets.all(16),
                  color: authProvider.isFreeUser
                      ? AppColors.info.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(
                        authProvider.isFreeUser
                            ? Icons.info_outline
                            : Icons.verified,
                        color: authProvider.isFreeUser
                            ? AppColors.info
                            : AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authProvider.isFreeUser
                              ? 'Free User: Watch ads to earn free gifts!'
                              : 'Premium User: Access all gifts with coins!',
                          style: GoogleFonts.urbanist(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Gift tabs
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildGiftGrid(_getFreeGifts(), true),
                      _buildGiftGrid(_getPremiumGifts(), false),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGiftGrid(List<Gift> gifts, bool isFreeCategory) {
    if (gifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFreeCategory ? Icons.volunteer_activism : Icons.diamond,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isFreeCategory ? 'free' : 'premium'} gifts available',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return _buildGiftCard(gift);
      },
    );
  }

  Widget _buildGiftCard(Gift gift) {
    final authProvider = Provider.of<AuthProvider>(context);
    final inventoryQuantity = _userInventory?.getGiftQuantity(gift.id) ?? 0;
    final isAccessible = gift.category == 'free' || !authProvider.isFreeUser;
    
    return GestureDetector(
      onTap: () => _onGiftTap(gift),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccessible ? AppColors.border : AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gift content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gift.icon ?? '🎁',
                    style: TextStyle(
                      fontSize: 40,
                      color: isAccessible ? Colors.black : Colors.black.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gift.name,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAccessible ? AppColors.text : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (gift.category == 'premium')
                    Text(
                      '${gift.price} coins',
                      style: GoogleFonts.urbanist(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            
            // Lock icon for premium gifts (free users)
            if (gift.category == 'premium' && authProvider.isFreeUser)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            
            // Inventory badge
            if (inventoryQuantity > 0)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'x$inventoryQuantity',
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            
            // Free gift ad indicator
            if (gift.category == 'free' && authProvider.isFreeUser && inventoryQuantity == 0)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.play_circle_outline,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 
