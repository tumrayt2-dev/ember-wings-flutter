import 'package:flutter/material.dart';
import '../models/game_character.dart';
import 'ember_wings_game.dart';

// ==================== ANA MENÜ ====================

class MenuOverlay extends StatefulWidget {
  final EmberWingsGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  late int _currentIndex;
  bool _showLockedPopup = false;
  GameCharacter? _popupCharacter;

  @override
  void initState() {
    super.initState();
    final selectedId = widget.game.characterService.getSelectedCharacter();
    _currentIndex = GameCharacter.all.indexWhere((c) => c.id == selectedId);
    if (_currentIndex < 0) _currentIndex = 0;
  }

  GameCharacter get _selectedCharacter => GameCharacter.all[_currentIndex];
  bool get _isUnlocked =>
      _selectedCharacter.isFree ||
      widget.game.characterService.isOwned(_selectedCharacter.id);

  void _goTo(int index) {
    if (index < 0 || index >= GameCharacter.all.length) return;
    setState(() {
      _currentIndex = index;
      _showLockedPopup = false;
      widget.game.characterService.setSelectedCharacter(
        GameCharacter.all[index].id,
      );
      widget.game.analyticsService.logCharacterSelected(
        GameCharacter.all[index].id.name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final biome = _selectedCharacter.biomeColors;

    return Stack(
      children: [
        // Biom arka planı
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [biome.skyTop, biome.skyBottom, biome.skyAccent],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        // İçerik
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Başlık
              const Text(
                'EMBER WINGS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 10),
                    Shadow(color: Colors.black26, blurRadius: 20),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedCharacter.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              if (widget.game.scoreService.highScore > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events,
                          color: const Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'En İyi: ${widget.game.scoreService.highScore}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              // Karakter adı
              Text(
                _selectedCharacter.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 8)],
                ),
              ),
              const SizedBox(height: 6),
              // Biyom önizleme şeridi
              _BiomeStrip(character: _selectedCharacter),
              const SizedBox(height: 10),
              // Yatay karakter seçici — ok butonları + swipe
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -100) {
                    _goTo(_currentIndex + 1);
                  } else if (details.primaryVelocity! > 100) {
                    _goTo(_currentIndex - 1);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sol ok
                      GestureDetector(
                        onTap: () => _goTo(_currentIndex - 1),
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                          color: _currentIndex > 0
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      // Karakterler
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(GameCharacter.all.length, (index) {
                            final character = GameCharacter.all[index];
                            final isSelected = index == _currentIndex;
                            final isOwned = widget.game.characterService.isOwned(character.id);
                            final isLocked = !character.isFree && !isOwned;

                            return GestureDetector(
                              onTap: () {
                                if (index != _currentIndex) {
                                  _goTo(index);
                                } else if (isLocked) {
                                  setState(() {
                                    _showLockedPopup = true;
                                    _popupCharacter = character;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isSelected ? 56 : 40,
                                height: isSelected ? 56 : 40,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: character.bodyColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.3),
                                          width: isSelected ? 3 : 1.5,
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(
                                                color: character.bodyColor.withValues(alpha: 0.5),
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              )]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: isSelected ? 8 : 6,
                                          height: isSelected ? 8 : 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isLocked)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          size: isSelected ? 22 : 16,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Sağ ok
                      GestureDetector(
                        onTap: () => _goTo(_currentIndex + 1),
                        child: Icon(
                          Icons.chevron_right,
                          size: 30,
                          color: _currentIndex < GameCharacter.all.length - 1
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Sayfa indikatörü
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  GameCharacter.all.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentIndex ? 10 : 6,
                    height: i == _currentIndex ? 10 : 6,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // BAŞLA butonu
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    widget.game.audioService.playButton();
                    if (_isUnlocked) {
                      widget.game.startGame();
                    } else {
                      setState(() {
                        _showLockedPopup = true;
                        _popupCharacter = _selectedCharacter;
                      });
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isUnlocked
                                ? [const Color(0xFFFF4500), const Color(0xFFFF8C00)]
                                : [const Color(0xFF666666), const Color(0xFF444444)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: _isUnlocked
                              ? [BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )]
                              : null,
                        ),
                        child: Text(
                          'BAŞLA',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _isUnlocked
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      if (!_isUnlocked)
                        Positioned(
                          right: 8,
                          child: Icon(
                            Icons.lock,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Sıralama butonu
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: GestureDetector(
                  onTap: () => widget.game.leaderboardService.showLeaderboard(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x44FFFFFF),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0x66FFFFFF)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.leaderboard, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SIRALAMA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Kilitli karakter popup
        if (_showLockedPopup && _popupCharacter != null)
          _LockedCharacterPopup(
            character: _popupCharacter!,
            game: widget.game,
            onClose: () => setState(() => _showLockedPopup = false),
            onStateChanged: () => setState(() {}),
            onStartGame: () => widget.game.startGame(),
          ),
      ],
    );
  }
}

// ==================== KİLİTLİ KARAKTER POPUP ====================

class _LockedCharacterPopup extends StatelessWidget {
  final GameCharacter character;
  final EmberWingsGame game;
  final VoidCallback onClose;
  final VoidCallback onStateChanged;
  final VoidCallback onStartGame;

  const _LockedCharacterPopup({
    required this.character,
    required this.game,
    required this.onStartGame,
    required this.onClose,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = game.characterService.getTotalRemainingGames(character.id);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {}, // popup içi tıklamayı yut
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kapatma alanı
            GestureDetector(
              onTap: onClose,
              child: Container(
                height: 200,
                color: Colors.transparent,
              ),
            ),
            // Popup içeriği
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xF01A0E08),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: Color(0xFFFF8C00), width: 2),
                  left: BorderSide(color: Color(0xFFFF8C00), width: 2),
                  right: BorderSide(color: Color(0xFFFF8C00), width: 2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık satırı
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: character.bodyColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: character.wingColor, width: 2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              character.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              character.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close, color: Colors.white54, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Deneme hakkı varsa — Dene butonu
                  if (remaining > 0)
                    GestureDetector(
                      onTap: onStartGame,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Dene — $remaining hak kaldı',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Video izle butonu
                  GestureDetector(
                    onTap: () {
                      game.analyticsService.logAdShown('rewarded_session_games');
                      game.adService.showRewardedAd(
                        onRewarded: () async {
                          await game.characterService.addSessionGames(character.id);
                          onStateChanged();
                        },
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_fill, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Video İzle — 3 Oyun Hakkı',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Satın al butonu
                  GestureDetector(
                    onTap: () => game.purchaseService.buyCharacter(character.id),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8C00), Color(0xFFFF6D00)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Satın Al — ${game.purchaseService.getSingleCharacterPrice(character.id)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Tümünü al butonu
                  GestureDetector(
                    onTap: () => game.purchaseService.buyBundle(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Tümünü Al — ${game.purchaseService.getBundlePrice()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A0E08),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== GAME OVER ====================

class GameOverOverlay extends StatelessWidget {
  final EmberWingsGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final canContinue = game.canContinue;
    final isAdFree = game.purchaseService.isAdFree;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final horizontalMargin = w * 0.08;
        final padding = w * 0.06;
        final fontSize = (w * 0.035).clamp(11.0, 14.0);

        return Center(
          child: Container(
            padding: EdgeInsets.all(padding),
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              color: const Color(0xDD1A0E08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF4500), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'YANDIN!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4500),
                    shadows: [
                      Shadow(color: Colors.orange, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Skor: ${game.scoreDisplay.score}',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 6),
                if (game.isNewHighScore)
                  const Text(
                    'YENİ REKOR!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      shadows: [Shadow(color: Colors.orange, blurRadius: 8)],
                    ),
                  )
                else
                  Text(
                    'En İyi: ${game.scoreService.highScore}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                const SizedBox(height: 16),
                // Devam et butonu
                if (canContinue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        if (game.purchaseService.isAdFree) {
                          game.continueGame();
                        } else {
                          game.analyticsService.logAdShown('rewarded_continue');
                          game.adService.showRewardedAd(
                            onRewarded: () => game.continueGame(),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isAdFree)
                              const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                            if (!isAdFree)
                              const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isAdFree
                                    ? 'Devam Et'
                                    : 'Devam Et — Video İzle (${game.continuesRemaining})',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Reklamsız paket
                if (!isAdFree)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => game.purchaseService.buyAdFree(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'Reklamsız — ${game.purchaseService.getAdFreePrice()}',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A0E08),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                _FireButton(
                  text: 'TEKRAR DENE',
                  onTap: () => game.startGame(),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => game.goToMenu(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x44FFFFFF),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0x66FFFFFF)),
                    ),
                    child: const Text(
                      'ANA MENÜ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==================== PAUSE ====================

class PauseOverlay extends StatelessWidget {
  final EmberWingsGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: const Color(0xDD1A0E08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF8C00), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DURAKLATILDI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8C00),
                shadows: [
                  Shadow(color: Colors.orange, blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _FireButton(
              text: 'DEVAM ET',
              onTap: () => game.resumeGame(),
            ),
            const SizedBox(height: 16),
            _FireButton(
              text: 'ANA MENÜ',
              onTap: () {
                game.resumeEngine();
                game.goToMenu();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HUD ====================

class GameHud extends StatefulWidget {
  final EmberWingsGame game;
  const GameHud({super.key, required this.game});

  @override
  State<GameHud> createState() => _GameHudState();
}

class _GameHudState extends State<GameHud> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HudButton(
              icon: widget.game.soundEnabled ? Icons.volume_up : Icons.volume_off,
              onTap: () {
                widget.game.toggleSound();
                setState(() {});
              },
            ),
            const SizedBox(width: 10),
            _HudButton(
              icon: Icons.pause,
              onTap: () => widget.game.pauseGame(),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== ORTAK WİDGETLER ====================

class _HudButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HudButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0x88000000),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0x44FF8C00)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _FireButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FireButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BiomeStrip extends StatelessWidget {
  final GameCharacter character;
  const _BiomeStrip({required this.character});

  @override
  Widget build(BuildContext context) {
    final info = _biomeInfo(character.biome);
    final b = character.biomeColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [b.skyTop, b.skyBottom, b.skyAccent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            info.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _BiomeInfo _biomeInfo(String biome) {
    switch (biome) {
      case 'water':
        return const _BiomeInfo(Icons.water_drop, 'BATAKLIK');
      case 'ice':
        return const _BiomeInfo(Icons.ac_unit, 'BUZUL');
      case 'night':
        return const _BiomeInfo(Icons.nightlight_round, 'GECE');
      case 'fire':
      default:
        return const _BiomeInfo(Icons.local_fire_department, 'ALEV');
    }
  }
}

class _BiomeInfo {
  final IconData icon;
  final String label;
  const _BiomeInfo(this.icon, this.label);
}
