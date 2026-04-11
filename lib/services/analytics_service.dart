import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics ince sarmalayıcısı.
/// Web'de no-op, hata durumunda sessizce geçer — oyunu asla bloklamaz.
class AnalyticsService {
  FirebaseAnalytics? _analytics;

  void init() {
    if (kIsWeb) return;
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (_) {}
  }

  void logGameStart(String characterId, String biome) {
    _safeLog('game_start', {'character': characterId, 'biome': biome});
  }

  void logGameOver(int score, bool isNewHighScore, String characterId) {
    _safeLog('game_over', {
      'score': score,
      'new_high_score': isNewHighScore,
      'character': characterId,
    });
  }

  void logContinue(int currentScore) {
    _safeLog('continue_used', {'score': currentScore});
  }

  void logAdShown(String adType) {
    _safeLog('ad_shown', {'ad_type': adType});
  }

  void logCharacterSelected(String characterId) {
    _safeLog('character_selected', {'character': characterId});
  }

  void logPurchase(String productId) {
    _safeLog('iap_purchase', {'product_id': productId});
  }

  void _safeLog(String name, Map<String, Object> params) {
    if (_analytics == null) return;
    try {
      _analytics!.logEvent(name: name, parameters: params);
    } catch (_) {}
  }
}
