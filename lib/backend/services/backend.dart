// ==================== IMPORTS ====================
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// commit 1
const String kBackendVersion = "1.0.0";

//commit 2
void backendLog(String message) {
  if (kDebugMode) {
    debugPrint("[Backend] $message");
  }
}

// =====================================================
// 1) GROUP MODEL: AppTask (UNCHANGED behavior)
// =====================================================
class AppTask {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final bool isCompleted;
  final String source;
  final bool hidden;

  AppTask({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.isCompleted,
    required this.source,
    required this.hidden,
  });

  factory AppTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final Timestamp? ts = data["dueAt"];
    final DateTime due = ts?.toDate() ?? DateTime.now();

    return AppTask(
      id: doc.id,
      title: (data["title"] ?? "").toString(),
      subtitle: (data["subtitle"] ?? "").toString(),
      dueDate: due,
      isCompleted: (data["isCompleted"] ?? false) as bool,
      source: (data["source"] ?? "task").toString(),
      hidden: (data["hidden"] ?? false) as bool,
    );
  }
}

// =====================================================
// 2) GROUP SERVICE: AuthService (UNCHANGED behavior)
// =====================================================
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signIn({required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithProfile({
    required String name,
    required int age,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'internal-error',
        message: 'User account was not created.',
      );
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'age': age,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('datas')
        .doc("settings")
        .set({'notification': true});

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('datas')
        .doc("app_datas")
        .set({'variable1': 'value1', 'variable2': 'value2'});

    await user.updateDisplayName(name);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}

// =====================================================
// 3) GROUP SERVICE: HomeProfileService (UNCHANGED behavior)
// =====================================================
class HomeProfileService {
  HomeProfileService._();
  static final HomeProfileService instance = HomeProfileService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  Future<String> fetchMyName() async {
    final doc = await _firestore.collection('users').doc(_uid).get();
    final data = doc.data();
    return (data?['name'] ?? 'VORA Student').toString();
  }
}

// =====================================================
// 4) GROUP SERVICE: TaskFirestoreService (UNCHANGED behavior)
// =====================================================
class TaskFirestoreService {
  TaskFirestoreService._();
  static final TaskFirestoreService instance = TaskFirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCol {
    return _db.collection('users').doc(_uid).collection('tasks');
  }

  Future<void> addTask({
    required String id,
    required String title,
    required String subtitle,
    required DateTime dueAt,
    required String source,
  }) async {
    await _taskCol.doc(id).set({
      'title': title,
      'subtitle': subtitle,
      'dueAt': Timestamp.fromDate(dueAt),
      'isCompleted': false,
      'source': source,
      'hidden': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppTask>> streamTasks() {
    return _taskCol
        .where('hidden', isEqualTo: false)
        .orderBy('dueAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppTask.fromDoc(d)).toList());
  }

  Future<void> toggleDone(String taskId, bool currentValue) async {
    await _taskCol.doc(taskId).update({'isCompleted': !currentValue});
  }

  Future<void> hideTask(String taskId) async {
    await _taskCol.doc(taskId).update({'hidden': true});
  }

  //commit 4
  Future<void> deleteTask(String taskId) async {
    await _taskCol.doc(taskId).delete();
  }

  //Commit 5
  Future<void> updateTask({
    required String taskId,
    String? title,
    String? subtitle,
    DateTime? dueAt,
  }) async {
    final updates = <String, dynamic>{};

    if (title != null) updates['title'] = title;
    if (subtitle != null) updates['subtitle'] = subtitle;
    if (dueAt != null) updates['dueAt'] = Timestamp.fromDate(dueAt);

    if (updates.isEmpty) return;

    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _taskCol.doc(taskId).update(updates);
  }
}

// =====================================================
// 5) GROUP SERVICE: NotificationService (UNCHANGED behavior)
// =====================================================
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

// =====================================================
// 6) GROUP SERVICE: MessagingService (UNCHANGED behavior)
// =====================================================
class MessagingService {
  MessagingService._();
  static final MessagingService instance = MessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  Future<void> initialize() async {
    await requestPermission();
    await logDeviceToken();

    _foregroundSubscription ??= FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      final notification = message.notification;

      if (notification == null) {
        debugPrint('No notification payload (data-only message)');
        return;
      }

      final title = notification.title ?? 'Notification';
      final body = notification.body ?? '';

      NotificationService().showNotification(title: title, body: body);
      debugPrint('Notification: $title - $body');
    });
  }

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Notification permission GRANTED');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Notification permission DENIED');
    } else {
      debugPrint('Notification permission NOT DETERMINED');
    }
  }

  Future<String?> getDeviceToken() => _messaging.getToken();

  Future<void> logDeviceToken() async {
    final token = await getDeviceToken();
    debugPrint('FCM Device Token: $token');
  }

  void dispose() {
    _foregroundSubscription?.cancel();
    _foregroundSubscription = null;
  }
}

// =====================================================
// 7) NEW: DateKey (streak/quotes helper)
// =====================================================
class DateKey {
  static String todayKey({DateTime? now, bool useUtc = true}) {
    final dt = now ?? DateTime.now();
    final d = useUtc ? dt.toUtc() : dt;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static String fromDate(DateTime date, {bool useUtc = true}) {
    final d = useUtc ? date.toUtc() : date;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

// =====================================================
// 8) NEW: StreakService (single source of truth in users/{uid})
// =====================================================
class StreakService {
  StreakService._();
  static final StreakService instance = StreakService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("User not logged in");
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  Future<void> markActiveToday() async {
    final today = DateKey.todayKey(useUtc: true);
    final yesterday = DateKey.fromDate(
      DateTime.now().toUtc().subtract(const Duration(days: 1)),
      useUtc: true,
    );

    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userRef);
      final data = snap.data() ?? {};

      final last = data['lastActiveDate'] as String?;
      int streak = (data['streak'] as num?)?.toInt() ?? 0;
      int longest = (data['longestStreak'] as num?)?.toInt() ?? 0;

      if (last == today) return;

      if (last == yesterday) {
        streak += 1;
      } else {
        streak = 1;
      }

      if (streak > longest) longest = streak;

      tx.set(_userRef, {
        'lastActiveDate': today,
        'streak': streak,
        'longestStreak': longest,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<int> getCurrentStreak() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['streak'] as num?)?.toInt() ?? 0;
  }

  Future<int> getLongestStreak() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['longestStreak'] as num?)?.toInt() ?? 0;
  }
}

// =====================================================
// 9) NEW: RewardService (points in users/{uid}.points)
// =====================================================
class RewardService {
  RewardService._();
  static final RewardService instance = RewardService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception("User not logged in");
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _db.collection('users').doc(_uid);

  Future<void> addPoints(int delta) async {
    await _userRef.set({
      'points': FieldValue.increment(delta),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> onTaskCompleted() => addPoints(10);

  Future<void> onStreakMilestone(int streak) async {
    if (streak % 7 == 0) {
      await addPoints(50);
    }
  }

  Future<int> getMyPoints() async {
    final doc = await _userRef.get();
    final data = doc.data() ?? {};
    return (data['points'] as num?)?.toInt() ?? 0;
  }
}

// =====================================================
// 10) NEW: Quotes (Firestore-based daily quote cache)
// Collections:
//   quotes/{id}  -> {text, author, category, createdAt}
//   dailyQuotes/{YYYY-MM-DD} -> {text, author, category, sourceQuoteId, dateKey, createdAt}
// =====================================================
class QuotesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getQuotes({
    List<String>? categories,
    int limit = 200,
  }) async {
    Query<Map<String, dynamic>> q = _db.collection('quotes');
    if (categories != null && categories.isNotEmpty) {
      q = q.where('category', whereIn: categories.take(10).toList());
    }
    final snap = await q.limit(limit).get();
    return snap.docs;
  }

  Future<Map<String, dynamic>?> getDailyQuote(String dateKey) async {
    final doc = await _db.collection('dailyQuotes').doc(dateKey).get();
    return doc.data();
  }

  Future<void> setDailyQuote(String dateKey, Map<String, dynamic> quote) async {
    await _db.collection('dailyQuotes').doc(dateKey).set({
      ...quote,
      'dateKey': dateKey,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class QuoteService {
  QuoteService({QuotesRepository? repo}) : _repo = repo ?? QuotesRepository();
  final QuotesRepository _repo;

  Future<Map<String, dynamic>> getOrCreateTodayQuote({
    List<String>? allowedCategories,
  }) async {
    final key = DateKey.todayKey(useUtc: true);

    final cached = await _repo.getDailyQuote(key);
    if (cached != null) return cached;

    final quotes = await _repo.getQuotes(
      categories: allowedCategories,
      limit: 200,
    );

    if (quotes.isEmpty) {
      final fallback = {
        'text': 'Keep going. You are building something real.',
        'author': 'VORA',
        'category': 'fallback',
      };
      await _repo.setDailyQuote(key, fallback);
      return fallback;
    }

    final idx = _stableIndex(key, quotes.length);
    final picked = quotes[idx].data();

    final daily = {
      'text': (picked['text'] ?? '').toString(),
      'author': (picked['author'] ?? 'Unknown').toString(),
      'category': (picked['category'] ?? 'Motivation').toString(),
      'sourceQuoteId': quotes[idx].id,
    };

    await _repo.setDailyQuote(key, daily);
    return daily;
  }

  int _stableIndex(String key, int length) {
    final r = Random(key.hashCode);
    return r.nextInt(length);
  }
}

// =====================================================
// 11) NEW: FirebaseBootstrap (safe init + optional quote seeding)
// =====================================================
class FirebaseBootstrap {
  FirebaseBootstrap._();

  //commit 3
  static Future<void> initFirebase({
    required FirebaseOptions options,
    bool seedQuotesIfEmpty = true,
  }) async {
    backendLog("Firebase init started");
    await Firebase.initializeApp(options: options);
    backendLog("Firebase init done");

    if (seedQuotesIfEmpty) {
      backendLog("Quote seed check started");
      await seedQuotesIfEmptyInFirestore();
      backendLog("Quote seed check done");
    }
  }

  // commit 4
  static Future<void> seedQuotesIfEmptyInFirestore() async {
    final fs = FirebaseFirestore.instance;
    final snap = await fs.collection('quotes').limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final starter = <Map<String, dynamic>>[
      {
        'text': 'The only way to do great work is to love what you do.',
        'author': 'Steve Jobs',
        'category': 'Motivation',
      },
      {
        'text': 'Success is not final, failure is not fatal.',
        'author': 'Winston Churchill',
        'category': 'Success',
      },
      {
        'text': 'Believe you can and you\'re halfway there.',
        'author': 'Theodore Roosevelt',
        'category': 'Motivation',
      },
    ];

    final batch = fs.batch();
    for (final q in starter) {
      final ref = fs.collection('quotes').doc();
      batch.set(ref, {...q, 'createdAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }
}
