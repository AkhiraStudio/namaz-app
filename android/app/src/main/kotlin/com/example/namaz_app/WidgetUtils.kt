package com.example.namaz_app

fun computeCurrentWindow(
    nowMs: Long,
    fajrTime: String, sunriseTime: String,
    dhuhrTime: String, asrTime: String,
    maghribTime: String, ishaTime: String
): Triple<String, Long, Long>? {
    val ishaMs = parseTimeToTodayMs(ishaTime)
    val windows = listOf(
        Triple("Fajr",    parseTimeToTodayMs(fajrTime),    parseTimeToTodayMs(sunriseTime)),
        Triple("Dhuhr",   parseTimeToTodayMs(dhuhrTime),   parseTimeToTodayMs(asrTime)),
        Triple("Asr",     parseTimeToTodayMs(asrTime),     parseTimeToTodayMs(maghribTime)),
        Triple("Maghrib", parseTimeToTodayMs(maghribTime), parseTimeToTodayMs(ishaTime)),
        Triple("Isha",    ishaMs,                          ishaMs + 3 * 3_600_000L),
    )
    for ((name, start, end) in windows) {
        if (start > 0 && end > start && nowMs >= start && nowMs < end) {
            return Triple(name, start, end)
        }
    }
    return null
}

fun computeNextPrayer(
    nowMs: Long,
    fajrTime: String, dhuhrTime: String, asrTime: String,
    maghribTime: String, ishaTime: String
): String {
    val prayers = listOf(
        "Fajr" to fajrTime, "Dhuhr" to dhuhrTime,
        "Asr"  to asrTime,  "Maghrib" to maghribTime, "Isha" to ishaTime
    )
    for ((name, time) in prayers) {
        if (parseTimeToTodayMs(time) > nowMs) return name
    }
    return "Fajr"
}

fun minutesUntilTime(timeStr: String): Long {
    val parts = timeStr.split(":")
    if (parts.size != 2) return 0L
    val now    = java.util.Calendar.getInstance()
    val target = now.clone() as java.util.Calendar
    target.set(java.util.Calendar.HOUR_OF_DAY, parts[0].toIntOrNull() ?: 0)
    target.set(java.util.Calendar.MINUTE,      parts[1].toIntOrNull() ?: 0)
    target.set(java.util.Calendar.SECOND, 0)
    target.set(java.util.Calendar.MILLISECOND, 0)
    if (target.before(now)) target.add(java.util.Calendar.DAY_OF_YEAR, 1)
    return (target.timeInMillis - now.timeInMillis) / 60_000
}

fun parseTimeToTodayMs(timeStr: String): Long {
    val parts = timeStr.split(":")
    if (parts.size != 2) return 0L
    val cal = java.util.Calendar.getInstance()
    cal.set(java.util.Calendar.HOUR_OF_DAY, parts[0].toIntOrNull() ?: 0)
    cal.set(java.util.Calendar.MINUTE,      parts[1].toIntOrNull() ?: 0)
    cal.set(java.util.Calendar.SECOND, 0)
    cal.set(java.util.Calendar.MILLISECOND, 0)
    return cal.timeInMillis
}
