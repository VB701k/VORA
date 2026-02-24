import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';

class MotivationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get user motivation preferences
  Future<Map<String, dynamic>?> getUserPreferences(String userId) async {
    try {
      final doc = await FirestorePaths.preferencesCollection(
        userId,
      ).doc('motivation').get();

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error getting motivation preferences: $e');
      return null;
    }
  }

  /// Update notification settings
  Future<void> updateNotificationSettings(
    String userId,
    bool enabled,
    String deliveryTime,
  ) async {
    try {
      await FirestorePaths.preferencesCollection(userId).doc('motivation').set({
        'notificationsEnabled': enabled,
        'deliveryTime': deliveryTime,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating notification settings: $e');
      rethrow;
    }
  }

  /// Update selected categories
  Future<void> updateSelectedCategories(
    String userId,
    List<String> categories,
  ) async {
    try {
      await FirestorePaths.preferencesCollection(userId).doc('motivation').set({
        'selectedCategories': categories,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating categories: $e');
      rethrow;
    }
  }

  /// Toggle daily motivation notifications
  Future<void> toggleDailyMotivation(String userId, bool enabled) async {
    try {
      await FirestorePaths.preferencesCollection(userId).doc('motivation').set({
        'dailyMotivationEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error toggling daily motivation: $e');
      rethrow;
    }
  }

  /// Get a personalized quote based on user's selected categories
  Future<Map<String, dynamic>?> getPersonalizedQuote(String userId) async {
    try {
      // Get user's preferred categories
      final prefs = await getUserPreferences(userId);
      final categories = prefs?['selectedCategories'] as List<dynamic>? ?? [];
      final categoryList = categories.map((c) => c.toString()).toList();

      // Build query based on categories
      Query query = FirestorePaths.quotesCollection();

      if (categoryList.isNotEmpty) {
        query = query.where('category', whereIn: categoryList);
      }

      final snapshot = await query.limit(10).get();
      final quotes = snapshot.docs;

      if (quotes.isEmpty) return null;

      final randomIndex = DateTime.now().millisecondsSinceEpoch % quotes.length;
      final doc = quotes[randomIndex];
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'text': data['text'] ?? '',
        'author': data['author'] ?? 'Unknown',
        'category': data['category'] ?? 'Motivation',
      };
    } catch (e) {
      print('Error getting personalized quote: $e');
      return null;
    }
  }

  /// Get all available quote categories
  Future<List<String>> getQuoteCategories() async {
    try {
      final snapshot = await FirestorePaths.quotesCollection().get();
      final categories = <String>{};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      return categories.toList()..sort();
    } catch (e) {
      print('Error getting quote categories: $e');
      return [];
    }
  }

  /// Get user's motivation streak
  Future<int> getMotivationStreak(String userId) async {
    try {
      final doc = await FirestorePaths.preferencesCollection(
        userId,
      ).doc('motivation').get();

      final data = doc.data() as Map<String, dynamic>?;
      return data?['streak'] ?? 0;
    } catch (e) {
      print('Error getting motivation streak: $e');
      return 0;
    }
  }

  /// Increment motivation streak
  Future<void> incrementMotivationStreak(String userId) async {
    try {
      final docRef = FirestorePaths.preferencesCollection(
        userId,
      ).doc('motivation');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        final data = doc.data() as Map<String, dynamic>?;
        final currentStreak = data?['streak'] ?? 0;

        transaction.set(docRef, {
          'streak': currentStreak + 1,
          'lastMotivationDate': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (e) {
      print('Error incrementing motivation streak: $e');
    }
  }

  /// Reset motivation streak
  Future<void> resetMotivationStreak(String userId) async {
    try {
      await FirestorePaths.preferencesCollection(userId).doc('motivation').set({
        'streak': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error resetting motivation streak: $e');
    }
  }

  /// Check if user has motivation preferences
  Future<bool> hasPreferences(String userId) async {
    try {
      final doc = await FirestorePaths.preferencesCollection(
        userId,
      ).doc('motivation').get();
      return doc.exists;
    } catch (e) {
      print('Error checking preferences: $e');
      return false;
    }
  }

  /// Get user's delivery time
  Future<String?> getDeliveryTime(String userId) async {
    try {
      final prefs = await getUserPreferences(userId);
      return prefs?['deliveryTime'] as String?;
    } catch (e) {
      print('Error getting delivery time: $e');
      return null;
    }
  }

  /// Check if daily motivation is enabled
  Future<bool> isDailyMotivationEnabled(String userId) async {
    try {
      final prefs = await getUserPreferences(userId);
      return prefs?['dailyMotivationEnabled'] as bool? ?? false;
    } catch (e) {
      print('Error checking daily motivation: $e');
      return false;
    }
  }
}
