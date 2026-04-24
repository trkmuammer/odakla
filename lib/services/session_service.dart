import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focuszen/models/focus_session.dart';

class SessionService extends ChangeNotifier {
  static const String _sessionsKey = 'focus_sessions';
  List<FocusSession> _sessions = [];

  bool _isFocusLocked = false;
  bool get isFocusLocked => _isFocusLocked;

  void setFocusLocked(bool locked) {
    if (_isFocusLocked == locked) return;
    _isFocusLocked = locked;
    notifyListeners();
  }

  List<FocusSession> get sessions => _sessions;

  List<FocusSession> getThisWeekSessions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return _sessions.where((s) => s.startTime.isAfter(weekStartDate) && s.completed).toList();
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsData = prefs.getString(_sessionsKey);
      
      if (sessionsData != null) {
        final List<dynamic> decoded = jsonDecode(sessionsData);
        _sessions = decoded.map((json) => FocusSession.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Failed to initialize sessions: $e');
      _sessions = [];
    }
    notifyListeners();
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_sessionsKey, encoded);
    } catch (e) {
      debugPrint('Failed to save sessions: $e');
    }
  }

  Future<FocusSession> createSession(String userId, int durationMinutes) async {
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      durationMinutes: durationMinutes,
      startTime: DateTime.now(),
      completed: false,
      pointsEarned: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _sessions.add(session);
    await _saveSessions();
    notifyListeners();
    return session;
  }

  Future<void> completeSession(String sessionId, int actualMinutes) async {
    final index = _sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;
    
    final points = (actualMinutes / 5).floor() * 10;
    _sessions[index] = _sessions[index].copyWith(
      endTime: DateTime.now(),
      completed: true,
      pointsEarned: points,
      updatedAt: DateTime.now(),
    );
    
    await _saveSessions();
    notifyListeners();
  }
}
