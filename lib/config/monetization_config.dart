class MonetizationConfig {
  // Seans sistemi
  static const int gamesPerVideoReward = 3;
  static const int freeTrialGamesPerCharacter = 2;

  // Google Play product ID'leri
  static const String productIdPrefix = 'character_';
  static const String productIdBundle = 'character_bundle_all';

  // Reklamsız paket
  static const String productIdAdFree = 'ad_free_pack';

  // İndirim oranı (popup'ta gösterim için)
  static const int bundleDiscountPercent = 20;

  // AdMob ID'leri (test ID'leri — yayınlamadan önce gerçek ID ile değiştirilecek)
  // App ID: AndroidManifest.xml'de de güncellenmeli
  static const String adMobAppId = 'ca-app-pub-3940256099942544~3347511713'; // test App ID
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // test Ad Unit ID
}
