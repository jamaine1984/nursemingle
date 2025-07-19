import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/gift_model.dart';

class GiftTile extends StatelessWidget {
  final Gift gift;
  final VoidCallback onTap;
  final bool isLocked;

  const GiftTile({
    Key? key,
    required this.gift,
    required this.onTap,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isLocked ? AppColors.surfaceVariant : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? AppColors.textSecondary : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gift icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLocked ? AppColors.textSecondary : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      gift.icon ?? '🎁',
                      style: TextStyle(
                        fontSize: 24,
                        color: isLocked ? AppColors.textSecondary : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Gift name
                Text(
                  gift.name,
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isLocked ? AppColors.textSecondary : AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Price or status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLocked 
                        ? AppColors.textSecondary.withValues(alpha: 0.1)
                        : gift.isFree 
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLocked 
                        ? 'Locked'
                        : gift.isFree 
                            ? 'FREE'
                            : '${gift.price} coins',
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLocked 
                          ? AppColors.textSecondary
                          : gift.isFree 
                              ? AppColors.success
                              : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            // Lock icon overlay
            if (isLocked)
              Positioned(
                top: 8,
                right: 8,
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
          ],
        ),
      ),
    );
  }
} 
