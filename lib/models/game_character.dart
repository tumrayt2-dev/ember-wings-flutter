import 'dart:ui';

enum CharacterId { phoenix, kingfisher, frostBird, shadow }

class BiomeColors {
  final Color skyTop;
  final Color skyBottom;
  final Color skyAccent;
  final Color treeTrunk;
  final Color treeEmber;
  final Color groundColor;
  final Color groundDark;
  final Color particleColor;

  const BiomeColors({
    required this.skyTop,
    required this.skyBottom,
    required this.skyAccent,
    required this.treeTrunk,
    required this.treeEmber,
    required this.groundColor,
    required this.groundDark,
    required this.particleColor,
  });
}

class GameCharacter {
  final CharacterId id;
  final String name;
  final String description;
  final bool isFree;
  final Color bodyColor;
  final Color wingColor;
  final Color beakColor;
  final String biome;
  final BiomeColors biomeColors;

  const GameCharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.isFree,
    required this.bodyColor,
    required this.wingColor,
    required this.beakColor,
    required this.biome,
    required this.biomeColors,
  });

  String get productId => 'character_${id.name}';

  static const List<GameCharacter> all = [
    GameCharacter(
      id: CharacterId.phoenix,
      name: 'Phoenix',
      description: 'Ateş kuşu — yanan ormandan kaçar',
      isFree: true,
      bodyColor: Color(0xFFFFD700),
      wingColor: Color(0xFFFF8C00),
      beakColor: Color(0xFFFF6600),
      biome: 'fire',
      biomeColors: BiomeColors(
        skyTop: Color(0xFFFF4500),
        skyBottom: Color(0xFFFF8C00),
        skyAccent: Color(0xFFFFAA33),
        treeTrunk: Color(0xFF2C1810),
        treeEmber: Color(0xFFFF4500),
        groundColor: Color(0xFF3D2B1F),
        groundDark: Color(0xFF2C1810),
        particleColor: Color(0xFFFF6347),
      ),
    ),
    GameCharacter(
      id: CharacterId.kingfisher,
      name: 'Kingfisher',
      description: 'Su kuşu — bataklıktan geçer',
      isFree: false,
      bodyColor: Color(0xFF00BCD4),
      wingColor: Color(0xFF0097A7),
      beakColor: Color(0xFFFF9800),
      biome: 'water',
      biomeColors: BiomeColors(
        skyTop: Color(0xFF0D47A1),
        skyBottom: Color(0xFF1B5E20),
        skyAccent: Color(0xFF2E7D32),
        treeTrunk: Color(0xFF2E4F3A),
        treeEmber: Color(0xFF4CAF50),
        groundColor: Color(0xFF3E2723),
        groundDark: Color(0xFF1B3A26),
        particleColor: Color(0xFF80CBC4),
      ),
    ),
    GameCharacter(
      id: CharacterId.frostBird,
      name: 'Frost Bird',
      description: 'Buz kuşu — kış ormanından kaçar',
      isFree: false,
      bodyColor: Color(0xFFE0F7FA),
      wingColor: Color(0xFF80DEEA),
      beakColor: Color(0xFFFFAB40),
      biome: 'ice',
      biomeColors: BiomeColors(
        skyTop: Color(0xFF546E7A),
        skyBottom: Color(0xFFB0BEC5),
        skyAccent: Color(0xFFECEFF1),
        treeTrunk: Color(0xFF455A64),
        treeEmber: Color(0xFF80DEEA),
        groundColor: Color(0xFFCFD8DC),
        groundDark: Color(0xFF90A4AE),
        particleColor: Color(0xFFE0F7FA),
      ),
    ),
    GameCharacter(
      id: CharacterId.shadow,
      name: 'Shadow',
      description: 'Gölge kuşu — gece ormanında süzülür',
      isFree: false,
      bodyColor: Color(0xFF37474F),
      wingColor: Color(0xFF263238),
      beakColor: Color(0xFFB0BEC5),
      biome: 'night',
      biomeColors: BiomeColors(
        skyTop: Color(0xFF0D0D1A),
        skyBottom: Color(0xFF1A1A2E),
        skyAccent: Color(0xFF16213E),
        treeTrunk: Color(0xFF1A1A2E),
        treeEmber: Color(0xFF7C4DFF),
        groundColor: Color(0xFF121212),
        groundDark: Color(0xFF0D0D0D),
        particleColor: Color(0xFFB388FF),
      ),
    ),
  ];

  static GameCharacter getById(CharacterId id) {
    return all.firstWhere((c) => c.id == id);
  }
}
