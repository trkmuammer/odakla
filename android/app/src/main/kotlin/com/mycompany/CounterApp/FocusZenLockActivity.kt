package com.mycompany.CounterApp

import android.app.Activity
import android.os.Bundle
import android.view.WindowManager
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.view.View

class FocusZenLockActivity : Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Keep screen on and show over lock screen (best-effort).
    window.addFlags(
      WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
    )

    // Immersive fullscreen.
    window.decorView.systemUiVisibility = (
      View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
        View.SYSTEM_UI_FLAG_FULLSCREEN or
        View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
      )

    val tv = TextView(this)
    tv.text = "Odak modu aktif\n\nBu süre boyunca diğer uygulamalar kilitli."
    tv.setTextColor(Color.WHITE)
    tv.textSize = 20f
    tv.gravity = Gravity.CENTER
    tv.setBackgroundColor(Color.BLACK)
    setContentView(tv)
  }

  override fun onResume() {
    super.onResume()

    // If blocking was turned off or expired, immediately close.
    if (!FocusZenBlockState.isBlockingEnabled(applicationContext)) {
      finish()
      return
    }

    val until = FocusZenBlockState.getBlockUntilEpochMs(applicationContext)
    if (until > 0 && System.currentTimeMillis() > until) {
      FocusZenBlockState.setBlockingEnabled(applicationContext, false)
      FocusZenBlockState.setBlockUntilEpochMs(applicationContext, 0L)
      finish()
    }
  }

  override fun onBackPressed() {
    // Prevent exiting the lock screen; the user must stop the focus session from within the app.
    // (They can still disable the accessibility service from system settings.)
  }
}
