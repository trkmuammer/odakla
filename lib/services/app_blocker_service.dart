import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// System-level app blocking bridge.
///
/// iOS: Uses FamilyControls/ManagedSettings (Screen Time API) when available.
/// Android: Uses an AccessibilityService-based "soft block" (brings a lock screen on top).
///
/// Note: Both platforms require explicit user authorization in system settings.
class AppBlockerService {
  static const MethodChannel _channel = MethodChannel('focuszen/app_blocker');

  /// Returns whether the current platform has a native implementation.
  static Future<bool> isSupported() async {
    try {
      if (kIsWeb) return false;
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } catch (e) {
      debugPrint('AppBlockerService.isSupported failed: $e');
      return false;
    }
  }

  /// Triggers the relevant permission / authorization flow.
  ///
  /// Android: opens Accessibility settings.
  /// iOS: triggers Screen Time / FamilyControls authorization request (if available).
  static Future<bool> requestAuthorization() async {
    try {
      if (kIsWeb) return false;
      final result = await _channel.invokeMethod<bool>('requestAuthorization');
      return result ?? false;
    } catch (e) {
      debugPrint('AppBlockerService.requestAuthorization failed: $e');
      return false;
    }
  }

  /// Enables blocking mode.
  ///
  /// [allowPackage] is only used on Android to avoid blocking this app.
  static Future<void> startBlocking({required int durationSeconds, String? allowPackage}) async {
    try {
      if (kIsWeb) return;
      final args = <String, dynamic>{'durationSeconds': durationSeconds};
      if (Platform.isAndroid) args['allowPackage'] = allowPackage;
      await _channel.invokeMethod<void>('startBlocking', args);
    } catch (e) {
      debugPrint('AppBlockerService.startBlocking failed: $e');
    }
  }

  static Future<void> stopBlocking() async {
    try {
      if (kIsWeb) return;
      await _channel.invokeMethod<void>('stopBlocking');
    } catch (e) {
      debugPrint('AppBlockerService.stopBlocking failed: $e');
    }
  }

  /// Android convenience: opens Accessibility settings so the user can enable the service.
  static Future<void> openAndroidAccessibilitySettings() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return;
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } catch (e) {
      debugPrint('AppBlockerService.openAndroidAccessibilitySettings failed: $e');
    }
  }
}
