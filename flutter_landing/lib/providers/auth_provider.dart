import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _key = 'ss_flutter_user';

  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        _user = AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        notifyListeners();
      }
    } catch (_) {
      _user = null;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_user != null) {
        await prefs.setString(_key, jsonEncode(_user!.toJson()));
      } else {
        await prefs.remove(_key);
      }
    } catch (_) {}
  }

  Future<void> login(String email, String password, ApiService api) async {
    final u = await api.login(email, password);
    _user = u;
    notifyListeners();
    await _persist();
  }

  Future<void> register(
      String name, String email, String password, String phone, ApiService api) async {
    final u = await api.register(name, email, password, phone);
    _user = u;
    notifyListeners();
    await _persist();
  }

  void logout() {
    _user = null;
    notifyListeners();
    _persist();
  }
}
