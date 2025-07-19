import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._internal();
  
  AdService._internal();
  
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  
  // AdMob App ID and Ad Unit IDs (replace with your actual IDs)
  static const String _appId = 'ca-app-pub-3940256099942544~3347511713'; // Test App ID
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded Ad ID
  
  // Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  
  // Load rewarded ad
  Future<void> loadRewardedAd() async {
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          if (kDebugMode) {
            print('Rewarded ad loaded successfully');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdReady = false;
          if (kDebugMode) {
            print('Rewarded ad failed to load: $error');
          }
        },
      ),
    );
  }
  
  // Show rewarded ad
  Future<bool> showRewardedAd() async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      await loadRewardedAd();
      // Wait a bit for the ad to load
      await Future.delayed(const Duration(seconds: 2));
    }
    
    if (!_isRewardedAdReady || _rewardedAd == null) {
      return false;
    }
    
    bool adWatched = false;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        loadRewardedAd(); // Preload next ad
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        adWatched = true;
        if (kDebugMode) {
          print('User earned reward: ${reward.amount} ${reward.type}');
        }
      },
    );
    
    return adWatched;
  }
  
  // Show 3 sequential rewarded ads for free gifts
  Future<bool> showRewardedAdsForFreeGift() async {
    int adsWatched = 0;
    
    for (int i = 0; i < 3; i++) {
      if (kDebugMode) {
        print('Showing rewarded ad ${i + 1}/3');
      }
      
      final adWatched = await showRewardedAd();
      
      if (adWatched) {
        adsWatched++;
        if (kDebugMode) {
          print('Ad ${i + 1}/3 watched successfully');
        }
        
        // Wait a bit between ads
        if (i < 2) {
          await Future.delayed(const Duration(seconds: 1));
        }
      } else {
        if (kDebugMode) {
          print('Ad ${i + 1}/3 failed to show or was not watched');
        }
        break;
      }
    }
    
    return adsWatched == 3;
  }
  
  // Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdReady;
  
  // Dispose resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;
  }
} 