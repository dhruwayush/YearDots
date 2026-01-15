import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:year_dots/domain/models/year_progress.dart';
import 'package:year_dots/presentation/painters/dot_grid_painter.dart';
import 'package:year_dots/core/constants/app_colors.dart';

class ImageGenerator {
  static Future<File> generateWallpaperFile(YearProgress progress, AppTheme theme) async {
    // 1. Define image size (e.g., standard phone resolution or current screen size)
    // Ideally we get this from the device, but in background we might not have it context.
    // A safe high res vertical stricture is good. 1080x1920 is a safe bet for quality.
    const double width = 1080;
    const double height = 1920;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // 2. Draw Background Explicitly
    final bgPaint = Paint()..color = theme.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // 3. Draw Grid in Middle Zone
    // Define a "safe" middle area for the grid so it doesn't touch top or bottom text
    const double topMargin = 300; 
    const double bottomMargin = 500; // Leave expanded room for stats
    const double gridHeight = height - topMargin - bottomMargin;
    
    canvas.save();
    canvas.translate(0, topMargin);
    // reduce size passed to painter so it centers within this smaller box
    final gridPainter = DotGridPainter(progress: progress, theme: theme);
    gridPainter.paint(canvas, const Size(width, gridHeight));
    canvas.restore();

    // 4. Draw Text
    if (theme.showText) {
      // A helper to draw text centered
      void drawTextCentered(String text, double y, double fontSize, Color color, FontWeight weight, double letterSpacing) {
        final textSpan = TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: weight,
            letterSpacing: letterSpacing,
            fontFamily: 'Roboto', // Default Android font
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: width,
        );
        final x = (width - textPainter.width) / 2;
        textPainter.paint(canvas, Offset(x, y));
      }
  
      // Top Month (Centered in top margin)
      // 300px space. Center around 150px.
      drawTextCentered(
        progress.monthName, 
        120, 
        32, 
        theme.textSecondary, 
        FontWeight.w400, 
        6.0 
      );
  
      // Bottom Stats (Below grid)
      // Starts at height - bottomMargin (e.g. 1920 - 500 = 1420)
      final statsStartY = height - bottomMargin + 100; // Add some padding
      
      drawTextCentered(
        "${progress.dayOfYear} / ${progress.totalDays}",
        statsStartY,
        64,
        theme.textPrimary,
        FontWeight.w400,
        0,
      );
      
      drawTextCentered(
        "${progress.daysLeft} days left",
        statsStartY + 80,
        36,
        theme.textSecondary,
        FontWeight.w400,
        0,
      );
    }

    // 5. Convert to Image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());

    // 4. Encode to PNG
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // 5. Save to file
    // 5. Save to file
    // Use getExternalCacheDir or getExternalStorageDirectory so the system wallpaper service can read it.
    // If external is null (e.g. iOS or weird Android state), fallback to documents
    final directory = await getExternalStorageDirectory();
    final path = directory?.path ?? (await getApplicationDocumentsDirectory()).path;
    
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    // Clean up old wallpapers to avoid clutter
    try {
      final List<FileSystemEntity> entities = await dir.list().toList();
      for (var entity in entities) {
        if (entity is File && entity.path.contains("daily_wallpaper_")) {
           await entity.delete();
        }
      }
    } catch (e) {
      debugPrint("Error cleaning old wallpapers: $e");
    }

    // Use unique timestamp to prevent caching issues
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('$path/daily_wallpaper_$timestamp.png');
    await file.writeAsBytes(buffer);

    return file;
  }
}
