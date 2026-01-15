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

    // 3. Draw Content (Grid + Text) with Layout Transforms
    canvas.save();
    
    // Apply Scale (Centered)
    canvas.translate(width / 2, height / 2);
    canvas.scale(theme.scale, theme.scale);
    canvas.translate(-width / 2, -height / 2);
    
    // Apply Y Offset
    // IMPORTANT: In Flutter Widget, offset is pixels. Here 1080px width vs phone screen width.
    // We should scale the offset if the theme.yOffset is in "screen pixels".
    // Preview uses logical pixels. Generator uses 1080px.
    // Ratio ~3.0 (approx 1080 / 360).
    // Let's assume a factor of 2.8 to 3.0.
    const double pixelRatio = 3.0; // Approximation for High Res
    canvas.translate(0, theme.yOffset * pixelRatio);

    // Grid Painting
    const double topMargin = 300; 
    const double bottomMargin = 500; 
    const double gridHeight = height - topMargin - bottomMargin;
    
    canvas.save();
    canvas.translate(0, topMargin);
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
  
      // Top Month
      drawTextCentered(
        progress.monthName, 
        200, 
        48, 
        theme.textSecondary.withOpacity(1.0), 
        FontWeight.w400,
        3.0
      );
  
      // Bottom Stats (Below grid)
      // Starts at height - bottomMargin
      // Moving it UP -> Smaller Y value.
      // Previously: height - 500 + 100 = height - 400.
      // Target: Move UP. New: height - 500 + 20 = height - 480.
      final statsStartY = height - bottomMargin + 20;

      // We need to simulate the Row logic manually on Canvas
      // "15 / 365" (Highlight)  + "350 days left" (Grey)
      
      final mainText = "${progress.dayOfYear} / ${progress.totalDays}";
      final subText = "   ${progress.daysLeft} left"; // Three spaces = wider gap
      
      // Calculate widths to center the whole block
      final mainStyle = TextStyle(
         color: theme.dotToday, // Highlight Color
         fontSize: 48, // Smaller (was 64)
         fontFamily: 'Roboto', // Ideally bundled font, fallback to Roboto
         fontWeight: FontWeight.w600,
      );
      final subStyle = TextStyle(
         color: theme.textSecondary.withOpacity(0.8),
         fontSize: 32, // Smaller
         fontFamily: 'Roboto', 
         fontWeight: FontWeight.w400,
      );
      
      final mainSpan = TextSpan(text: mainText, style: mainStyle);
      final subSpan = TextSpan(text: subText, style: subStyle);
      
      final mainPainter = TextPainter(text: mainSpan, textDirection: TextDirection.ltr)..layout();
      final subPainter = TextPainter(text: subSpan, textDirection: TextDirection.ltr)..layout();
      
      final totalWidth = mainPainter.width + subPainter.width;
      final startX = (width - totalWidth) / 2;
      
      // Draw Main Part
      mainPainter.paint(canvas, Offset(startX, statsStartY));
      
      // Draw Sub Part (aligned baselineish, let's just align bottoms or centers)
      // Align baselines roughly by font size difference
      final baselineDiff = mainStyle.fontSize! - subStyle.fontSize!;
      subPainter.paint(canvas, Offset(startX + mainPainter.width, statsStartY + (baselineDiff/2) + 4));
    }
    
    // Restore the Layout Transform (Scale/Offset)
    canvas.restore();

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
