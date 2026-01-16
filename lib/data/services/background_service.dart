import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/services.dart';
import 'package:year_dots/data/services/wallpaper_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:year_dots/core/constants/app_colors.dart';

const String taskName = "year_dots_daily_update";

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Workmanager().executeTask((task, inputData) async {
    print("BackgroundService: Executing task: $task");
    switch (task) {
      case taskName:
        debugPrint("Background Service: Starting task $taskName");
        try {
          // Initialize SharedPreferences in background isolate
          final prefs = await SharedPreferences.getInstance();
          final themeId = prefs.getString('theme_id') ?? 'default';
          debugPrint("Background Service: Theme loaded ID: $themeId");

          AppTheme theme;
          if (themeId.startsWith('custom_')) {
             final colorValue = prefs.getInt('theme_color') ?? AppColors.primary.value;
             final textColorValue = prefs.getInt('theme_text_color'); // Nullable
             final bgColorValue = prefs.getInt('theme_background'); // New
             final styleIndex = prefs.getInt('theme_style') ?? 0;
             final showText = prefs.getBool('theme_show_text') ?? true;

             final gridColumns = prefs.getInt('theme_grid_columns') ?? 15;
             
             final base = AppTheme.defaults;
             
             Color textPrimary = base.textPrimary;
             Color textSecondary = base.textSecondary;

             if (textColorValue != null) {
                final customText = Color(textColorValue);
                textPrimary = customText;
                textSecondary = customText.withOpacity(0.6);
             }

             theme = AppTheme(
               id: themeId,
               name: 'Custom',
               background: bgColorValue != null ? Color(bgColorValue) : base.background, // Use custom BG
               surface: base.surface,
               dotPassed: base.dotPassed,
               dotToday: Color(colorValue),
               dotFuture: base.dotFuture,
               textPrimary: textPrimary,
               textSecondary: textSecondary,
               dotStyle: DotStyle.values[styleIndex],
               showText: showText,
               gridColumns: gridColumns,
             );
          } else {
             theme = AppTheme.fromId(themeId);
          }
          
          final service = WallpaperService();
          final result = await service.updateWallpaper(theme: theme);
          debugPrint("Background Service: Task finished. Result: $result");
          return result;
        } catch (e, stack) {
          debugPrint("Background Service: Error: $e");
          debugPrintStack(stackTrace: stack);
          return false;
        }
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
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> registerDailyTask({
    Duration frequency = const Duration(hours: 24),
    Duration initialDelay = Duration.zero,
    bool requiresBatteryNotLow = false,
  }) async {
    if (kIsWeb) return;
    await Workmanager().registerPeriodicTask(
      "1", // Unique Name
      taskName,
      frequency: frequency,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: requiresBatteryNotLow,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingWorkPolicy.update, // Use update to preserve if running, or replace? Replace is safer for rescheduling.
    );
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
