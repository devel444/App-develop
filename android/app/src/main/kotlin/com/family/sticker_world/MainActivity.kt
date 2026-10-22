package com.family.sticker_world

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sticker_world/usage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasAccess" -> result.success(hasUsageAccess())
                    "openSettings" -> {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(null)
                    }
                    "minutesToday" -> {
                        if (!hasUsageAccess()) {
                            result.success(null)
                        } else {
                            result.success(minutesToday(call.argument<String>("package")))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /// 오늘 0시부터 지금까지 그 앱이 화면 앞에 있었던 분.
    private fun minutesToday(packageName: String?): Int {
        if (packageName == null) {
            return 0
        }
        val usageManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val startOfDay = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        val stats = usageManager.queryAndAggregateUsageStats(startOfDay, System.currentTimeMillis())
        val millis = stats[packageName]?.totalTimeInForeground ?: 0L
        return (millis / 60000L).toInt()
    }
}
