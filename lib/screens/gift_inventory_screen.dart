import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/gift_service.dart';
import '../models/gift_inventory.dart';
import '../models/gift_model.dart';
import '../data/gift_catalog.dart';

class GiftInventoryScreen extends StatefulWidget {
  const GiftInventoryScreen({Key? key}) : super(key: key);

  @override
  State<GiftInventoryScreen> createState() => _GiftInventoryScreenState();
}

class _GiftInventoryScreenState extends State<GiftInventoryScreen> {
  UserGiftInventory? _inventory;
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, free, premium

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventory = await GiftService.getUserInventory();
      setState(() {
        _inventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load inventory: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<GiftInventoryItem> _getFilteredInventory() {
    if (_inventory == null) return [];
    
    switch (_selectedFilter) {
      case 'free':
        return _inventory!.getGiftsByType('free');
      case 'premium':
        return _inventory!.getGiftsByType('premium');
      default:
        return _inventory!.inventory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Gift Inventory',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Free Gifts', 'free'),
                const SizedBox(width: 8),
                _buildFilterChip('Premium Gifts', 'premium'),
              ],
            ),
          ),
          
          // Inventory stats
          if (_inventory != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total Gifts',
                    _inventory!.inventory.length.toString(),
                    Icons.card_giftcard,
                  ),
                  _buildStatItem(
                    'Free Gifts',
                    _inventory!.getGiftsByType('free').length.toString(),
                    Icons.volunteer_activism,
                  ),
                  _buildStatItem(
                    'Premium Gifts',
                    _inventory!.getGiftsByType('premium').length.toString(),
                    Icons.diamond,
                  ),
                ],
              ),
            ),
          
          // Gift grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildGiftGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(
        label,
        style: GoogleFonts.urbanist(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.text,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
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

  Widget _buildGiftGrid() {
    final filteredInventory = _getFilteredInventory();
    
    if (filteredInventory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_selectedFilter == 'all' ? '' : _selectedFilter} gifts yet',
              style: GoogleFonts.urbanist(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'free'
                  ? 'Watch ads to earn free gifts!'
                  : _selectedFilter == 'premium'
                      ? 'Upgrade to premium to get exclusive gifts!'
                      : 'Start collecting gifts from the gift shelf!',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
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
      itemCount: filteredInventory.length,
      itemBuilder: (context, index) {
        final inventoryItem = filteredInventory[index];
        final gift = GiftCatalog.getGiftById(inventoryItem.giftId);
        
        if (gift == null) {
          return const SizedBox();
        }
        
        return _buildInventoryGiftCard(gift, inventoryItem.quantity);
      },
    );
  }

  Widget _buildInventoryGiftCard(Gift gift, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(height: 4),
                Text(
                  gift.name,
                  style: GoogleFonts.urbanist(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Quantity badge
          if (quantity > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'x$quantity',
                  style: GoogleFonts.urbanist(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Type badge (Free/Premium)
          Positioned(
            bottom: 4,
            left: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: gift.category == 'premium'
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                gift.category == 'premium' ? 'Premium' : 'Free',
                style: GoogleFonts.urbanist(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: gift.category == 'premium'
                      ? AppColors.warning
                      : AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 