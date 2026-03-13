import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

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

class _BoxBreathingScreenState extends State<BoxBreathingScreen> {
  static const int phaseSeconds = 4;
  static const int totalCycles = 10;

  final List<String> phases = ['INHALE', 'HOLD', 'EXHALE', 'HOLD'];

  Timer? _timer;
  bool _isRunning = true;
  bool _soundOn = true;

  int _currentPhaseIndex = 0;
  int _secondsLeft = phaseSeconds;
  int _completedCycles = 0; //fresh cycle

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
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning) return;

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
    }
  }

  void _togglePause() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _restartSession() {
    setState(() {
      _currentPhaseIndex = 0;
      _secondsLeft = phaseSeconds;
      _completedCycles = 0;
      _isRunning = true;
    });
    _startTimer();
  }

  void _toggleSound() {
    setState(() {
      _soundOn = !_soundOn;
    });
  }

  String _formatTime(int total) {
    final minutes = (total ~/ 60).toString();
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentPhase = phases[_currentPhaseIndex];

    return Scaffold(
      backgroundColor: WellnessColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            children: [
              _topBar(context),
              const SizedBox(height: 28),
              const Text(
                'Focus on your rhythm',
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
              const SizedBox(height: 24),
              _breathingCircle(currentPhase),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F463E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: WellnessColors.stroke),
                ),
                child: Column(
                  children: [
                    Text(
                      _secondsLeft.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: WellnessColors.text,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'SECONDS',
                      style: TextStyle(
                        color: WellnessColors.mint,
                        letterSpacing: 2,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
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
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$_completedCycles',
                            style: const TextStyle(
                              color: WellnessColors.text,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const TextSpan(
                            text: ' / $totalCycles',
                            style: TextStyle(
                              color: WellnessColors.textDim,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: LinearProgressIndicator(
                        minHeight: 8,
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
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundIconButton(
                    icon: Icons.replay_rounded,
                    onTap: _restartSession,
                  ),
                  GestureDetector(
                    onTap: _togglePause,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: WellnessColors.mint,
                      ),
                      child: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: WellnessColors.bg,
                        size: 48,
                      ),
                    ),
                  ),
                  _roundIconButton(
                    icon: _soundOn
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                    onTap: _toggleSound,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: List.generate(phases.length, (index) {
                  final isActive = index == _currentPhaseIndex;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index == phases.length - 1 ? 0 : 12,
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
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
                          const SizedBox(height: 10),
                          Text(
                            phases[index],
                            style: TextStyle(
                              color: isActive
                                  ? WellnessColors.mint
                                  : WellnessColors.textDim,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
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
            size: 28,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'BOX BREATHING',
              style: TextStyle(
                color: WellnessColors.mint,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: WellnessColors.mint,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.info_outline_rounded,
              color: WellnessColors.bg,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _breathingCircle(String currentPhase) {
    final phaseProgress = (phaseSeconds - _secondsLeft) / phaseSeconds;

    return SizedBox(
      width: 330,
      height: 330,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: CustomPaint(painter: RingPainter(progress: phaseProgress)),
          ),
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: WellnessColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: WellnessColors.mint, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _phaseLabel(currentPhase),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                const Icon(
                  Icons.air_rounded,
                  color: WellnessColors.mint,
                  size: 44,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: WellnessColors.card,
          border: Border.all(color: WellnessColors.stroke),
        ),
        child: Icon(icon, color: WellnessColors.text, size: 36),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  final double progress;

  RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const startAngle = -math.pi / 2;
    final rect = Offset.zero & size;

    final basePaint = Paint()
      ..color = WellnessColors.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = WellnessColors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
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
    return oldDelegate.progress != progress;
  }
}
