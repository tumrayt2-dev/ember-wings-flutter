import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';

class TreeObstacle extends PositionComponent with CollisionCallbacks, HasGameReference<EmberWingsGame> {
  final bool isTop;
  final double treeHeight;
  final int variant;
  final Random _random = Random();
  late List<_EmberSpot> _embers;
  late List<_BarkLine> _barkLines;

  TreeObstacle({
    required this.isTop,
    required this.treeHeight,
    required double x,
    required this.variant,
  }) : super(
    position: Vector2(x, isTop ? 0 : GameConfig.gameHeight - GameConfig.groundHeight - treeHeight),
    size: Vector2(GameConfig.treeWidth, treeHeight),
  ) {
    _embers = List.generate(
      (treeHeight / 30).floor(),
      (_) => _EmberSpot(
        x: _random.nextDouble() * GameConfig.treeWidth,
        y: _random.nextDouble() * treeHeight,
        radius: 2 + _random.nextDouble() * 4,
      ),
    );
    _barkLines = List.generate(
      (treeHeight / 20).floor(),
      (_) => _BarkLine(
        y: _random.nextDouble() * treeHeight,
        width: 10 + _random.nextDouble() * 20,
        x: _random.nextDouble() * (GameConfig.treeWidth - 20),
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;

    position.x -= game.currentSpeed * dt;

    // Ekran dışına çıktıysa kaldır
    if (position.x < -GameConfig.treeWidth) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;

    switch (game.activeBiomeName) {
      case 'water':
        _renderWater(canvas, biome);
        break;
      case 'ice':
        _renderIce(canvas, biome);
        break;
      case 'night':
        _renderNight(canvas, biome);
        break;
      case 'fire':
      default:
        _renderFire(canvas, biome);
    }

    // Boşluğa bakan kenar glow — tüm biyomlarda ortak
    final glowPaint = Paint()
      ..color = biome.treeEmber.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    if (isTop) {
      canvas.drawRect(Rect.fromLTWH(0, size.y - 8, size.x, 8), glowPaint);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 8), glowPaint);
    }
  }

  // Ateş biyomu: yanık ağaç gövdesi + kor noktaları
  void _renderFire(Canvas canvas, biome) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(rect, Paint()..color = biome.treeTrunk);

    // Varyasyon: variant 1 = daha fazla çatlak
    final barkPaint = Paint()
      ..color = Color.lerp(biome.treeTrunk, const Color(0xFF000000), 0.35)!
      ..strokeWidth = variant == 1 ? 3 : 2;
    for (final line in _barkLines) {
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x + line.width, line.y),
        barkPaint,
      );
    }
    for (final ember in _embers) {
      final emberPaint = Paint()
        ..color = biome.treeEmber.withValues(alpha: 0.3 + _random.nextDouble() * 0.5);
      canvas.drawCircle(Offset(ember.x, ember.y), ember.radius, emberPaint);
    }
  }

  // Su biyomu: kamış demeti (dikey ince şeritler)
  void _renderWater(Canvas canvas, biome) {
    final reedCount = variant == 0 ? 4 : 5;
    final reedWidth = size.x / (reedCount + 1);
    final basePaint = Paint()..color = biome.treeTrunk;
    final tipPaint = Paint()..color = biome.treeEmber;

    for (int i = 0; i < reedCount; i++) {
      final cx = reedWidth * (i + 1);
      final sway = (variant == 1 ? 3.0 : 1.5) * sin(i.toDouble());
      final reedRect = Rect.fromLTWH(
        cx - reedWidth * 0.3 + sway,
        0,
        reedWidth * 0.6,
        size.y,
      );
      canvas.drawRect(reedRect, basePaint);
      // Tepe/dip parıltısı
      final tipY = isTop ? size.y - 10 : 0.0;
      canvas.drawCircle(
        Offset(cx + sway, tipY + 5),
        reedWidth * 0.35,
        tipPaint,
      );
    }
  }

  // Buz biyomu: sarkıt/buz sütunu
  void _renderIce(Canvas canvas, biome) {
    final trunkPaint = Paint()..color = biome.treeTrunk;
    final glowPaint = Paint()..color = biome.treeEmber.withValues(alpha: 0.5);

    if (isTop) {
      // Tavandan aşağı sarkan sarkıt: üst geniş, alt sivri
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(size.x, 0)
        ..lineTo(size.x * (variant == 0 ? 0.55 : 0.7), size.y)
        ..lineTo(size.x * (variant == 0 ? 0.45 : 0.3), size.y)
        ..close();
      canvas.drawPath(path, trunkPaint);
      // Parıltı şeridi
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.35, 0, size.x * 0.1, size.y * 0.7),
        glowPaint,
      );
    } else {
      // Yerden yükselen sütun: alt geniş, üst sivri
      final path = Path()
        ..moveTo(0, size.y)
        ..lineTo(size.x, size.y)
        ..lineTo(size.x * (variant == 0 ? 0.65 : 0.8), 0)
        ..lineTo(size.x * (variant == 0 ? 0.35 : 0.2), 0)
        ..close();
      canvas.drawPath(path, trunkPaint);
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.45, size.y * 0.3, size.x * 0.1, size.y * 0.7),
        glowPaint,
      );
    }
  }

  // Gece biyomu: eğri gölge sütun + mor parıltı noktaları
  void _renderNight(Canvas canvas, biome) {
    final trunkPaint = Paint()..color = biome.treeTrunk;
    // Hafif kavisli sütun (variant'a göre yön)
    final lean = variant == 0 ? 4.0 : -4.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.x, 0)
      ..lineTo(size.x + lean, size.y)
      ..lineTo(lean, size.y)
      ..close();
    canvas.drawPath(path, trunkPaint);

    // Mor göz/parıltı noktaları
    for (final ember in _embers) {
      final glowPaint = Paint()
        ..color = biome.treeEmber.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(ember.x, ember.y), ember.radius * 0.8, glowPaint);
    }
  }
}

class _EmberSpot {
  final double x, y, radius;
  _EmberSpot({required this.x, required this.y, required this.radius});
}

class _BarkLine {
  final double y, width, x;
  _BarkLine({required this.y, required this.width, required this.x});
}

class TreePair extends Component with HasWorldReference {
  bool scored = false;
  final double gapCenter;
  final double x;
  final List<TreeObstacle> obstacles = [];

  TreePair({required this.gapCenter, required this.x});

  @override
  Future<void> onLoad() async {
    final topHeight = gapCenter - GameConfig.treeGap / 2;
    final bottomHeight = GameConfig.gameHeight - GameConfig.groundHeight - gapCenter - GameConfig.treeGap / 2;
    final rng = Random();
    final variant = rng.nextInt(2);

    if (topHeight > 0) {
      final top = TreeObstacle(isTop: true, treeHeight: topHeight, x: x, variant: variant);
      obstacles.add(top);
      world.add(top);
    }
    if (bottomHeight > 0) {
      final bottom = TreeObstacle(isTop: false, treeHeight: bottomHeight, x: x, variant: variant);
      obstacles.add(bottom);
      world.add(bottom);
    }
  }

  @override
  void onRemove() {
    for (final o in obstacles) {
      o.removeFromParent();
    }
    super.onRemove();
  }
}
