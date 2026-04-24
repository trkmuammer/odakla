import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focuszen/models/user.dart';

class UserService extends ChangeNotifier {
  static const String _userKey = 'user_data';
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        _currentUser = User.fromJson(jsonDecode(userData));
      } else {
        _currentUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          points: 0,
          totalFocusMinutes: 0,
          dayStreak: 0,
          sessionsCompleted: 0,
          equippedCharacter: 'focus_spirit',
          unlockedCharacters: ['focus_spirit'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveUser();
      }
    } catch (e) {
      debugPrint('Failed to initialize user: $e');
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        points: 0,
        totalFocusMinutes: 0,
        dayStreak: 0,
        sessionsCompleted: 0,
        equippedCharacter: 'focus_spirit',
        unlockedCharacters: ['focus_spirit'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    } catch (e) {
      debugPrint('Failed to save user: $e');
    }
  }

  Future<void> addPoints(int points) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      points: _currentUser!.points + points,
      updatedAt: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }

  Future<void> completeSession(int minutes) async {
    if (_currentUser == null) return;
    final points = (minutes / 5).floor() * 10;
    _currentUser = _currentUser!.copyWith(
      points: _currentUser!.points + points,
      totalFocusMinutes: _currentUser!.totalFocusMinutes + minutes,
      sessionsCompleted: _currentUser!.sessionsCompleted + 1,
      updatedAt: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }

  Future<void> unlockCharacter(String characterId) async {
    if (_currentUser == null) return;
    if (_currentUser!.unlockedCharacters.contains(characterId)) return;
    
    final unlockedChars = List<String>.from(_currentUser!.unlockedCharacters)..add(characterId);
    _currentUser = _currentUser!.copyWith(
      unlockedCharacters: unlockedChars,
      updatedAt: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }

  Future<void> equipCharacter(String characterId) async {
    if (_currentUser == null) return;
    if (!_currentUser!.unlockedCharacters.contains(characterId)) return;
    
    _currentUser = _currentUser!.copyWith(
      equippedCharacter: characterId,
      updatedAt: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }

  Future<void> spendPoints(int amount) async {
    if (_currentUser == null || _currentUser!.points < amount) return;
    _currentUser = _currentUser!.copyWith(
      points: _currentUser!.points - amount,
      updatedAt: DateTime.now(),
    );
    await _saveUser();
    notifyListeners();
  }
}
