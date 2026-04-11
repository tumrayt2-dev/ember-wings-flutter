import 'dart:async';
import 'package:flame/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/ember_wings_game.dart';
import 'game/overlays.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Firebase (web'de atla — Android native)
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp();
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (_) {
        // Firebase init hatası oyunu bloklamasın
      }
    }

    runApp(const EmberWingsApp());
  }, (error, stack) {
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

class EmberWingsApp extends StatelessWidget {
  const EmberWingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final game = EmberWingsGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: 400 / 800, // gameWidth / gameHeight
            child: GameWidget(
              game: game,
              overlayBuilderMap: {
                'menu': (context, game) => MenuOverlay(game: game as EmberWingsGame),
                'gameOver': (context, game) => GameOverOverlay(game: game as EmberWingsGame),
                'pause': (context, game) => PauseOverlay(game: game as EmberWingsGame),
                'hud': (context, game) => GameHud(game: game as EmberWingsGame),
              },
            ),
          ),
        ),
      ),
    );
  }
}
