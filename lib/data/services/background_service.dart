import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Background service has been disabled as workmanager dependency was removed
// This is a stub to maintain compatibility with existing code

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return;
    // Workmanager removed - no background tasks
    debugPrint("BackgroundService: Disabled (workmanager removed)");
  }

  static Future<void> registerDailyTask({
    Duration frequency = const Duration(hours: 24),
    Duration initialDelay = Duration.zero,
    bool requiresBatteryNotLow = false,
  }) async {
    if (kIsWeb) return;
    // Workmanager removed - no background tasks
    debugPrint("BackgroundService: Daily task registration disabled");
  }

  static const platform = MethodChannel('com.yeardots.year_dots/native');

  static Future<void> openLiveWallpaperPicker() async {
    try {
      if (kIsWeb) return;
      await platform.invokeMethod('openLiveWallpaperPicker');
    } on PlatformException catch (e) {
      debugPrint("Failed to open picker: ${e.message}");
    }
  }
}
