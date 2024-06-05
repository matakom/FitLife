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
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString


@Serializable
data class Data(val name: String, val type: Int, val timeStamp: Long)

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
                    val endTime = calendar.timeInMillis

                    calendar.set(Calendar.HOUR_OF_DAY, 0)
                    calendar.set(Calendar.MINUTE, 0)
                    calendar.set(Calendar.SECOND, 0)
                    calendar.set(Calendar.MILLISECOND, 0)
                    val startTime = calendar.timeInMillis

                    val myJson = mutableListOf<Data>()

                    val usageStats = usageStatsManager.queryEvents(startTime, endTime)

                    while(usageStats.hasNextEvent()){
                        val event = UsageEvents.Event()
                        usageStats.getNextEvent(event)
                        val appName = getAppName(applicationContext, event.packageName)
                        Log.d("appName", appName)
                        myJson.add(Data(appName, event.eventType, event.timeStamp))
                    }

                    result.success(Json.encodeToString(myJson))
                }
                    
                }
                else {
                    result.notImplemented()
            }
        }
    }
    
    private fun getAppName(context: Context, packageName: String): String {
        return try {
            val packageManager = context.packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            packageManager.getApplicationLabel(applicationInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("MainActivity", "App name not found for package: $packageName")
            packageName // fallback to package name if the app name is not found
        }
    }

}