package com.example.fit_life

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.app.AppOpsManager
import android.content.pm.PackageManager
import android.util.Log
import android.provider.Settings
import java.util.Calendar
import java.util.concurrent.TimeUnit


class MainActivity: FlutterFragmentActivity() {

    private val USAGE_STATS_PERMISSION_REQUEST_CODE = 1000

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kotlinChannel").setMethodCallHandler {
          call, result ->
            if(call.method == "getUsageStats") {

                val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager

                val mode = appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(), packageName
                )

                if(mode != AppOpsManager.MODE_ALLOWED){
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    startActivity(intent)
                    result.error("PERMISSION_DENIED", "Usage stats permission not granted", null)
                }
                else{

                    val usageStatsManager = this.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
                    val calendar = Calendar.getInstance()
                    val endTimeRounded = calendar.timeInMillis

                    calendar.set(Calendar.HOUR_OF_DAY, 0)
                    calendar.set(Calendar.MINUTE, 0)
                    calendar.set(Calendar.SECOND, 0)
                    calendar.set(Calendar.MILLISECOND, 0)
                    val startTime = calendar.timeInMillis

                    val intervalData = mutableListOf<List<Map<String, Long>>>()

                    var currentHourStart = startTime;


                    while(currentHourStart < endTimeRounded){
                        val usageStats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, currentHourStart, currentHourStart + TimeUnit.HOURS.toMillis(1))

                        
                        
                        val screenTimeMap = mutableMapOf<String, Long>()
                        usageStats?.forEach {
                            screenTimeMap[it.packageName] = it.totalTimeInForeground
                        }
                        
                        // Remove 0 values
                        val iterator = screenTimeMap.entries.iterator()
                        while (iterator.hasNext()) {
                            val entry = iterator.next()
                            if (entry.value == 0L) {
                                iterator.remove()
                            }
                        }
                        
                        val sortedScreenTimeMap = screenTimeMap.toList().sortedByDescending{(_, value) -> value}.toMap()
                        val listSortedScreenTimeMap = listOf(sortedScreenTimeMap)
                        intervalData.add(listSortedScreenTimeMap)
                        currentHourStart = currentHourStart + TimeUnit.HOURS.toMillis(1)
                    }
                    result.success(intervalData)
                }
                    
                }
                else {
                    result.notImplemented()
            }
        }
    }

}