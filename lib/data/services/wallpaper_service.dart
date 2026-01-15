import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:year_dots/core/utils/image_generator.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/domain/logic/date_logic.dart';

class WallpaperService {
  
  /// Generates the wallpaper for today and sets it.
  /// Generates the wallpaper for today and sets it.
  Future<bool> updateWallpaper({required AppTheme theme}) async {
    try {
      // 1. Calculate Data
      final progress = DateLogic.calculateProgress();

      // 2. Generate Image
      // On Web, generating a File object might work but saving/path_provider/setting wallpaper is different.
      // For now, let's just return true if on web to avoid crash, effectively "Mocking" it.
      if (kIsWeb) {
        debugPrint("Wallpaper update simulated on Web");
        return true;
      }

      final file = await ImageGenerator.generateWallpaperFile(progress, theme);
      debugPrint("WallpaperService: Generated file at ${file.path}");

      // 3. Set Wallpaper
      // User requested ONLY Lock Screen
      bool resultLock = await AsyncWallpaper.setWallpaperFromFile(
        filePath: file.path, 
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        goToHome: false,
      );

      return resultLock;

    } on PlatformException catch (e) {
      debugPrint("WallpaperService: PlatformException: ${e.message}");
      return false;
    } catch (e, stack) {
      debugPrint("WallpaperService: Error: $e");
      debugPrintStack(stackTrace: stack);
      return false;
    }
  }
}
