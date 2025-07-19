import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/gift_model.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart'; // Added import for AppStateProvider
import '../services/ad_service.dart'; // Added import for AdService

class GiftsScreen extends StatefulWidget {
  final bool isModal;
  final Function(dynamic)? onGiftSelected;
  
  const GiftsScreen({
    super.key,
    this.isModal = false,
    this.onGiftSelected,
  });

  @override
  State<GiftsScreen> createState() => _GiftsScreenState();
}

class _GiftsScreenState extends State<GiftsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  int _adsWatchedForGifts = 0;

  final List<String> _categories = [
    'All',
    'Medical Equipment',
    'Medical Professionals',
    'Medical Symbols',
    'Hospital Items',
    'Body Parts',
    'Premium Medical Equipment',
    'Premium Medical Professionals',
    'Premium Medical Symbols',
    'Premium Hospital Items',
    'Premium Body Parts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Gift> _getFilteredGifts() {
    // Return filtered gifts from app state
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    return appState.availableGifts;
  }

  void _watchAdForGifts() {
    // TODO: Implement rewarded ad logic
    setState(() {
      _adsWatchedForGifts++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You earned gift points!')),
    );
  }

  void _onGiftTap(Gift gift) {
    if (widget.isModal && widget.onGiftSelected != null) {
      widget.onGiftSelected!(gift);
      Navigator.pop(context);
      return;
    }
    
    if (gift.price == 0) {
      // Free gift - require 3 rewarded ads
      _showRewardedAdDialog(gift);
    } else {
      // Paid gift - show purchase dialog
      _showPurchaseDialog(gift);
    }
  }

  void _showRewardedAdDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Watch Ads for Free Gift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Watch 3 rewarded ads to claim this free gift!',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              gift.name,
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _watchRewardedAdsForGift(gift);
            },
            child: const Text('Watch Ads'),
          ),
        ],
      ),
    );
  }

  Future<void> _watchRewardedAdsForGift(Gift gift) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading ads...'),
            ],
          ),
        ),
      );

      // Import and use the ad service
      final adService = AdService.instance;
      final success = await adService.showRewardedAdsForFreeGift();
      
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        // All 3 ads watched successfully
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        await appState.completeRewardedAdsForGift(gift.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Free gift claimed! Added to inventory 🎁'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to watch all 3 ads to claim the gift'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showPurchaseDialog(Gift gift) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Gift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              gift.name,
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${gift.price.toStringAsFixed(2)}',
              style: GoogleFonts.urbanist(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseGift(gift);
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseGift(Gift gift) async {
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.purchaseGift(gift.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gift purchased! Added to inventory 🎁'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _sendGift(Gift gift) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (gift.price > 0 && !authProvider.canSendPremiumGifts) {
      // Show premium gift dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Premium Gift'),
          content: const Text('This is a premium gift. Upgrade your subscription to send premium gifts!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to subscription page
              },
              child: const Text('Upgrade'),
            ),
          ],
        ),
      );
      return;
    }

    // Check if user has enough gift points
    if (gift.price > authProvider.giftPoints) {
      // Show insufficient points dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Gift Points'),
          content: Text('You need ${gift.price} gift points to send this gift. You have ${authProvider.giftPoints} points.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to purchase gift points
              },
              child: const Text('Get More Points'),
            ),
          ],
        ),
      );
      return;
    }

    // Send the gift
    // authProvider.giftPoints -= gift.price; // Commented out as setter is mock
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${gift.name} sent successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final filteredGifts = _getFilteredGifts();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Gift Shelf',
          style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Gift Shelf Info'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Free gifts require watching 3 ads', style: GoogleFonts.poppins()),
                      Text('• Premium gifts require gift points', style: GoogleFonts.poppins()),
                      Text('• Starter/Gold plans can send all gifts', style: GoogleFonts.poppins()),
                      Text('• Free plan: only free gifts via ads', style: GoogleFonts.poppins()),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Gift points and plan info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gift Points',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      authProvider.giftPoints.toString(),
                      style: GoogleFonts.urbanist(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      authProvider.currentPlan,
                      style: GoogleFonts.urbanist(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.free_breakfast, size: 16),
                      const SizedBox(width: 4),
                      Text('Free', style: GoogleFonts.poppins(fontSize: 12)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond, size: 16),
                      const SizedBox(width: 4),
                      Text('Premium', style: GoogleFonts.poppins(fontSize: 12)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory, size: 16),
                      const SizedBox(width: 4),
                      Text('Inventory', style: GoogleFonts.poppins(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Gifts grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Free gifts tab
                _buildGiftsGrid(
                  filteredGifts.where((gift) => gift.price == 0).toList(),
                  isPremium: false,
                ),
                // Premium gifts tab
                _buildGiftsGrid(
                  filteredGifts.where((gift) => gift.price > 0).toList(),
                  isPremium: true,
                ),
                // Inventory tab
                _buildGiftsGrid(
                  Provider.of<AppStateProvider>(context).giftInventory,
                  isPremium: false,
                  isInventory: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftsGrid(List<Gift> gifts, {required bool isPremium, bool isInventory = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        return _buildGiftCard(gift, isPremium: isPremium, isInventory: isInventory);
      },
    );
  }

  Widget _buildGiftCard(Gift gift, {required bool isPremium, bool isInventory = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final canSend = gift.price == 0 || authProvider.canSendPremiumGifts;
    
    return GestureDetector(
      onTap: () => _onGiftTap(gift),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canSend ? AppColors.primary : AppColors.textSecondary,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gift.icon ?? gift.imageUrl,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              gift.name,
              style: GoogleFonts.urbanist(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${gift.price} points',
              style: GoogleFonts.urbanist(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            if (!canSend)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Premium',
                  style: GoogleFonts.urbanist(
                    fontSize: 8,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
