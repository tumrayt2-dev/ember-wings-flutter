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

  // Cached Paint nesneleri — her frame yeniden oluşturulmaz
  final Paint _trunkPaint = Paint();
  final Paint _barkPaint = Paint();
  final Paint _emberPaint = Paint();
  final Paint _glowPaint = Paint();
  final Paint _tipPaint = Paint();
  // Gece biyomu blur paint — ayrı tutulur, maskFilter sabit
  final Paint _nightGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  // Kenar glow paint — blur sabit
  final Paint _edgeGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  // Cached Path nesneleri (ice/night biyomları)
  final Path _shapePath = Path();

  // Cached Rect (glow kenar, trunk rect)
  late final Rect _glowRectTop;
  late final Rect _glowRectBottom;
  late final Rect _trunkRect;

  // Ember alpha değerleri — constructor'da hesaplanır, render'da kullanılır
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

    // Ember alpha değerlerini önceden hesapla
    _emberAlphas = List.generate(
      _embers.length,
      (_) => 0.3 + rng.nextDouble() * 0.5,
    );

    // Sabit rect'leri önceden hesapla
    _glowRectTop = Rect.fromLTWH(0, treeHeight - 8, GameConfig.treeWidth, 8);
    _glowRectBottom = const Rect.fromLTWH(0, 0, GameConfig.treeWidth, 8);
    _trunkRect = Rect.fromLTWH(0, 0, GameConfig.treeWidth, treeHeight);
  }

  @override
  Future<void> onLoad() async {
    if (game.activeBiomeName == 'ice') {
      add(PolygonHitbox(_iceVertices()));
    } else {
      add(RectangleHitbox());
    }
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

    // Ekran dışına çıktıysa kaldır
    if (position.x < -GameConfig.treeWidth) {
      removeFromParent();
    }
  }

  // Biyom renk cache — biyom değişmedikçe Color nesneleri yeniden oluşturulmaz
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
    _cachedGlowColor015 = Color.fromARGB(38, r, g, b);
    _cachedGlowColor050 = Color.fromARGB(128, r, g, b);
    _cachedEmberColor060 = Color.fromARGB(153, r, g, b);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final biome = game.activeBiome;
    _updateBiomeCache(biome);

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
    _edgeGlowPaint.color = _cachedGlowColor015!;
    canvas.drawRect(isTop ? _glowRectTop : _glowRectBottom, _edgeGlowPaint);
  }

  // Ateş biyomu: yanık ağaç gövdesi + kor noktaları
  void _renderFire(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    canvas.drawRect(_trunkRect, _trunkPaint);

    _barkPaint
      ..color = _cachedBarkColor!
      ..strokeWidth = variant == 1 ? 3 : 2;
    for (final line in _barkLines) {
      canvas.drawLine(
        Offset(line.x, line.y),
        Offset(line.x + line.width, line.y),
        _barkPaint,
      );
    }

    final ember = biome.treeEmber;
    final r = ember.r.toInt();
    final g = ember.g.toInt();
    final b = ember.b.toInt();
    for (int i = 0; i < _embers.length; i++) {
      final e = _embers[i];
      _emberPaint.color = Color.fromARGB((_emberAlphas[i] * 255).toInt(), r, g, b);
      canvas.drawCircle(Offset(e.x, e.y), e.radius, _emberPaint);
    }
  }

  // Su biyomu: kamış demeti (dikey ince şeritler)
  void _renderWater(Canvas canvas, BiomeColors biome) {
    final reedCount = variant == 0 ? 4 : 5;
    final reedWidth = size.x / (reedCount + 1);
    _trunkPaint.color = biome.treeTrunk;
    _tipPaint.color = biome.treeEmber;

    for (int i = 0; i < reedCount; i++) {
      final cx = reedWidth * (i + 1);
      final sway = (variant == 1 ? 3.0 : 1.5) * sin(i.toDouble());
      canvas.drawRect(
        Rect.fromLTWH(cx - reedWidth * 0.3 + sway, 0, reedWidth * 0.6, size.y),
        _trunkPaint,
      );
      final tipY = isTop ? size.y - 10 : 0.0;
      canvas.drawCircle(
        Offset(cx + sway, tipY + 5),
        reedWidth * 0.35,
        _tipPaint,
      );
    }
  }

  // Buz biyomu: sarkıt/buz sütunu
  void _renderIce(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    _glowPaint.color = _cachedGlowColor050!;

    _shapePath.reset();
    if (isTop) {
      _shapePath.moveTo(0, 0);
      _shapePath.lineTo(size.x, 0);
      _shapePath.lineTo(size.x * (variant == 0 ? 0.55 : 0.7), size.y);
      _shapePath.lineTo(size.x * (variant == 0 ? 0.45 : 0.3), size.y);
      _shapePath.close();
      canvas.drawPath(_shapePath, _trunkPaint);
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.35, 0, size.x * 0.1, size.y * 0.7),
        _glowPaint,
      );
    } else {
      _shapePath.moveTo(0, size.y);
      _shapePath.lineTo(size.x, size.y);
      _shapePath.lineTo(size.x * (variant == 0 ? 0.65 : 0.8), 0);
      _shapePath.lineTo(size.x * (variant == 0 ? 0.35 : 0.2), 0);
      _shapePath.close();
      canvas.drawPath(_shapePath, _trunkPaint);
      canvas.drawRect(
        Rect.fromLTWH(size.x * 0.45, size.y * 0.3, size.x * 0.1, size.y * 0.7),
        _glowPaint,
      );
    }
  }

  // Gece biyomu: eğri gölge sütun + mor parıltı noktaları
  void _renderNight(Canvas canvas, BiomeColors biome) {
    _trunkPaint.color = biome.treeTrunk;
    final lean = variant == 0 ? 4.0 : -4.0;

    _shapePath.reset();
    _shapePath.moveTo(0, 0);
    _shapePath.lineTo(size.x, 0);
    _shapePath.lineTo(size.x + lean, size.y);
    _shapePath.lineTo(lean, size.y);
    _shapePath.close();
    canvas.drawPath(_shapePath, _trunkPaint);

    // Mor göz/parıltı noktaları
    _nightGlowPaint.color = _cachedEmberColor060!;
    for (final ember in _embers) {
      canvas.drawCircle(Offset(ember.x, ember.y), ember.radius * 0.8, _nightGlowPaint);
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
