package com.yeardots.year_dots

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yeardots.year_dots/native"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openLiveWallpaperPicker") {
                try {
                    val intent = android.content.Intent(android.app.WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
                    intent.putExtra(android.app.WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT, 
                        android.content.ComponentName(this, YearDotsWallpaperService::class.java))
                    startActivity(intent)
                    result.success("Opened")
                } catch (e: Exception) {
                     try {
                        val intent = android.content.Intent(android.app.WallpaperManager.ACTION_LIVE_WALLPAPER_CHOOSER)
                        startActivity(intent)
                        result.success("Opened Chooser")
                    } catch (e2: Exception) {
                        result.error("UNAVAILABLE", "Wallpaper picker not available", null)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
