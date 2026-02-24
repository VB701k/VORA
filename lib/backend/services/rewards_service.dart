import '../repositories/user_repo.dart';

class RewardService {
  final UserRepository _userRepo;

  RewardService(this._userRepo);

  /// Reward user for completing a task
  Future<void> rewardForTaskCompleted(String userId) async {
    try {
      // Add 10 points for task completion
      await _userRepo.addPoints(userId, 10);

      // You can add more reward logic here
      // - Check for achievements
      // - Update streak
      // - Unlock badges
    } catch (e) {
      print('Error rewarding task completion: $e');
    }
  }

  /// Reward user for maintaining streak
  Future<void> rewardForStreak(String userId, int streakDays) async {
    try {
      // Bonus points for streaks
      int bonusPoints = streakDays * 5;
      await _userRepo.addPoints(userId, bonusPoints);
    } catch (e) {
      print('Error rewarding streak: $e');
    }
  }

  /// Get user's current points
  Future<int> getUserPoints(String userId) async {
    return await _userRepo.getUserPoints(userId);
  }
}
