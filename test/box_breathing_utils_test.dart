import 'package:flutter_test/flutter_test.dart';
import 'package:vora/backend/utils/box_breathing_utils.dart';

void main() {
  group('BoxBreathingUtils', () {
    test('totalSessionSeconds calculates correctly', () {
      expect(
        BoxBreathingUtils.totalSessionSeconds(
          totalCycles: 10,
          phasesCount: 4,
          phaseSeconds: 4,
        ),
        160,
      );
    });

    test('elapsedSeconds calculates correctly', () {
      expect(
        BoxBreathingUtils.elapsedSeconds(
          completedCycles: 1,
          phasesCount: 4,
          phaseSeconds: 4,
          currentPhaseIndex: 2,
          secondsLeft: 2,
        ),
        26,
      );
    });

    test('remainingSeconds calculates correctly', () {
      expect(
        BoxBreathingUtils.remainingSeconds(
          totalCycles: 10,
          phasesCount: 4,
          phaseSeconds: 4,
          completedCycles: 1,
          currentPhaseIndex: 2,
          secondsLeft: 2,
        ),
        134,
      );
    });

    test('remainingSeconds never goes below 0', () {
      expect(
        BoxBreathingUtils.remainingSeconds(
          totalCycles: 1,
          phasesCount: 4,
          phaseSeconds: 4,
          completedCycles: 10,
          currentPhaseIndex: 3,
          secondsLeft: 0,
        ),
        0,
      );
    });

    test('formatTime returns correct m:ss format', () {
      expect(BoxBreathingUtils.formatTime(160), '2:40');
      expect(BoxBreathingUtils.formatTime(5), '0:05');
      expect(BoxBreathingUtils.formatTime(65), '1:05');
    });
  });
}