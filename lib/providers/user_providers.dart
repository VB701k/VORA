import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../backend/repositories/user_repo.dart';
import '../frontend/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  final UserRepository _userRepo = UserRepository();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _userRepo.signIn(email, password);
      if (userCredential != null) {
        final userData = await _userRepo.getUserData(userCredential.user!.uid);
        if (userData != null) {
          _user = UserModel(
            id: userCredential.user!.uid,
            email: userData['email'] ?? '',
            name: userData['name'] ?? '',
            streak: userData['streak'] ?? 0,
            points: userData['points'] ?? 0,
            createdAt: DateTime.now(),
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _userRepo.signUp(email, password);
      if (userCredential != null) {
        await _userRepo.createUser(userCredential.user!.uid, email, name);
        _user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          streak: 0,
          points: 0,
          createdAt: DateTime.now(),
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _userRepo.signOut();
    _user = null;
    notifyListeners();
  }
}
