class BoxBreathingUtils {
  static int totalSessionSeconds({
    required int totalCycles,
    required int phasesCount,
    required int phaseSeconds,
  }) {
    return totalCycles * phasesCount * phaseSeconds;
  }

  static int elapsedSeconds({
    required int completedCycles,
    required int phasesCount,
    required int phaseSeconds,
    required int currentPhaseIndex,
    required int secondsLeft,
  }) {
    final finishedFullCycles = completedCycles * phasesCount * phaseSeconds;
    final finishedPhasesInCurrentCycle = currentPhaseIndex * phaseSeconds;
    final currentPhaseElapsed = phaseSeconds - secondsLeft;

    return finishedFullCycles +
        finishedPhasesInCurrentCycle +
        currentPhaseElapsed;
  }

  static int remainingSeconds({
    required int totalCycles,
    required int phasesCount,
    required int phaseSeconds,
    required int completedCycles,
    required int currentPhaseIndex,
    required int secondsLeft,
  }) {
    final total = totalSessionSeconds(
      totalCycles: totalCycles,
      phasesCount: phasesCount,
      phaseSeconds: phaseSeconds,
    );

    final elapsed = elapsedSeconds(
      completedCycles: completedCycles,
      phasesCount: phasesCount,
      phaseSeconds: phaseSeconds,
      currentPhaseIndex: currentPhaseIndex,
      secondsLeft: secondsLeft,
    );

    final remain = total - elapsed;
    return remain < 0 ? 0 : remain;
  }

  static String formatTime(int total) {
    final minutes = (total ~/ 60).toString();
    final seconds = (total % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}