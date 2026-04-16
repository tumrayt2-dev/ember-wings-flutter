import 'dart:ui' show VoidCallback;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/monetization_config.dart';

class AdService {
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _isRewardedLoading = false;
  bool _isBannerLoaded = false;

  bool get isAdReady => _rewardedAd != null;
  bool get isBannerLoaded => _isBannerLoaded;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> init() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    _loadRewardedAd();
    _loadBannerAd();
  }

  // ─── Rewarded ────────────────────────────────────────────────

  Future<void> _loadRewardedAd() async {
    if (kIsWeb || _isRewardedLoading) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  Future<void> showRewardedAd({required VoidCallback onRewarded}) async {
    if (kIsWeb || _rewardedAd == null) {
      onRewarded();
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded();
      },
    );
  }

  // ─── Banner ───────────────────────────────────────────────────

  void _loadBannerAd() {
    if (kIsWeb) return;

    _bannerAd = BannerAd(
      adUnitId: MonetizationConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isBannerLoaded = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
        },
      ),
    )..load();
  }

  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
  }
}
