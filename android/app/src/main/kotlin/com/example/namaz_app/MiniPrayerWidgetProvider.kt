package com.example.namaz_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews

private const val MINI_PREFS = "HomeWidgetPreferences"
private const val MINI_REQUEST_CODE = 1

class MiniPrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            try {
                updateMiniWidget(context, appWidgetManager, id)
            } catch (e: Exception) {
                android.util.Log.e("MiniWidget", "Failed: ${e.message}", e)
            }
        }
        scheduleMiniUpdate(context)
    }

    override fun onEnabled(context: Context)  { scheduleMiniUpdate(context) }
    override fun onDisabled(context: Context) { cancelMiniUpdate(context) }
}

private fun scheduleMiniUpdate(context: Context) {
    val ids = AppWidgetManager.getInstance(context)
        .getAppWidgetIds(ComponentName(context, MiniPrayerWidgetProvider::class.java))
    if (ids.isEmpty()) return

    val intent = Intent(context, MiniPrayerWidgetProvider::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
    }
    val pending = PendingIntent.getBroadcast(
        context, MINI_REQUEST_CODE, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
        .setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + 60_000L, pending)
}

private fun cancelMiniUpdate(context: Context) {
    val intent = Intent(context, MiniPrayerWidgetProvider::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
    }
    val pending = PendingIntent.getBroadcast(
        context, MINI_REQUEST_CODE, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
}

private fun updateMiniWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
    val prefs  = context.getSharedPreferences(MINI_PREFS, Context.MODE_PRIVATE)
    val nowMs  = System.currentTimeMillis()

    val fajrTime    = prefs.getString("fajr_time",    "—") ?: "—"
    val dhuhrTime   = prefs.getString("dhuhr_time",   "—") ?: "—"
    val asrTime     = prefs.getString("asr_time",     "—") ?: "—"
    val maghribTime = prefs.getString("maghrib_time", "—") ?: "—"
    val ishaTime    = prefs.getString("isha_time",    "—") ?: "—"
    val sunriseTime = prefs.getString("sunrise_time", "—") ?: "—"

    val views = RemoteViews(context.packageName, R.layout.widget_mini_prayer)

    val currentWindow = computeCurrentWindow(nowMs, fajrTime, sunriseTime, dhuhrTime, asrTime, maghribTime, ishaTime)

    if (currentWindow != null) {
        val (name, startMs, endMs) = currentWindow
        val remainingMs = (endMs - nowMs).coerceAtLeast(0)
        val h = (remainingMs / 3_600_000).toInt()
        val m = ((remainingMs % 3_600_000) / 60_000).toInt()
        val remaining = if (h > 0) "Il reste ${h}h ${m}min" else "Il reste ${m}min"

        val progress = ((nowMs - startMs).toFloat() / (endMs - startMs)).coerceIn(0f, 1f)
        val color = when {
            progress < 0.2f -> Color.parseColor("#6BAF6D")
            progress < 0.8f -> Color.parseColor("#DB880A")
            else            -> Color.parseColor("#C25850")
        }
        views.setTextViewText(R.id.tv_mini_name, name)
        views.setTextColor(R.id.tv_mini_name, color)
        views.setTextViewText(R.id.tv_mini_countdown, remaining)
        views.setTextViewText(R.id.tv_mini_status, when {
            progress < 0.2f -> "Début de l'heure"
            progress < 0.8f -> "Temps idéal"
            else            -> "Fin proche"
        })
    } else {
        val nextName = computeNextPrayer(nowMs, fajrTime, dhuhrTime, asrTime, maghribTime, ishaTime)
        val nextTime = when (nextName) {
            "Fajr"    -> fajrTime;  "Dhuhr"   -> dhuhrTime
            "Asr"     -> asrTime;   "Maghrib" -> maghribTime
            "Isha"    -> ishaTime;  else      -> "—"
        }
        val mins = minutesUntilTime(nextTime)
        val h = mins / 60; val m = mins % 60
        val countdown = if (h > 0) "dans ${h}h ${m}min" else "dans ${m}min"

        views.setTextViewText(R.id.tv_mini_name, nextName)
        views.setTextColor(R.id.tv_mini_name, Color.parseColor("#D4A843"))
        views.setTextViewText(R.id.tv_mini_countdown, countdown)
        views.setTextViewText(R.id.tv_mini_status, "Prochaine prière")
    }

    manager.updateAppWidget(widgetId, views)
}
