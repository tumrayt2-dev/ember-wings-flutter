import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

/// Deterministik zemin deseni için önceden hesaplanmış veriler.
class _DirtTile {
  final double offsetX;
  final double width;
  _DirtTile(this.offsetX, this.width);
}

class _EmberDot {
  final double offsetX;
  final double offsetY;
  final double radius;
  _EmberDot(this.offsetX, this.offsetY, this.radius);
}

class Ground extends PositionComponent with CollisionCallbacks, HasGameReference<EmberWingsGame> {
  double _scrollOffset = 0;

  // Cached Paint nesneleri
  final Paint _groundPaint = Paint();
  final Paint _ashPaint = Paint()..strokeWidth = 3;
  final Paint _darkPaint = Paint();
  final Paint _emberPaint = Paint();

  // Cached Offset (sabit)
  static const Offset _lineStart = Offset(0, 2);

  // Önceden hesaplanmış deterministik desenler
  late final List<List<_DirtTile>> _dirtRows;
  late final List<_EmberDot> _emberDots;

  // Biyom renk cache — sadece biyom değişince güncellenir
  Color? _cachedAshColor;
  Color? _cachedEmberColor;

  Ground() : super(
    position: Vector2(0, GameConfig.gameHeight - GameConfig.groundHeight),
    size: Vector2(GameConfig.gameWidth, GameConfig.groundHeight),
    priority: 5,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _precomputePatterns();
  }

  void _precomputePatterns() {
    // Toprak deseni — 40px tile başına satırlar
    // Ekranın 2 katı genişliğinde tile üret (scroll için)
    final tileCount = (size.x / 40).ceil() + 2;
    final rng = Random(42);
    final rowCount = ((size.y - 10) / 15).ceil();

    _dirtRows = List.generate(rowCount, (_) {
      return List.generate(tileCount, (_) {
        return _DirtTile(
          rng.nextDouble() * 10,
          12 + rng.nextDouble() * 8,
        );
      });
    });

    // Kor noktaları
    final emberCount = (size.x / 60).ceil() + 2;
    final rng2 = Random(123);
    _emberDots = List.generate(emberCount, (_) {
      return _EmberDot(
        rng2.nextDouble() * 30,
        6 + rng2.nextDouble() * 8,
        1.5 + rng2.nextDouble() * 2,
      );
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;
    _scrollOffset += game.currentSpeed * dt;
    if (_scrollOffset > 40) _scrollOffset -= 40;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;

    // Ana zemin
    _groundPaint.color = biome.groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _groundPaint);

    // Üst kenar - biyom renk cache
    final ashColor = biome.treeEmber;
    if (_cachedAshColor != ashColor) {
      _cachedAshColor = ashColor;
      _ashPaint.color = Color.fromARGB(204, ashColor.r.toInt(), ashColor.g.toInt(), ashColor.b.toInt());
      _cachedEmberColor = Color.fromARGB(102, ashColor.r.toInt(), ashColor.g.toInt(), ashColor.b.toInt());
      _emberPaint.color = _cachedEmberColor!;
    }
    canvas.drawLine(_lineStart, Offset(size.x, 2), _ashPaint);

    // Koyu toprak deseni — önceden hesaplanmış
    _darkPaint.color = biome.groundDark;
    for (int row = 0; row < _dirtRows.length; row++) {
      final y = 10.0 + row * 15;
      final tiles = _dirtRows[row];
      int tileIdx = 0;
      for (double x = -_scrollOffset; x < size.x + 40; x += 40) {
        if (tileIdx >= tiles.length) break;
        final tile = tiles[tileIdx++];
        canvas.drawRect(
          Rect.fromLTWH(x + tile.offsetX, y, tile.width, 3),
          _darkPaint,
        );
      }
    }

    // Kor parçaları
    int dotIdx = 0;
    for (double x = -_scrollOffset; x < size.x + 40; x += 60) {
      if (dotIdx >= _emberDots.length) break;
      final dot = _emberDots[dotIdx++];
      canvas.drawCircle(
        Offset(x + dot.offsetX, dot.offsetY),
        dot.radius,
        _emberPaint,
      );
    }
  }
}
