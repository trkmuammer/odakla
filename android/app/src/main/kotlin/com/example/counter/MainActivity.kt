package com.mycompany.CounterApp

import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channelName = "focuszen/app_blocker"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
      when (call.method) {
        "isSupported" -> result.success(true)
        "requestAuthorization" -> {
          // On Android the user must enable the accessibility service manually.
          openAccessibilitySettings()
          result.success(true)
        }
        "openAccessibilitySettings" -> {
          openAccessibilitySettings()
          result.success(null)
        }
        "startBlocking" -> {
          val durationSeconds = (call.argument<Int>("durationSeconds") ?: 0)
          val allowPackage = call.argument<String>("allowPackage") ?: applicationContext.packageName
          FocusZenBlockState.setBlockingEnabled(applicationContext, true)
          FocusZenBlockState.setAllowPackage(applicationContext, allowPackage)
          FocusZenBlockState.setBlockUntilEpochMs(
            applicationContext,
            if (durationSeconds > 0) System.currentTimeMillis() + durationSeconds * 1000L else 0L
          )
          result.success(null)
        }
        "stopBlocking" -> {
          FocusZenBlockState.setBlockingEnabled(applicationContext, false)
          FocusZenBlockState.setBlockUntilEpochMs(applicationContext, 0L)
          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }

  private fun openAccessibilitySettings() {
    try {
      val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      startActivity(intent)
    } catch (_: Exception) {
      // ignore
    }
  }
}
