import 'dart:ui' show VoidCallback;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/monetization_config.dart';

class AdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  bool get isAdReady => _rewardedAd != null;

  Future<void> init() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    await _loadAd();
  }

  Future<void> _loadAd() async {
    if (kIsWeb || _isLoading) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  /// Rewarded video göster, başarılı izlenirse onRewarded çağrılır.
  /// Reklam yoksa veya web'deyse doğrudan onRewarded çağrılır (test/geliştirme kolaylığı).
  Future<void> showRewardedAd({required VoidCallback onRewarded}) async {
    if (kIsWeb || _rewardedAd == null) {
      onRewarded();
      _loadAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
