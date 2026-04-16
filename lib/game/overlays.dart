import 'package:flutter/material.dart';
import '../models/game_character.dart';
import '../services/locale_service.dart';
import 'ember_wings_game.dart';

String _t(EmberWingsGame game, String key, [Map<String, String>? params]) {
  var s = game.localeService.get(key);
  params?.forEach((k, v) => s = s.replaceAll('{$k}', v));
  return s;
}

// ==================== ANA MENÜ ====================

class MenuOverlay extends StatefulWidget {
  final EmberWingsGame game;
  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  late int _currentIndex;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    final selectedId = widget.game.characterService.getSelectedCharacter();
    _currentIndex = GameCharacter.all.indexWhere((c) => c.id == selectedId);
    if (_currentIndex < 0) _currentIndex = 0;
  }

  GameCharacter get _selectedCharacter => GameCharacter.all[_currentIndex];

  void _goTo(int index) {
    final len = GameCharacter.all.length;
    final wrapped = ((index % len) + len) % len;
    setState(() {
      _currentIndex = wrapped;
      widget.game.characterService.setSelectedCharacter(GameCharacter.all[wrapped].id);
      widget.game.analyticsService.logCharacterSelected(GameCharacter.all[wrapped].id.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final biome = _selectedCharacter.biomeColors;

    return Stack(
      children: [
        // Biyom arka planı
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
        // Sağ üst ayarlar butonu
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => setState(() => _showSettings = true),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: Icon(Icons.settings, color: Colors.white.withValues(alpha: 0.5), size: 22),
                ),
              ),
            ),
          ),
        ),
        // İçerik
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                _t(widget.game, 'appTitle'),
                style: const TextStyle(
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
                _t(widget.game, 'desc_${_selectedCharacter.id.name}'),
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
              ),
              if (widget.game.scoreService.highScore > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${_t(widget.game, 'bestScore')}: ${widget.game.scoreService.highScore}',
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
              _BiomeStrip(character: _selectedCharacter, game: widget.game),
              const SizedBox(height: 10),
              // Karakter seçici
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity == null) return;
                  if (details.primaryVelocity! < -100) { _goTo(_currentIndex + 1); }
                  else if (details.primaryVelocity! > 100) { _goTo(_currentIndex - 1); }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _goTo(_currentIndex - 1),
                        child: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(GameCharacter.all.length, (index) {
                            final character = GameCharacter.all[index];
                            final isSelected = index == _currentIndex;
                            return GestureDetector(
                              onTap: () => _goTo(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isSelected ? 56 : 40,
                                height: isSelected ? 56 : 40,
                                decoration: BoxDecoration(
                                  color: character.bodyColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
                                    width: isSelected ? 3 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(
                                          color: character.bodyColor.withValues(alpha: 0.5),
                                          blurRadius: 12, spreadRadius: 2,
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
                            );
                          }),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _goTo(_currentIndex + 1),
                        child: const Icon(Icons.chevron_right, size: 30, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              // Sayfa indikatörü
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(GameCharacter.all.length, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentIndex ? 10 : 6,
                    height: i == _currentIndex ? 10 : 6,
                    decoration: BoxDecoration(
                      color: i == _currentIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
              ),
              const Spacer(),
              // BAŞLA butonu
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
                    widget.game.audioService.playButton();
                    widget.game.startGame();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.5),
                          blurRadius: 15, spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _t(widget.game, 'start'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.leaderboard, color: Color(0xFFFFD700), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _t(widget.game, 'leaderboard'),
                          style: const TextStyle(
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
        // Ayarlar popup
        if (_showSettings)
          _SettingsPopup(
            game: widget.game,
            onClose: () => setState(() => _showSettings = false),
            onChanged: () => setState(() {}),
          ),
      ],
    );
  }
}

// ==================== GAME OVER ====================

class GameOverOverlay extends StatelessWidget {
  final EmberWingsGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final fontSize = (w * 0.035).clamp(11.0, 14.0);

        return Center(
          child: Container(
            padding: EdgeInsets.all(w * 0.06),
            margin: EdgeInsets.symmetric(horizontal: w * 0.08),
            decoration: BoxDecoration(
              color: const Color(0xDD1A0E08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF4500), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _t(game, 'gameOver'),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4500),
                    shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_t(game, 'score')}: ${game.scoreDisplay.score}',
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 6),
                if (game.isNewHighScore)
                  Text(
                    _t(game, 'newRecord'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                      shadows: [Shadow(color: Colors.orange, blurRadius: 8)],
                    ),
                  )
                else
                  Text(
                    '${_t(game, 'bestScore')}: ${game.scoreService.highScore}',
                    style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                const SizedBox(height: 16),
                // Canlanma butonu
                if (game.canContinue)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        game.analyticsService.logAdShown('rewarded_continue');
                        game.adService.showRewardedAd(
                          onRewarded: () => game.prepareContinue(),
                        );
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
                            const Icon(Icons.play_circle_fill, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _t(game, 'reviveVideo', {'n': '${game.continuesRemaining}'}),
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
                const SizedBox(height: 4),
                _FireButton(
                  text: _t(game, 'retry'),
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
                    child: Text(
                      _t(game, 'mainMenu'),
                      style: const TextStyle(
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
            Text(
              _t(game, 'paused'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8C00),
                shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 30),
            _FireButton(text: _t(game, 'resume'), onTap: () => game.resumeGame()),
            const SizedBox(height: 16),
            _FireButton(
              text: _t(game, 'mainMenu'),
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
            _HudButton(icon: Icons.pause, onTap: () => widget.game.pauseGame()),
          ],
        ),
      ),
    );
  }
}

// ==================== DEVAM ET ====================

class ContinueOverlay extends StatelessWidget {
  final EmberWingsGame game;
  const ContinueOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _t(game, 'getReady'),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_t(game, 'score')}: ${game.scoreDisplay.score}',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => game.executeContinue(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                    blurRadius: 15, spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                _t(game, 'continueGame'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
            BoxShadow(color: Colors.orange.withValues(alpha: 0.5), blurRadius: 15),
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

// ==================== AYARLAR POPUP ====================

class _SettingsPopup extends StatelessWidget {
  final EmberWingsGame game;
  final VoidCallback onClose;
  final VoidCallback onChanged;

  const _SettingsPopup({required this.game, required this.onClose, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isTr = game.localeService.locale == AppLocale.tr;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: const Color(0x88000000),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xF01A0E08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFF8C00), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings, color: Colors.white70, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        _t(game, 'settings'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onClose,
                        child: const Icon(Icons.close, color: Colors.white54, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SettingsRow(
                    icon: game.soundEnabled ? Icons.volume_up : Icons.volume_off,
                    label: _t(game, 'sound'),
                    value: game.soundEnabled ? _t(game, 'soundOn') : _t(game, 'soundOff'),
                    onTap: () { game.toggleSound(); onChanged(); },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.language, color: Color(0xFFFF8C00), size: 22),
                      const SizedBox(width: 12),
                      Text(
                        _t(game, 'language'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _LanguageOption(
                          label: 'Türkçe', flag: '🇹🇷', isSelected: isTr,
                          onTap: () { game.localeService.setLocale(AppLocale.tr); onChanged(); },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LanguageOption(
                          label: 'English', flag: '🇬🇧', isSelected: !isTr,
                          onTap: () { game.localeService.setLocale(AppLocale.en); onChanged(); },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0x33FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x44FFFFFF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF8C00), size: 22),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x44FF8C00),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x44FF8C00) : const Color(0x22FFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF8C00) : const Color(0x33FFFFFF),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF8C00) : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BiomeStrip extends StatelessWidget {
  final GameCharacter character;
  final EmberWingsGame game;
  const _BiomeStrip({required this.character, required this.game});

  @override
  Widget build(BuildContext context) {
    final info = _biomeInfo(character.biome);
    final b = character.biomeColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [b.skyTop, b.skyBottom, b.skyAccent]),
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
      case 'water': return _BiomeInfo(Icons.water_drop, _t(game, 'biomeWater'));
      case 'ice':   return _BiomeInfo(Icons.ac_unit, _t(game, 'biomeIce'));
      case 'night': return _BiomeInfo(Icons.nightlight_round, _t(game, 'biomeNight'));
      default:      return _BiomeInfo(Icons.local_fire_department, _t(game, 'biomeFire'));
    }
  }
}

class _BiomeInfo {
  final IconData icon;
  final String label;
  const _BiomeInfo(this.icon, this.label);
}
