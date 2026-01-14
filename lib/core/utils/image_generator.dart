import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:year_dots/domain/models/year_progress.dart';
import 'package:year_dots/presentation/painters/dot_grid_painter.dart';

class ImageGenerator {
  static Future<File> generateWallpaperFile(YearProgress progress) async {
    // 1. Define image size (e.g., standard phone resolution or current screen size)
    // Ideally we get this from the device, but in background we might not have it context.
    // A safe high res vertical stricture is good. 1080x1920 is a safe bet for quality.
    const double width = 1080;
    const double height = 1920;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(width, height);

    // 2. Draw
    final painter = DotGridPainter(progress: progress);
    painter.paint(canvas, size);

    // 3. Convert to Image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());

    // 4. Encode to PNG
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // 5. Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/daily_wallpaper.png');
    await file.writeAsBytes(buffer);

    return file;
  }
}
