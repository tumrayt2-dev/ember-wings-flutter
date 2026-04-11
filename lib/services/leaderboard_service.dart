import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:games_services/games_services.dart';

class LeaderboardService {
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  // Google Play Console'da oluşturulacak leaderboard ID'si
  static const String leaderboardId = 'CgkI_LEADERBOARD_ID'; // TODO: Gerçek ID ile değiştir

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await GamesServices.signIn();
      _isSignedIn = true;
    } catch (_) {
      _isSignedIn = false;
    }
  }

  Future<void> submitScore(int score) async {
    if (!_isSignedIn || kIsWeb) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
    } catch (_) {}
  }

  Future<void> showLeaderboard() async {
    if (!_isSignedIn || kIsWeb) return;
    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: leaderboardId,
      );
    } catch (_) {}
  }
}
