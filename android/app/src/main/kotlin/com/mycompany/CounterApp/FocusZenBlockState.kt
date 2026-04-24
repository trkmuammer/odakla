package com.mycompany.CounterApp

import android.content.Context

internal object FocusZenBlockState {
  private const val prefsName = "focuszen_blocker"
  private const val keyEnabled = "enabled"
  private const val keyAllowPackage = "allow_package"
  private const val keyBlockUntil = "block_until_epoch_ms"

  private fun prefs(context: Context) = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)

  fun isBlockingEnabled(context: Context): Boolean = prefs(context).getBoolean(keyEnabled, false)

  fun setBlockingEnabled(context: Context, enabled: Boolean) {
    prefs(context).edit().putBoolean(keyEnabled, enabled).apply()
  }

  fun getAllowPackage(context: Context): String = prefs(context).getString(keyAllowPackage, context.packageName) ?: context.packageName

  fun setAllowPackage(context: Context, allowPackage: String) {
    prefs(context).edit().putString(keyAllowPackage, allowPackage).apply()
  }

  fun getBlockUntilEpochMs(context: Context): Long = prefs(context).getLong(keyBlockUntil, 0L)

  fun setBlockUntilEpochMs(context: Context, epochMs: Long) {
    prefs(context).edit().putLong(keyBlockUntil, epochMs).apply()
  }
}
