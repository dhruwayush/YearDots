import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:year_dots/data/services/wallpaper_service.dart';

const String taskName = "year_dots_daily_update";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case taskName:
        final service = WallpaperService();
        return await service.updateWallpaper();
      case Workmanager.iOSBackgroundTask:
         // iOS background task handling if needed
         break;
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    if (kIsWeb) return; // Workmanager not supported on web in this config
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // TODO: Set to false for production
    );
  }

  static Future<void> registerDailyTask() async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      "1", // Unique Name
      taskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      initialDelay: const Duration(seconds: 10), // Optional delay for testing
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
