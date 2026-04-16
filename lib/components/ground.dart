import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

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
  final Paint _ashPaint    = Paint()..strokeWidth = 3;
  final Paint _darkPaint   = Paint();
  final Paint _emberPaint  = Paint();

  static const Offset _lineStart = Offset(0, 2);

  // Önceden hesaplanmış ham veriler (scrollOffset hesabı için)
  late final List<List<_DirtTile>> _dirtRows;
  late final List<_EmberDot> _emberDots;

  // Pre-computed Rect / Offset — canvas.translate ile render'da sıfır allocation
  late final List<List<Rect>> _dirtRects;
  late final List<Offset> _emberOffsets;

  // Zemin base rect
  late final Rect _baseRect;

  // Biyom renk cache
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
    _baseRect = Rect.fromLTWH(0, 0, size.x, size.y);

    final tileCount = (size.x / 40).ceil() + 2;
    final rng       = Random(42);
    final rowCount  = ((size.y - 10) / 15).ceil();

    // Ham veriler
    _dirtRows = List.generate(rowCount, (_) {
      return List.generate(tileCount, (_) {
        return _DirtTile(rng.nextDouble() * 10, 12 + rng.nextDouble() * 8);
      });
    });

    final emberCount = (size.x / 60).ceil() + 2;
    final rng2 = Random(123);
    _emberDots = List.generate(emberCount, (_) {
      return _EmberDot(rng2.nextDouble() * 30, 6 + rng2.nextDouble() * 8, 1.5 + rng2.nextDouble() * 2);
    });

    // Pre-computed Rect'ler — x pozisyonu tile index bazlı (canvas.translate scroll'ı halleder)
    _dirtRects = List.generate(rowCount, (row) {
      final y = 10.0 + row * 15;
      return List.generate(tileCount, (i) {
        final tile = _dirtRows[row][i];
        return Rect.fromLTWH(i * 40.0 + tile.offsetX, y, tile.width, 3);
      });
    });

    // Pre-computed ember Offset'leri
    _emberOffsets = List.generate(emberCount, (i) {
      final dot = _emberDots[i];
      return Offset(i * 60.0 + dot.offsetX, dot.offsetY);
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
    canvas.drawRect(_baseRect, _groundPaint);

    // Üst kenar — biyom renk cache
    final ashColor = biome.treeEmber;
    if (_cachedAshColor != ashColor) {
      _cachedAshColor = ashColor;
      _ashPaint.color   = Color.fromARGB(204, ashColor.r.toInt(), ashColor.g.toInt(), ashColor.b.toInt());
      _cachedEmberColor = Color.fromARGB(102, ashColor.r.toInt(), ashColor.g.toInt(), ashColor.b.toInt());
      _emberPaint.color = _cachedEmberColor!;
    }
    canvas.drawLine(_lineStart, Offset(size.x, 2), _ashPaint);

    // Koyu toprak + kor — canvas.translate ile Rect/Offset allocation yok
    _darkPaint.color = biome.groundDark;
    canvas.save();
    canvas.translate(-_scrollOffset, 0);

    for (final rowRects in _dirtRects) {
      for (final rect in rowRects) {
        canvas.drawRect(rect, _darkPaint);
      }
    }

    for (int i = 0; i < _emberDots.length; i++) {
      canvas.drawCircle(_emberOffsets[i], _emberDots[i].radius, _emberPaint);
    }

    canvas.restore();
  }
}
