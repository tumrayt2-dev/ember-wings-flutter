import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:games_services/games_services.dart';
import 'score_service.dart';

class LeaderboardService {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  // Google Play Console liderlik tablosu kimlikleri
  static const String _classicLeaderboardId   = 'CgkInfXyq70WEAIQAQ';
  // TODO: Challenge leaderboard'u Play Console'da oluşturulup ID buraya eklenecek
  static const String _challengeLeaderboardId = 'CHALLENGE_LEADERBOARD_ID_PLACEHOLDER';

  String _idFor(ScoreMode mode) {
    return mode == ScoreMode.challenge ? _challengeLeaderboardId : _classicLeaderboardId;
  }

  bool _isValidId(String id) {
    return id.isNotEmpty && !id.contains('PLACEHOLDER');
  }

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await GamesServices.signIn();
      _isSignedIn = true;
    } catch (_) {
      _isSignedIn = false;
    }
  }

  Future<void> submitScore(int score, {ScoreMode mode = ScoreMode.klasik}) async {
    if (!_isSignedIn || kIsWeb) return;
    final id = _idFor(mode);
    if (!_isValidId(id)) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: id,
          value: score,
        ),
      );
    } catch (_) {}
  }

  Future<void> showLeaderboard({ScoreMode mode = ScoreMode.klasik}) async {
    if (!_isSignedIn || kIsWeb) return;
    final id = _idFor(mode);
    if (!_isValidId(id)) return;
    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: id,
      );
    } catch (_) {}
  }
}
