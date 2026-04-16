import 'dart:async';
import 'package:flame/game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
      home: _GameScreen(game: game),
    );
  }
}

class _GameScreen extends StatelessWidget {
  final EmberWingsGame game;
  const _GameScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 400 / 800,
                child: GameWidget(
                  game: game,
                  overlayBuilderMap: {
                    'menu': (context, g) => MenuOverlay(game: g as EmberWingsGame),
                    'gameOver': (context, g) => GameOverOverlay(game: g as EmberWingsGame),
                    'pause': (context, g) => PauseOverlay(game: g as EmberWingsGame),
                    'hud': (context, g) => GameHud(game: g as EmberWingsGame),
                    'continue': (context, g) => ContinueOverlay(game: g as EmberWingsGame),
                  },
                ),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: game.showBanner,
            builder: (_, visible, __) => visible
                ? _BannerAdFooter(game: game)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BannerAdFooter extends StatefulWidget {
  final EmberWingsGame game;
  const _BannerAdFooter({required this.game});

  @override
  State<_BannerAdFooter> createState() => _BannerAdFooterState();
}

class _BannerAdFooterState extends State<_BannerAdFooter> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Poll until banner is loaded, then rebuild once
      _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        if (widget.game.adService.isBannerLoaded) {
          _pollTimer?.cancel();
          if (mounted) setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    final ad = widget.game.adService.bannerAd;
    final isLoaded = widget.game.adService.isBannerLoaded;

    if (ad == null || !isLoaded) {
      // Reserve space so layout doesn't jump when ad loads
      return const SizedBox(height: 50, child: ColoredBox(color: Colors.black));
    }

    return SizedBox(
      height: 50,
      child: AdWidget(ad: ad),
    );
  }
}
