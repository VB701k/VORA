import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vora/backend/models/mindful_pop_session.dart';
import 'package:vora/backend/services/mindful_pop_backend.dart';

class MindfulPopScreen extends StatefulWidget {
  const MindfulPopScreen({super.key});

  @override
  State<MindfulPopScreen> createState() => _MindfulPopScreenState();
}

class _MindfulPopScreenState extends State<MindfulPopScreen> {
  final Random _random = Random();
  final List<PopBubble> _bubbles = [];
  final MindfulPopBackend _backend = MindfulPopBackend();

  Timer? _spawnTimer;
  Timer? _gameTimer;

  int _score = 0;
  int _streak = 0;
  int _missedBubbles = 0;
  int _bestStreakThisSession = 0;

  bool _soundOn = true;
  bool _started = false;
  bool _isSavingSession = false;

  DateTime? _sessionStartedAt;

  static const int _maxBubbles = 10;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
    _startGame();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoundPreference() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) return;

      final saved = await _backend.getSoundPreference();
      if (!mounted) return;

      setState(() {
        _soundOn = saved;
      });
    } catch (e) {
      debugPrint('Failed to load Mindful Pop sound setting: $e');
    }
  }

  void _startGame() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();

    setState(() {
      _score = 0;
      _streak = 0;
      _started = true;
      _bubbles.clear();
      _missedBubbles = 0;
      _bestStreakThisSession = 0;
      _sessionStartedAt = DateTime.now();
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;

      setState(() {
        if (_bubbles.length < _maxBubbles) {
          _bubbles.add(_generateBubble());
        }
      });
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!mounted) return;

      setState(() {
        for (final bubble in _bubbles) {
          bubble.y -= bubble.speed;
        }

        final missed = _bubbles.where((b) => b.y + b.size < 0).toList();
        if (missed.isNotEmpty) {
          _missedBubbles += missed.length;
          _streak = 0;
        }

        _bubbles.removeWhere((b) => b.y + b.size < 0);
      });
    });
  }

  PopBubble _generateBubble() {
    final size = 50.0 + _random.nextDouble() * 55.0;

    return PopBubble(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      x: _random.nextDouble(),
      y: 1.05,
      size: size,
      speed: 0.002 + _random.nextDouble() * 0.0035,
      color: _bubbleColor(),
      glowColor: _bubbleGlowColor(),
    );
  }

  Color _bubbleColor() {
    final colors = [
      const Color(0xFF74D8FF),
      const Color(0xFF62E0D0),
      const Color(0xFF8EDCF8),
      const Color(0xFF7FD8C3),
      const Color(0xFF93E6FF),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  Color _bubbleGlowColor() {
    final colors = [
      const Color(0x6646D7C4),
      const Color(0x6657C7FF),
      const Color(0x667FD6FF),
      const Color(0x6662E0D0),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void _popBubble(String id) {
    final index = _bubbles.indexWhere((b) => b.id == id);
    if (index == -1) return;

    setState(() {
      _bubbles.removeAt(index);
      _score += 1;
      _streak += 1;

      if (_streak > _bestStreakThisSession) {
        _bestStreakThisSession = _streak;
      }
    });
  }

  void _toggleSound() {
    final newValue = !_soundOn;

    setState(() {
      _soundOn = newValue;
    });

    if (FirebaseAuth.instance.currentUser != null) {
      _backend.saveSoundPreference(newValue).catchError((e) {
        debugPrint('Failed to save Mindful Pop sound setting: $e');
      });
    }
  }

  Future<void> _saveCurrentSession(String reason) async {
    if (_isSavingSession) return;
    if (_sessionStartedAt == null) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    final hasProgress = _score > 0 || _missedBubbles > 0;
    if (!hasProgress) return;

    _isSavingSession = true;

    try {
      final endedAt = DateTime.now();

      final session = MindfulPopSession(
        id: endedAt.microsecondsSinceEpoch.toString(),
        score: _score,
        bestStreak: _bestStreakThisSession,
        poppedBubbles: _score,
        missedBubbles: _missedBubbles,
        durationSeconds: endedAt.difference(_sessionStartedAt!).inSeconds,
        soundEnabled: _soundOn,
        endedReason: reason,
        startedAt: _sessionStartedAt!,
        endedAt: endedAt,
      );

      await _backend.saveSession(session);
    } catch (e) {
      debugPrint('Failed to save Mindful Pop session: $e');
    } finally {
      _isSavingSession = false;
    }
  }

  Future<void> _restartGame() async {
    await _saveCurrentSession('restart');
    if (!mounted) return;
    _startGame();
  }

  Future<void> _exitGame(BuildContext context) async {
    await _saveCurrentSession('back_to_hub');
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<bool> _handleSystemBack() async {
    await _saveCurrentSession('system_back');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleSystemBack,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [MindfulPopColors.bgTop, MindfulPopColors.bgBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    _buildSoftBackgroundOrbs(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                          child: _topBar(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _headerStats(),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x331D4C54),
                                      Color(0x22163E45),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  border: Border.all(
                                    color: MindfulPopColors.stroke,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Stack(
                                  children: [
                                    ..._bubbles.map(
                                      (bubble) => Positioned(
                                        left:
                                            bubble.x *
                                            (constraints.maxWidth -
                                                bubble.size -
                                                28),
                                        top:
                                            bubble.y *
                                            (constraints.maxHeight - 260),
                                        child: GestureDetector(
                                          onTap: () => _popBubble(bubble.id),
                                          child: _BubbleWidget(bubble: bubble),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: IgnorePointer(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.spa_rounded,
                                              size: 44,
                                              color: Color(0x55EAFBFA),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Tap the bubbles and relax',
                                              style: TextStyle(
                                                color: Color(0x88EAFBFA),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                          child: Row(
                            children: [
                              Expanded(
                                child: _actionButton(
                                  label: 'Restart',
                                  icon: Icons.refresh_rounded,
                                  filled: true,
                                  onTap: () {
                                    _restartGame();
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _actionButton(
                                  label: 'Back to Wellness',
                                  icon: Icons.home_rounded,
                                  filled: false,
                                  onTap: () {
                                    _exitGame(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            _exitGame(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: MindfulPopColors.text,
          ),
        ),
        const Expanded(
          child: Column(
            children: [
              Text(
                'Mindful Pop',
                style: TextStyle(
                  color: MindfulPopColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'VORA Stress Relief',
                style: TextStyle(
                  color: MindfulPopColors.aqua,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _toggleSound,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MindfulPopColors.cardSoft,
              shape: BoxShape.circle,
              border: Border.all(color: MindfulPopColors.stroke),
            ),
            child: Icon(
              _soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: MindfulPopColors.aqua,
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(title: 'POPPED', value: '$_score', trailing: null),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _statCard(
            title: 'ZEN STREAK',
            value: '$_streak',
            trailing: const Icon(
              Icons.bolt_rounded,
              color: MindfulPopColors.aqua,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: MindfulPopColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MindfulPopColors.stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: MindfulPopColors.textDim,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: MindfulPopColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 6), trailing],
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: filled ? MindfulPopColors.aqua : MindfulPopColors.cardSoft,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: filled ? Colors.transparent : MindfulPopColors.stroke,
          ),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color(0x3357C7FF),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? MindfulPopColors.bgBottom : MindfulPopColors.text,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: filled
                    ? MindfulPopColors.bgBottom
                    : MindfulPopColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoftBackgroundOrbs() {
    return IgnorePointer(
      child: Stack(
        children: const [
          Positioned(
            top: 110,
            left: -30,
            child: _BackgroundOrb(size: 160, color: Color(0x1146D7C4)),
          ),
          Positioned(
            top: 210,
            right: -10,
            child: _BackgroundOrb(size: 120, color: Color(0x1157C7FF)),
          ),
          Positioned(
            top: 420,
            left: 40,
            child: _BackgroundOrb(size: 90, color: Color(0x107FD6FF)),
          ),
          Positioned(
            bottom: 170,
            right: 35,
            child: _BackgroundOrb(size: 110, color: Color(0x1062E0D0)),
          ),
        ],
      ),
    );
  }
}

class MindfulPopColors {
  static const bgTop = Color(0xFF10343A);
  static const bgBottom = Color(0xFF0E2428);
  static const card = Color(0xFF163E45);
  static const cardSoft = Color(0xFF1D4C54);
  static const mint = Color(0xFF46D7C4);
  static const aqua = Color(0xFF57C7FF);
  static const softBlue = Color(0xFF7FD6FF);
  static const text = Color(0xFFEAFBFA);
  static const textDim = Color(0xFFB7D7D5);
  static const stroke = Color(0xFF2D6B73);
}

class PopBubble {
  final String id;
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;
  final Color glowColor;

  PopBubble({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.glowColor,
  });
}

class _BubbleWidget extends StatelessWidget {
  final PopBubble bubble;

  const _BubbleWidget({required this.bubble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bubble.size,
      height: bubble.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            bubble.color.withValues(alpha: 0.9),
            bubble.color.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
          color: bubble.color.withValues(alpha: 0.45),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(color: bubble.glowColor, blurRadius: 18, spreadRadius: 2),
        ],
      ),
      child: Align(
        alignment: const Alignment(-0.25, -0.25),
        child: Container(
          width: bubble.size * 0.16,
          height: bubble.size * 0.16,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 28, spreadRadius: 10)],
      ),
    );
  }
}
