package com.example.fit_life

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.app.usage.UsageStatsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageEvents.Event
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

                    var i = 1
                    //val intervalData = mutableListOf<Map<String, Long>>()
                    val intervalData = mutableListOf<UsageEvents>()

                    var currentHourStart = startTime
                    calendar.set(Calendar.HOUR_OF_DAY, i)
                    var currentHourEnd = calendar.timeInMillis

                    while(currentHourStart < endTimeRounded){

                        Log.d("start", currentHourStart.toString())
                        Log.d("end", currentHourEnd.toString())

                        val usageStats = usageStatsManager.queryEvents(currentHourStart, currentHourEnd)

                        Log.d("statistics", usageStats.toString())

                        /*
                        val screenTimeMap = mutableMapOf<String, Long>()
                        usageStats?.forEach { event ->
                            screenTimeMap[event.packageName] = event.totalTimeInForeground
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
                        Log.d("stats", sortedScreenTimeMap.toString())
                        
                        intervalData.add(sortedScreenTimeMap)
                        */
                        intervalData.add(usageStats)

                        while(usageStats.hasNextEvent()){
                            val event = UsageEvents.Event()
                            usageStats.getNextEvent(event)
                            Log.d("usage", event.packageName.toString() + "|" + event.eventType + "|" + event.timeStamp)
                        }

                        currentHourStart = currentHourEnd
                        i = i + 1
                        calendar.set(Calendar.HOUR_OF_DAY, i)
                        currentHourEnd = calendar.timeInMillis
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