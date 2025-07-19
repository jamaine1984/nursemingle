import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/ad_service.dart';

class RewardedAdDialog extends StatefulWidget {
  final String giftName;
  final String giftIcon;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const RewardedAdDialog({
    Key? key,
    required this.giftName,
    required this.giftIcon,
    required this.onSuccess,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<RewardedAdDialog> {
  int _adsWatched = 0;
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    // Preload first ad
    AdService.instance.loadRewardedAd();
  }

  Future<void> _watchAds() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Loading ad ${_adsWatched + 1} of 3...';
    });

    try {
      // Show sequential ads
      for (int i = _adsWatched; i < 3; i++) {
        setState(() {
          _statusMessage = 'Loading ad ${i + 1} of 3...';
        });

        // Show the ad
        final adWatched = await AdService.instance.showRewardedAd();
        
        if (adWatched) {
          setState(() {
            _adsWatched = i + 1;
            _statusMessage = 'Ad ${i + 1} completed!';
          });
          
          // If all ads watched, success!
          if (_adsWatched == 3) {
            setState(() {
              _statusMessage = 'All ads completed! Adding gift to your inventory...';
            });
            
            // Small delay to show success message
            await Future.delayed(const Duration(seconds: 1));
            
            // Close dialog and call success callback
            Navigator.of(context).pop();
            widget.onSuccess();
            return;
          }
          
          // Small delay between ads
          if (i < 2) {
            await Future.delayed(const Duration(milliseconds: 500));
          }
        } else {
          // Ad failed or was skipped
          setState(() {
            _isLoading = false;
            _statusMessage = 'Ad was not completed. Please try again.';
          });
          return;
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading ads. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Text(
            widget.giftIcon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'Get ${widget.giftName}',
            style: GoogleFonts.urbanist(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Watch 3 ads to get this free gift!',
            style: GoogleFonts.urbanist(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _adsWatched
                      ? AppColors.success
                      : AppColors.surfaceVariant,
                  border: Border.all(
                    color: index < _adsWatched
                        ? AppColors.success
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: index < _adsWatched
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '${index + 1}',
                          style: GoogleFonts.urbanist(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          if (_statusMessage.isNotEmpty) ...[
            Text(
              _statusMessage,
              style: GoogleFonts.urbanist(
                fontSize: 14,
                color: _statusMessage.contains('Error')
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_adsWatched > 0 && _adsWatched < 3)
            Text(
              '$_adsWatched of 3 ads watched',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onCancel();
                },
          child: Text(
            'Cancel',
            style: GoogleFonts.urbanist(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _watchAds,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _adsWatched == 0
                ? 'Watch Ads'
                : _adsWatched < 3
                    ? 'Continue'
                    : 'Complete',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
} 
