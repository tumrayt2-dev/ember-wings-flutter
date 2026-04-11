import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _highScoreKey = 'high_score';
  int _highScore = 0;

  int get highScore => _highScore;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Skoru kontrol et, yeni rekor ise kaydet. Yeni rekor olup olmadığını döner.
  Future<bool> submitScore(int score) async {
    if (score <= _highScore) return false;
    _highScore = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
    return true;
  }
}
