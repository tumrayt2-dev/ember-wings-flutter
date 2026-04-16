import 'package:flutter/foundation.dart';

class MonetizationConfig {
  // Canlanma (oyun içi devam) — herkes için sabit
  static const int maxContinuesPerGame = 2;

  // ─── AdMob ID'leri ────────────────────────────────────────────
  // Debug modunda Google'ın resmi test ID'leri kullanılır.
  // Release modunda gerçek ID'ler devreye girer.

  static const String _prodRewardedAdUnitId = 'ca-app-pub-8438407620610676/6198788478';
  static const String _prodBannerAdUnitId   = 'ca-app-pub-8438407620610676/4888272893';

  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerAdUnitId   = 'ca-app-pub-3940256099942544/6300978111';

  static const String rewardedAdUnitId = kReleaseMode ? _prodRewardedAdUnitId : _testRewardedAdUnitId;
  static const String bannerAdUnitId   = kReleaseMode ? _prodBannerAdUnitId   : _testBannerAdUnitId;
}
