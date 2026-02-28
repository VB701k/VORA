import 'package:flutter/material.dart';
import 'dart:async';


class PomodoroTab extends StatefulWidget {
    const PomodoroTab({super.key});

  @override
  State<PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<PomodoroTab> {
  Timer? _timer;

  // You can later connect these to settings / firestore
  final int _workMinutes = 25;
  int _secondsLeft = 25 * 60;

  bool _isRunning = false;

  int get _totalSeconds => _workMinutes * 60;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _pause(); // stop at 0
      }
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsLeft = _totalSeconds;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // 1.0 at start -> 0.0 at end (countdown ring)
  double get _progress {
    if (_totalSeconds <= 0) return 0;
    return _secondsLeft / _totalSeconds;
  }


  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F2027);
    const primary = Color(0xFF64B5F6);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          child: Column(
            children: [
              const SizedBox(height: 8),


            const Text(
              "Pomodoro Timer",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            Expanded(
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
  alignment: Alignment.center,
  children: [
    // ✅ rotate only the rings
    
          SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          const SizedBox(width: 260, height: 260),
          Transform.rotate(
          angle: 0,
          child: SizedBox(
            width: 260,
            height: 260,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              valueColor: const AlwaysStoppedAnimation<Color>(primary),
              backgroundColor: Colors.transparent,
            ),
          ),
          ),

    // ✅ text stays normal (NOT rotated)
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(_secondsLeft),
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Focus Time",
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        const Text(
          "25 min",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    ),
  ],
),
                ),
              ),
            ),
            

              // 🔵 Buttons section
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: "Start",
                      icon: Icons.play_arrow_rounded,
                      filled: true,
                      enabled: !_isRunning,
                      color: primary,
                      onTap: _start,
                    ),
                  ),

                    const SizedBox(width: 14),
                  Expanded(
                    child: _ActionButton(
                      label: "Pause",
                      icon: Icons.pause_rounded,
                      filled: false,
                      enabled: _isRunning,
                      color: primary,
                      onTap: _pause,
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: _ActionButton(
                  label: "Reset",
                  icon: Icons.restart_alt_rounded,
                  filled: false,
                  enabled: true,
                  color: Colors.white70,
                  outlineColor: Colors.white24,
                  onTap: _reset,                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool enabled;
  final Color color;
  final Color? outlineColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.color,
    required this.onTap,
    this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    final disabledOpacity = 0.45;

    final bg = filled ? color : Colors.transparent;
    final fg = filled ? Colors.black : color;
    final border = filled ? Colors.transparent : (outlineColor ?? color);

    return Opacity(
      opacity: enabled ? 1 : disabledOpacity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: border, width: 1.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}