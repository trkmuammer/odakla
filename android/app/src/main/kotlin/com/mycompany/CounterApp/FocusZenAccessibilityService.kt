package com.mycompany.CounterApp

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent

class FocusZenAccessibilityService : AccessibilityService() {
  override fun onAccessibilityEvent(event: AccessibilityEvent?) {
    if (event == null) return
    if (!FocusZenBlockState.isBlockingEnabled(applicationContext)) return

    val blockUntil = FocusZenBlockState.getBlockUntilEpochMs(applicationContext)
    if (blockUntil > 0 && System.currentTimeMillis() > blockUntil) {
      FocusZenBlockState.setBlockingEnabled(applicationContext, false)
      FocusZenBlockState.setBlockUntilEpochMs(applicationContext, 0L)
      return
    }

    val packageName = event.packageName?.toString() ?: return
    val allowPackage = FocusZenBlockState.getAllowPackage(applicationContext)

    // Ignore our own app.
    if (packageName == allowPackage) return

    // Only react to window changes / app switches.
    if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED &&
      event.eventType != AccessibilityEvent.TYPE_WINDOWS_CHANGED) {
      return
    }

    // Bring our lock screen to front.
    val intent = Intent(this, FocusZenLockActivity::class.java)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
    startActivity(intent)
  }

  override fun onInterrupt() {
    // no-op
  }
}
