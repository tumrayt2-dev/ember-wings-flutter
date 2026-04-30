import 'package:shared_preferences/shared_preferences.dart';

enum ScoreMode { klasik, challenge }

class ScoreService {
  static const String _classicKey = 'high_score';
  static const String _challengeKey = 'high_score_challenge';

  int _classicHigh = 0;
  int _challengeHigh = 0;

  /// Geriye dönük uyumluluk — klasik modun yüksek skoru
  int get highScore => _classicHigh;

  int getHighScore(ScoreMode mode) {
    return mode == ScoreMode.challenge ? _challengeHigh : _classicHigh;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _classicHigh   = prefs.getInt(_classicKey) ?? 0;
    _challengeHigh = prefs.getInt(_challengeKey) ?? 0;
  }

  /// Skoru ilgili moda göre kontrol et, yeni rekor ise kaydet.
  Future<bool> submitScore(int score, {ScoreMode mode = ScoreMode.klasik}) async {
    final current = getHighScore(mode);
    if (score <= current) return false;

    final prefs = await SharedPreferences.getInstance();
    if (mode == ScoreMode.challenge) {
      _challengeHigh = score;
      await prefs.setInt(_challengeKey, score);
    } else {
      _classicHigh = score;
      await prefs.setInt(_classicKey, score);
    }
    return true;
  }
}
