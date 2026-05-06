package com.example.namaz_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

private const val QADA_PREFS = "HomeWidgetPreferences"
private val QADA_GOLD  = Color.parseColor("#D4A843")
private val QADA_GREEN = Color.parseColor("#6BAF6D")

class QadaTrackerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) {
            try {
                updateQadaWidget(context, appWidgetManager, id)
            } catch (e: Exception) {
                android.util.Log.e("QadaWidget", "Failed: ${e.message}", e)
            }
        }
    }
}

private fun updateQadaWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
    val prefs = context.getSharedPreferences(QADA_PREFS, Context.MODE_PRIVATE)

    val hasProgram  = (prefs.all["qada_has_program"]?.toString()?.toIntOrNull() ?: 0) == 1
    val dailyTarget = prefs.all["qada_daily_target"]?.toString()?.toIntOrNull() ?: 5
    val streak      = prefs.all["qada_streak"]?.toString()?.toIntOrNull()       ?: 0
    val todayTotal  = prefs.all["qada_today_total"]?.toString()?.toIntOrNull()  ?: 0
    val remaining   = prefs.all["qada_remaining"]?.toString()?.toIntOrNull()    ?: 0

    val views = RemoteViews(context.packageName, R.layout.widget_qada_tracker)

    // Tap sur le widget → écran Rattrapages
    val pi = HomeWidgetLaunchIntent.getActivity(
        context, MainActivity::class.java, Uri.parse("namaz://open/qada"))
    views.setOnClickPendingIntent(R.id.widget_root, pi)

    if (!hasProgram) {
        views.setViewVisibility(R.id.tv_qada_streak, android.view.View.GONE)
        views.setViewVisibility(R.id.ll_no_program,  android.view.View.VISIBLE)
        views.setViewVisibility(R.id.ll_has_program, android.view.View.GONE)
        manager.updateAppWidget(widgetId, views)
        return
    }

    views.setViewVisibility(R.id.tv_qada_streak, android.view.View.VISIBLE)
    views.setViewVisibility(R.id.ll_no_program,  android.view.View.GONE)
    views.setViewVisibility(R.id.ll_has_program, android.view.View.VISIBLE)

    // Streak
    views.setTextViewText(R.id.tv_qada_streak, "🔥 $streak jours")

    // Barre de progression journalière
    val goalReached = todayTotal >= dailyTarget && dailyTarget > 0
    val progress    = if (dailyTarget > 0) todayTotal.toFloat() / dailyTarget else 0f
    val options     = manager.getAppWidgetOptions(widgetId)
    val minWidthDp  = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
    val density     = context.resources.displayMetrics.density
    val widthPx     = (minWidthDp * density).toInt().coerceAtLeast(100)
    views.setImageViewBitmap(R.id.img_qada_bar, buildQadaBar(context, progress, widthPx, goalReached))
    views.setTextViewText(R.id.tv_qada_today, "$todayTotal / $dailyTarget")
    views.setTextColor(R.id.tv_qada_today, if (goalReached) QADA_GREEN else QADA_GOLD)

    val estimateText = when {
        remaining == 0          -> "Programme terminé ✓"
        dailyTarget <= 0        -> ""
        else -> {
            val days = Math.ceil(remaining.toDouble() / dailyTarget).toInt()
            "~$days jours à ce rythme"
        }
    }
    views.setTextViewText(R.id.tv_qada_estimate, estimateText)

    // Restant par prière — vert si 0, or sinon
    fun remColor(n: Int) = if (n == 0) QADA_GREEN else QADA_GOLD
    val remFajr    = prefs.all["qada_rem_fajr"]?.toString()?.toIntOrNull()    ?: 0
    val remDhuhr   = prefs.all["qada_rem_dhuhr"]?.toString()?.toIntOrNull()   ?: 0
    val remAsr     = prefs.all["qada_rem_asr"]?.toString()?.toIntOrNull()     ?: 0
    val remMaghrib = prefs.all["qada_rem_maghrib"]?.toString()?.toIntOrNull() ?: 0
    val remIsha    = prefs.all["qada_rem_isha"]?.toString()?.toIntOrNull()    ?: 0
    views.setTextViewText(R.id.tv_rem_fajr,    remFajr.toString())
    views.setTextViewText(R.id.tv_rem_dhuhr,   remDhuhr.toString())
    views.setTextViewText(R.id.tv_rem_asr,     remAsr.toString())
    views.setTextViewText(R.id.tv_rem_maghrib, remMaghrib.toString())
    views.setTextViewText(R.id.tv_rem_isha,    remIsha.toString())
    views.setTextColor(R.id.tv_rem_fajr,    remColor(remFajr))
    views.setTextColor(R.id.tv_rem_dhuhr,   remColor(remDhuhr))
    views.setTextColor(R.id.tv_rem_asr,     remColor(remAsr))
    views.setTextColor(R.id.tv_rem_maghrib, remColor(remMaghrib))
    views.setTextColor(R.id.tv_rem_isha,    remColor(remIsha))

    manager.updateAppWidget(widgetId, views)
}

private fun buildQadaBar(context: Context, progress: Float, widthPx: Int, goalReached: Boolean): Bitmap {
    val density  = context.resources.displayMetrics.density
    val heightPx = (12 * density).toInt().coerceAtLeast(12)
    val bmp = Bitmap.createBitmap(widthPx, heightPx, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bmp)
    val paint  = Paint(Paint.ANTI_ALIAS_FLAG)
    val radius = heightPx / 2f
    val w = widthPx.toFloat()
    val h = heightPx.toFloat()
    val p = progress.coerceIn(0f, 1f)
    val fillColor = if (goalReached) QADA_GREEN else QADA_GOLD

    val path = android.graphics.Path()
    path.addRoundRect(RectF(0f, 0f, w, h), radius, radius, android.graphics.Path.Direction.CW)
    canvas.clipPath(path)

    paint.color = Color.argb(60, 0xD4, 0xA8, 0x43)
    canvas.drawRect(RectF(0f, 0f, w, h), paint)

    if (p > 0f) {
        paint.color = fillColor
        canvas.drawRect(RectF(0f, 0f, w * p, h), paint)
    }

    return bmp
}
