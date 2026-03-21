import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../backend/services/wellness_service.dart';

class WellnessColors {
  static const bg = Color(0xFF0B1F1C);
  static const card = Color(0xFF12322C);
  static const card2 = Color(0xFF0F2A25);
  static const mint = Color(0xFF29D3B0);
  static const text = Color(0xFFEAF6F3);
  static const textDim = Color(0xFFB5D2CC);
  static const stroke = Color(0xFF1B4C42);
}

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with WidgetsBindingObserver {
  static const int phaseSeconds = 4;
  static const int totalCycles = 10;

  final List<String> phases = ['INHALE', 'HOLD', 'EXHALE', 'HOLD'];

  Timer? _timer;

  bool _isRunning = false;
  bool _soundOn = true;
  bool _isSaving = false;

  int _currentPhaseIndex = 0;
  int _secondsLeft = phaseSeconds;
  int _completedCycles = 0;

  int get totalSessionSeconds => totalCycles * phases.length * phaseSeconds;

  int get elapsedSeconds {
    final finishedFullCycles = _completedCycles * phases.length * phaseSeconds;
    final finishedPhasesInCurrentCycle = _currentPhaseIndex * phaseSeconds;
    final currentPhaseElapsed = phaseSeconds - _secondsLeft;

    return finishedFullCycles +
        finishedPhasesInCurrentCycle +
        currentPhaseElapsed;
  }

  int get remainingSeconds {
    final remain = totalSessionSeconds - elapsedSeconds;
    return remain < 0 ? 0 : remain;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_isRunning) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _initializeSession() async {
    try {
      if (!WellnessService.instance.isAuthenticated) {
        _showAuthErrorAndExit();
        return;
      }

      setState(() {
        _isRunning = true;
      });

      _startTimer();
    } catch (e) {
      _showAuthErrorAndExit();
    }
  }

  void _showAuthErrorAndExit() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to use breathing exercises'),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRunning) return;

      setState(() {
        if (_secondsLeft > 1) {
          _secondsLeft--;
        } else {
          _moveToNextPhase();
        }
      });
    });
  }

  void _moveToNextPhase() {
    if (_currentPhaseIndex == phases.length - 1) {
      _currentPhaseIndex = 0;
      if (_completedCycles < totalCycles) {
        _completedCycles++;
      }
    } else {
      _currentPhaseIndex++;
    }

    _secondsLeft = phaseSeconds;

    if (_completedCycles >= totalCycles) {
      _isRunning = false;
      _timer?.cancel();
      _timer = null;
      _showSessionComplete();
    }
  }

  void _showSessionComplete() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great job! Breathing session complete!'),
        backgroundColor: WellnessColors.mint,
        duration: Duration(seconds: 3),
      ),
    );

    _saveSessionToFirebase();
  }

  Future<void> _saveSessionToFirebase() async {
    if (!mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await WellnessService.instance.saveBoxBreathingSession(
        totalCycles: totalCycles,
        completedCycles: _completedCycles,
        phaseSeconds: phaseSeconds,
        soundOn: _soundOn,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session saved successfully!'),
          backgroundColor: WellnessColors.mint,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });
    }
  }

  void _togglePause() {
    if (!mounted) return;

    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning && _timer == null) {
      _startTimer();
    }
  }

  void _restartSession() {
    _timer?.cancel();
    _timer = null;

    if (!mounted) return;

    setState(() {
      _currentPhaseIndex = 0;
      _secondsLeft = phaseSeconds;
      _completedCycles = 0;
      _isRunning = true;
    });

    _startTimer();
  }

  void _toggleSound() {
    if (!mounted) return;

    setState(() {
      _soundOn = !_soundOn;
    });
  }

  String _formatTime(int total) {
    final minutes = (total ~/ 60).toString();
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'INHALE':
        return 'Inhale';
      case 'EXHALE':
        return 'Exhale';
      default:
        return 'Hold';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WellnessColors.card,
        title: const Text(
          'Box Breathing',
          style: TextStyle(
            color: WellnessColors.mint,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Inhale for 4 seconds, hold for 4 seconds, exhale for 4 seconds, and hold again for 4 seconds. Repeat the cycle to reduce stress and improve focus.',
          style: TextStyle(color: WellnessColors.textDim, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: WellnessColors.mint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'BOX BREATHING',
              style: TextStyle(
                color: WellnessColors.mint,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _showInfoDialog,
          icon: const Icon(
            Icons.info_outline_rounded,
            color: WellnessColors.mint,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _breathingCircle(String currentPhase, double size) {
    final phaseProgress = (phaseSeconds - _secondsLeft) / phaseSeconds;
    final innerSize = size * 0.68;

    return SizedBox(
      width: size + 24,
      height: size + 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: RingPainter(progress: phaseProgress, strokeWidth: 7),
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: WellnessColors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: WellnessColors.mint, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _phaseLabel(currentPhase),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size < 240 ? 22 : 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(
                  Icons.air_rounded,
                  color: WellnessColors.mint,
                  size: size < 240 ? 30 : 36,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required double size,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: WellnessColors.card,
          border: Border.all(color: WellnessColors.stroke),
        ),
        child: Icon(icon, color: WellnessColors.text, size: size * 0.38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = phases[_currentPhaseIndex];

    return Scaffold(
      backgroundColor: WellnessColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenHeight < 760;

            final circleSize = math.min(
              screenWidth * 0.62,
              isSmallScreen ? 220.0 : 270.0,
            );

            final actionButtonSize = isSmallScreen ? 70.0 : 86.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: Column(
                    children: [
                      _topBar(context),
                      const SizedBox(height: 14),
                      const Text(
                        'Focus on your rhythm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: WellnessColors.textDim,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatTime(remainingSeconds)} remaining',
                        style: const TextStyle(
                          color: WellnessColors.mint,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 22),
                      _breathingCircle(currentPhase, circleSize),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F463E),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: WellnessColors.stroke),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _secondsLeft.toString().padLeft(2, '0'),
                              style: TextStyle(
                                color: WellnessColors.text,
                                fontSize: isSmallScreen ? 34 : 40,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SECONDS',
                              style: TextStyle(
                                color: WellnessColors.mint,
                                letterSpacing: 2,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: WellnessColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: WellnessColors.stroke),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cycles Completed',
                                    style: TextStyle(
                                      color: WellnessColors.textDim,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.refresh_rounded,
                                  color: WellnessColors.mint,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_completedCycles',
                                    style: const TextStyle(
                                      color: WellnessColors.text,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' / $totalCycles',
                                    style: TextStyle(
                                      color: WellnessColors.textDim,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: LinearProgressIndicator(
                                minHeight: 6,
                                value: totalCycles == 0
                                    ? 0
                                    : _completedCycles / totalCycles,
                                backgroundColor: WellnessColors.stroke,
                                valueColor: const AlwaysStoppedAnimation(
                                  WellnessColors.mint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _roundIconButton(
                            icon: Icons.replay_rounded,
                            onTap: _restartSession,
                            size: actionButtonSize,
                          ),
                          GestureDetector(
                            onTap: _togglePause,
                            child: Container(
                              width: actionButtonSize + 10,
                              height: actionButtonSize + 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: WellnessColors.mint,
                              ),
                              child: Icon(
                                _isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: WellnessColors.bg,
                                size: isSmallScreen ? 40 : 46,
                              ),
                            ),
                          ),
                          _roundIconButton(
                            icon: _soundOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            onTap: _toggleSound,
                            size: actionButtonSize,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: List.generate(phases.length, (index) {
                          final isActive = index == _currentPhaseIndex;

                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                right: index == phases.length - 1 ? 0 : 8,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? WellnessColors.card
                                          : WellnessColors.card2,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isActive
                                            ? WellnessColors.mint
                                            : WellnessColors.stroke,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    phases[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isActive
                                          ? WellnessColors.mint
                                          : WellnessColors.textDim,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      if (_isSaving)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: CircularProgressIndicator(
                            color: WellnessColors.mint,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  RingPainter({required this.progress, this.strokeWidth = 7});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final basePaint = Paint()
      ..color = WellnessColors.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = WellnessColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 2, false, basePaint);
    canvas.drawArc(
      rect,
      startAngle,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
