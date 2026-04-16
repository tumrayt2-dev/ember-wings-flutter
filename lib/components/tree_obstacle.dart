import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../config/game_config.dart';
import '../game/ember_wings_game.dart';
import '../models/game_character.dart';

class TreeObstacle extends PositionComponent with CollisionCallbacks, HasGameReference<EmberWingsGame> {
  final bool isTop;
  final double treeHeight;
  final int variant;
  late List<_EmberSpot> _embers;
  late List<_BarkLine> _barkLines;

  // Cached Paint nesneleri
  final Paint _trunkPaint = Paint();
  final Paint _barkPaint = Paint();
  final Paint _emberPaint = Paint();
  final Paint _glowPaint = Paint();
  final Paint _tipPaint = Paint();
  final Paint _nightGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  final Paint _edgeGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  // Pre-computed shapes — onLoad'da bir kez hesaplanır, render'da kullanılır
  late final Path _iceShapePath;
  late final Rect _iceGlowRect;
  late final Path _nightShapePath;

  // Pre-computed water reed geometry
  late final int _reedCount;
  late final List<Rect> _reedBodyRects;
  late final List<Offset> _reedTipOffsets;
  late final double _reedTipRadius;

  // Cached Rect (edge glow, trunk)
  late final Rect _glowRectTop;
  late final Rect _glowRectBottom;
  late final Rect _trunkRect;

  // Ember alpha değerleri
  late final List<double> _emberAlphas;

  TreeObstacle({
    required this.isTop,
    required this.treeHeight,
    required double x,
    required this.variant,
  }) : super(
    position: Vector2(x, isTop ? 0 : GameConfig.gameHeight - GameConfig.groundHeight - treeHeight),
    size: Vector2(GameConfig.treeWidth, treeHeight),
  ) {
    final rng = Random();
    _embers = List.generate(
      (treeHeight / 30).floor(),
      (_) => _EmberSpot(
        x: rng.nextDouble() * GameConfig.treeWidth,
        y: rng.nextDouble() * treeHeight,
        radius: 2 + rng.nextDouble() * 4,
      ),
    );
    _barkLines = List.generate(
      (treeHeight / 20).floor(),
      (_) => _BarkLine(
        y: rng.nextDouble() * treeHeight,
        width: 10 + rng.nextDouble() * 20,
        x: rng.nextDouble() * (GameConfig.treeWidth - 20),
      ),
    );

    _emberAlphas = List.generate(
      _embers.length,
      (_) => 0.3 + rng.nextDouble() * 0.5,
    );

    _glowRectTop    = Rect.fromLTWH(0, treeHeight - 8, GameConfig.treeWidth, 8);
    _glowRectBottom = const Rect.fromLTWH(0, 0, GameConfig.treeWidth, 8);
    _trunkRect      = Rect.fromLTWH(0, 0, GameConfig.treeWidth, treeHeight);
  }

  @override
  Future<void> onLoad() async {
    _precomputeShapes();
    if (game.activeBiomeName == 'ice') {
      add(PolygonHitbox(_iceVertices()));
    } else {
      add(RectangleHitbox());
    }
  }

  // Tüm biyom shape'leri ve water reed geometrisi — her instance için bir kez çalışır
  void _precomputeShapes() {
    final w = size.x;
    final h = size.y;

    // ── Ice: trapezoid path ────────────────────────────────────────────
    _iceShapePath = Path();
    if (isTop) {
      final rRight = variant == 0 ? 0.55 : 0.70;
      final rLeft  = variant == 0 ? 0.45 : 0.30;
      _iceShapePath
        ..moveTo(0, 0)
        ..lineTo(w, 0)
        ..lineTo(w * rRight, h)
        ..lineTo(w * rLeft, h)
        ..close();
      _iceGlowRect = Rect.fromLTWH(w * 0.35, 0, w * 0.1, h * 0.7);
    } else {
      final rRight = variant == 0 ? 0.65 : 0.80;
      final rLeft  = variant == 0 ? 0.35 : 0.20;
      _iceShapePath
        ..moveTo(0, h)
        ..lineTo(w, h)
        ..lineTo(w * rRight, 0)
        ..lineTo(w * rLeft, 0)
        ..close();
      _iceGlowRect = Rect.fromLTWH(w * 0.45, h * 0.3, w * 0.1, h * 0.7);
    }

    // ── Night: eğri sütun path ─────────────────────────────────────────
    final lean = variant == 0 ? 4.0 : -4.0;
    _nightShapePath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w + lean, h)
      ..lineTo(lean, h)
      ..close();

    // ── Water: reed geometry ───────────────────────────────────────────
    _reedCount = variant == 0 ? 4 : 5;
    final reedW = w / (_reedCount + 1);
    _reedTipRadius = reedW * 0.35;
    final swayScale = variant == 1 ? 3.0 : 1.5;
    final tipY = isTop ? h - 5.0 : 5.0;

    _reedBodyRects = List.generate(_reedCount, (i) {
      final cx   = reedW * (i + 1);
      final sway = swayScale * sin(i.toDouble());
      return Rect.fromLTWH(cx - reedW * 0.3 + sway, 0, reedW * 0.6, h);
    });

    _reedTipOffsets = List.generate(_reedCount, (i) {
      final cx   = reedW * (i + 1);
      final sway = swayScale * sin(i.toDouble());
      return Offset(cx + sway, tipY);
    });

    // Bark stroke width — variant'a göre sabit
    _barkPaint.strokeWidth = variant == 1 ? 3.0 : 2.0;
  }

  List<Vector2> _iceVertices() {
    final w = size.x;
    final h = size.y;
    if (isTop) {
      final rRight = variant == 0 ? 0.55 : 0.70;
      final rLeft  = variant == 0 ? 0.45 : 0.30;
      return [Vector2(0, 0), Vector2(w, 0), Vector2(w * rRight, h), Vector2(w * rLeft, h)];
    } else {
      final rRight = variant == 0 ? 0.65 : 0.80;
      final rLeft  = variant == 0 ? 0.35 : 0.20;
      return [Vector2(w * rLeft, 0), Vector2(w * rRight, 0), Vector2(w, h), Vector2(0, h)];
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.state != GameState.playing) return;
    position.x -= game.currentSpeed * dt;
    if (position.x < -GameConfig.treeWidth) removeFromParent();
  }

  // Biyom renk cache
  Color? _lastBiomeTrunk;
  Color? _cachedBarkColor;
  Color? _cachedGlowColor015;
  Color? _cachedGlowColor050;
  Color? _cachedEmberColor060;

  void _updateBiomeCache(BiomeColors biome) {
    if (_lastBiomeTrunk == biome.treeTrunk) return;
    _lastBiomeTrunk = biome.treeTrunk;
    _cachedBarkColor = Color.lerp(biome.treeTrunk, const Color(0xFF000000), 0.35)!;

    final ember = biome.treeEmber;
    final r = ember.r.toInt();
    final g = ember.g.toInt();
    final b = ember.b.toInt();
    _cachedGlowColor015 = Color.fromARGB(38,  r, g, b);
    _cachedGlowColor050 = Color.fromARGB(128, r, g, b);
    _cachedEmberColor060 = Color.fromARGB(153, r, g, b);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;
    _updateBiomeCache(biome);

    switch (game.activeBiomeName) {
      case 'water': _renderWater(canvas, biome); break;
      case 'ice':   _renderIce(canvas, biome);   break;
      case 'night': _renderNight(canvas, biome); break;
      case 'fire':
      default:      _renderFire(canvas, biome);
    }

    _edgeGlowPaint.color = _cachedGlowColor015!;
    canvas.drawRect(isTop ? _glowRectTop : _glowRectBottom, _edgeGlowPaint);
  }

  void _renderFire(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    canvas.drawRect(_trunkRect, _trunkPaint);

    _barkPaint.color = _cachedBarkColor!;
    for (final line in _barkLines) {
      canvas.drawLine(line.start, line.end, _barkPaint);
    }

    final ember = biome.treeEmber;
    final r = ember.r.toInt();
    final g = ember.g.toInt();
    final b = ember.b.toInt();
    for (int i = 0; i < _embers.length; i++) {
      _emberPaint.color = Color.fromARGB((_emberAlphas[i] * 255).toInt(), r, g, b);
      canvas.drawCircle(_embers[i].offset, _embers[i].radius, _emberPaint);
    }
  }

  void _renderWater(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    _tipPaint.color   = biome.treeEmber;
    for (int i = 0; i < _reedCount; i++) {
      canvas.drawRect(_reedBodyRects[i], _trunkPaint);
      canvas.drawCircle(_reedTipOffsets[i], _reedTipRadius, _tipPaint);
    }
  }

  void _renderIce(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    _glowPaint.color  = _cachedGlowColor050!;
    canvas.drawPath(_iceShapePath, _trunkPaint);
    canvas.drawRect(_iceGlowRect, _glowPaint);
  }

  void _renderNight(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    canvas.drawPath(_nightShapePath, _trunkPaint);
    _nightGlowPaint.color = _cachedEmberColor060!;
    for (final ember in _embers) {
      canvas.drawCircle(ember.offset, ember.nightRadius, _nightGlowPaint);
    }
  }
}

class _EmberSpot {
  final double x, y, radius;
  final Offset offset;
  final double nightRadius;

  _EmberSpot({required this.x, required this.y, required this.radius})
      : offset      = Offset(x, y),
        nightRadius = radius * 0.8;
}

class _BarkLine {
  final double y, width, x;
  final Offset start;
  final Offset end;

  _BarkLine({required this.y, required this.width, required this.x})
      : start = Offset(x, y),
        end   = Offset(x + width, y);
}

class TreePair extends Component with HasWorldReference {
  bool scored = false;
  final double gapCenter;
  final double x;
  final List<TreeObstacle> obstacles = [];

  TreePair({required this.gapCenter, required this.x});

  @override
  Future<void> onLoad() async {
    final topHeight    = gapCenter - GameConfig.treeGap / 2;
    final bottomHeight = GameConfig.gameHeight - GameConfig.groundHeight - gapCenter - GameConfig.treeGap / 2;
    final rng     = Random();
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
