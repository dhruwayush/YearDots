import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:year_dots/core/utils/image_generator.dart';
import 'package:year_dots/domain/logic/date_logic.dart';

class WallpaperService {
  
  /// Generates the wallpaper for today and sets it.
  Future<bool> updateWallpaper() async {
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

      final file = await ImageGenerator.generateWallpaperFile(progress);

      // 3. Set Wallpaper
      // Using async_wallpaper to set both home and lock screen
      // If validation fails, we might try different platform channels or plugins
      bool result = await AsyncWallpaper.setWallpaperFromFile(
        filePath: file.path, 
        wallpaperLocation: AsyncWallpaper.HOME_SCREEN, // Or BOTH
        goToHome: false,
      );
      
       // Set for Lock screen too if needed, or use BOTH constant if available plugin supports simple 'BOTH'
       // async_wallpaper usually supports individual calls.
       await AsyncWallpaper.setWallpaperFromFile(
        filePath: file.path, 
        wallpaperLocation: AsyncWallpaper.LOCK_SCREEN,
        goToHome: false,
      );

      return result;
    } on PlatformException {
      return false;
    } catch (e) {
      return false;
    }
  }
}
