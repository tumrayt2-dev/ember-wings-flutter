import 'dart:ui';

class GameConfig {
  // Ekran
  static const double gameWidth = 400;
  static const double gameHeight = 800;

  // Kuş
  static const double birdSize = 30;
  static const double birdX = 80;
  static const double gravity = 900;
  static const double jumpForce = -350;
  static const double maxVelocity = 500;

  // Engeller (yanmış ağaçlar)
  static const double treeWidth = 60;
  static const double treeGap = 160; // geçiş boşluğu
  static const double treeSpeed = 150;
  static const double treeSpawnInterval = 1.6; // saniye
  static const double minTreeHeight = 80;

  // Zemin
  static const double groundHeight = 80;
  static const double groundSpeed = 150;

  // Renkler - Yanık Orman Teması
  static const Color skyTop = Color(0xFFFF4500); // koyu turuncu
  static const Color skyBottom = Color(0xFFFF8C00); // açık turuncu
  static const Color treeTrunk = Color(0xFF2C1810); // yanmış kahverengi
  static const Color treeBark = Color(0xFF1A0E08); // koyu yanık
  static const Color treeEmber = Color(0xFFFF4500); // kor turuncu
  static const Color groundColor = Color(0xFF3D2B1F); // yanmış toprak
  static const Color groundDark = Color(0xFF2C1810); // koyu toprak
  static const Color ashColor = Color(0xFF696969); // kül grisi
  static const Color birdBody = Color(0xFFFFD700); // altın sarısı
  static const Color birdWing = Color(0xFFFF8C00); // turuncu kanat
  static const Color birdEye = Color(0xFF000000);
  static const Color emberParticle = Color(0xFFFF6347); // kıvılcım
  static const Color smokeColor = Color(0x88696969); // duman
}
