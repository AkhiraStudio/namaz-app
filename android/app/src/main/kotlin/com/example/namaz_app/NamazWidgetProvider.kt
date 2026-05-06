package com.example.namaz_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

private const val PREFS = "HomeWidgetPreferences"
private val COLOR_GREEN   = Color.parseColor("#6BAF6D")
private val COLOR_ORANGE  = Color.parseColor("#DB880A")
private val COLOR_RED     = Color.parseColor("#C25850")
private val COLOR_GOLD    = Color.parseColor("#D4A843")

class NamazWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            try {
                _updateWidget(context, appWidgetManager, id)
                android.util.Log.d("NamazWidget", "Widget $id updated OK")
            } catch (e: Exception) {
                android.util.Log.e("NamazWidget", "Widget $id failed: ${e.message}", e)
            }
        }
        scheduleMinuteUpdate(context)
    }

    // Démarre la chaîne dès que le premier widget est ajouté
    override fun onEnabled(context: Context) {
        scheduleMinuteUpdate(context)
    }

    // Annule la chaîne quand le dernier widget est retiré
    override fun onDisabled(context: Context) {
        cancelMinuteUpdate(context)
    }
}

private fun scheduleMinuteUpdate(context: Context) {
    val ids = AppWidgetManager.getInstance(context)
        .getAppWidgetIds(ComponentName(context, NamazWidgetProvider::class.java))
    if (ids.isEmpty()) return

    val intent = Intent(context, NamazWidgetProvider::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
    }
    val pending = PendingIntent.getBroadcast(
        context, 0, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    // setExactAndAllowWhileIdle : se déclenche même en mode Doze (écran éteint)
    // Android le limite à ~9 min pendant le Doze profond, mais toutes les minutes quand l'écran est allumé
    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, System.currentTimeMillis() + 60_000L, pending)
}

private fun cancelMinuteUpdate(context: Context) {
    val intent = Intent(context, NamazWidgetProvider::class.java).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
    }
    val pending = PendingIntent.getBroadcast(
        context, 0, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(pending)
}

private fun _updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
    val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    val fmt = SimpleDateFormat("HH:mm", Locale.getDefault())

    val sunrise    = prefs.getString("sunrise_time", "—") ?: "—"
    val hijriDate  = prefs.getString("hijri_date", "—") ?: "—"
    val fajrTime   = prefs.getString("fajr_time", "—") ?: "—"
    val dhuhrTime  = prefs.getString("dhuhr_time", "—") ?: "—"
    val asrTime    = prefs.getString("asr_time", "—") ?: "—"
    val maghribTime = prefs.getString("maghrib_time", "—") ?: "—"
    val ishaTime   = prefs.getString("isha_time", "—") ?: "—"

    val views = RemoteViews(context.packageName, R.layout.widget_next_prayer)
    val nowMs = System.currentTimeMillis()

    // Calcul toujours frais — ne dépend pas des valeurs écrites par Flutter
    val currentWindow = computeCurrentWindow(nowMs, fajrTime, sunrise, dhuhrTime, asrTime, maghribTime, ishaTime)
    val currentName   = currentWindow?.first  ?: ""
    val windowStartMs = currentWindow?.second ?: 0L
    val windowEndMs   = currentWindow?.third  ?: 0L
    val nextName      = computeNextPrayer(nowMs, fajrTime, dhuhrTime, asrTime, maghribTime, ishaTime)
    val hasCurrent    = currentWindow != null

    var dynamicColor = COLOR_GOLD

    if (hasCurrent) {
        views.setViewVisibility(R.id.ll_top_section, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.bar_container, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.ll_window_times, android.view.View.VISIBLE)
        views.setViewVisibility(R.id.ll_next_big, android.view.View.GONE)
        val totalMs = windowEndMs - windowStartMs
        val elapsedMs = (nowMs - windowStartMs).coerceIn(0L, totalMs)
        val progress = elapsedMs.toFloat() / totalMs

        val options = manager.getAppWidgetOptions(widgetId)
        val minWidthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
        val density = context.resources.displayMetrics.density
        val widthPx = (minWidthDp * density).toInt().coerceAtLeast(200)

        val bitmap = buildTricolorBitmap(context, progress, widthPx)
        views.setImageViewBitmap(R.id.img_tricolor_bar, bitmap)

        val status = when {
            progress < 0.2f -> "Début de l'heure"
            progress < 0.8f -> "Temps idéal"
            else            -> "Fin proche"
        }

        val remainingMs = (windowEndMs - nowMs).coerceAtLeast(0)
        val hours = (remainingMs / 3_600_000).toInt()
        val minutes = ((remainingMs % 3_600_000) / 60_000).toInt()
        val remaining = if (hours > 0) "Il reste ${hours}h ${minutes}min" else "Il reste ${minutes}min"

        dynamicColor = when {
            progress < 0.2f -> COLOR_GREEN
            progress < 0.8f -> COLOR_ORANGE
            else            -> COLOR_RED
        }

        views.setTextViewText(R.id.tv_current_prayer_name, currentName)
        views.setTextViewText(R.id.tv_current_prayer_status, "$status • $remaining")
        views.setTextColor(R.id.tv_current_prayer_name, dynamicColor)
        views.setTextColor(R.id.tv_current_prayer_status, context.getColor(R.color.widget_text_status))
        views.setTextViewText(R.id.tv_window_start, fmt.format(Date(windowStartMs)))
        views.setTextViewText(R.id.tv_window_end, fmt.format(Date(windowEndMs)))

    } else {
        views.setViewVisibility(R.id.ll_top_section, android.view.View.GONE)
        views.setViewVisibility(R.id.bar_container, android.view.View.GONE)
        views.setViewVisibility(R.id.ll_window_times, android.view.View.GONE)
        views.setViewVisibility(R.id.ll_next_big, android.view.View.VISIBLE)

        val nextTime = when (nextName) {
            "Fajr"    -> fajrTime
            "Dhuhr"   -> dhuhrTime
            "Asr"     -> asrTime
            "Maghrib" -> maghribTime
            "Isha"    -> ishaTime
            else      -> "—"
        }

        val countdown = minutesUntilTime(nextTime).let { mins ->
            if (mins <= 0L) "" else {
                val h = mins / 60; val m = mins % 60
                if (h > 0) "dans ${h}h ${m}min" else "dans ${m}min"
            }
        }

        views.setTextViewText(R.id.tv_next_big_name, nextName.ifEmpty { "—" })
        views.setTextViewText(R.id.tv_next_big_countdown, countdown)
    }

    views.setTextViewText(R.id.tv_sunrise, "☀ $sunrise")
    views.setTextViewText(R.id.tv_hijri_date, hijriDate)

    views.setTextViewText(R.id.tv_fajr_time, fajrTime)
    views.setTextViewText(R.id.tv_dhuhr_time, dhuhrTime)
    views.setTextViewText(R.id.tv_asr_time, asrTime)
    views.setTextViewText(R.id.tv_maghrib_time, maghribTime)
    views.setTextViewText(R.id.tv_isha_time, ishaTime)

    // Couleur de mise en évidence : dynamique (vert/orange/rouge) si prière en cours, or pour la suivante
    val highlight = if (currentName.isNotEmpty()) currentName else nextName
    val highlightColor = if (hasCurrent) dynamicColor else COLOR_GOLD
    val defaultTimeColor = context.getColor(R.color.widget_prayer_time)

    data class PrayerRow(val name: String, val timeId: Int, val lineId: Int)
    val rows = listOf(
        PrayerRow("Fajr",    R.id.tv_fajr_time,    R.id.line_fajr),
        PrayerRow("Dhuhr",   R.id.tv_dhuhr_time,   R.id.line_dhuhr),
        PrayerRow("Asr",     R.id.tv_asr_time,     R.id.line_asr),
        PrayerRow("Maghrib", R.id.tv_maghrib_time, R.id.line_maghrib),
        PrayerRow("Isha",    R.id.tv_isha_time,    R.id.line_isha),
    )
    for (row in rows) {
        val isHighlighted = row.name == highlight
        views.setTextColor(row.timeId, if (isHighlighted) highlightColor else defaultTimeColor)
        views.setViewVisibility(row.lineId, if (isHighlighted) android.view.View.VISIBLE else android.view.View.INVISIBLE)
        if (isHighlighted) views.setInt(row.lineId, "setBackgroundColor", highlightColor)
    }

    manager.updateAppWidget(widgetId, views)
}

private fun buildTricolorBitmap(context: Context, progress: Float, widthPx: Int): Bitmap {
    val heightPx = (14 * context.resources.displayMetrics.density).toInt().coerceAtLeast(14)
    val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bmp)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    val radius = heightPx / 2f
    val w = widthPx.toFloat()
    val h = heightPx.toFloat()
    val p = progress.coerceIn(0f, 1f)
    val cursorX = w * p

    // Clip tout dans le contour arrondi
    val path = android.graphics.Path()
    path.addRoundRect(RectF(0f, 0f, w, h), radius, radius, android.graphics.Path.Direction.CW)
    canvas.clipPath(path)

    // Zones toujours visibles en opacité réduite (couleurs app)
    paint.color = Color.argb(70, 0x6B, 0xAF, 0x6D)  // prayerEarly
    canvas.drawRect(RectF(0f, 0f, w * 0.2f, h), paint)
    paint.color = Color.argb(70, 0xDB, 0x88, 0x0A)  // prayerOnTime
    canvas.drawRect(RectF(w * 0.2f, 0f, w * 0.8f, h), paint)
    paint.color = Color.argb(70, 0xC2, 0x58, 0x50)  // prayerLate
    canvas.drawRect(RectF(w * 0.8f, 0f, w, h), paint)

    // Partie écoulée en pleine opacité
    if (cursorX > 0f) {
        paint.color = COLOR_GREEN
        canvas.drawRect(RectF(0f, 0f, minOf(cursorX, w * 0.2f), h), paint)
        if (cursorX > w * 0.2f) {
            paint.color = COLOR_ORANGE
            canvas.drawRect(RectF(w * 0.2f, 0f, minOf(cursorX, w * 0.8f), h), paint)
        }
        if (cursorX > w * 0.8f) {
            paint.color = COLOR_RED
            canvas.drawRect(RectF(w * 0.8f, 0f, cursorX, h), paint)
        }
    }

    // Curseur à la position actuelle
    if (p > 0f && p < 1f) {
        paint.color = Color.parseColor("#FAF6F0")
        paint.strokeWidth = 2f * context.resources.displayMetrics.density
        canvas.drawLine(cursorX, 0f, cursorX, h, paint)
    }

    return bmp
}

private fun buildEmptyBitmap(context: Context): Bitmap {
    val density  = context.resources.displayMetrics.density
    val widthPx  = (200 * density).toInt()
    val heightPx = (14 * density).toInt().coerceAtLeast(14)
    val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bmp)
    val paint = Paint(Paint.ANTI_ALIAS_FLAG)
    val radius = heightPx / 2f
    val w = widthPx.toFloat()
    val h = heightPx.toFloat()

    val path = android.graphics.Path()
    path.addRoundRect(RectF(0f, 0f, w, h), radius, radius, android.graphics.Path.Direction.CW)
    canvas.clipPath(path)

    // Mêmes 3 zones, juste sans progression ni curseur
    paint.color = Color.argb(70, 0x6B, 0xAF, 0x6D)
    canvas.drawRect(RectF(0f, 0f, w * 0.2f, h), paint)
    paint.color = Color.argb(70, 0xDB, 0x88, 0x0A)
    canvas.drawRect(RectF(w * 0.2f, 0f, w * 0.8f, h), paint)
    paint.color = Color.argb(70, 0xC2, 0x58, 0x50)
    canvas.drawRect(RectF(w * 0.8f, 0f, w, h), paint)

    return bmp
}
