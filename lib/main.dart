import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/ember_wings_game.dart';
import 'game/overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const EmberWingsApp());
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
