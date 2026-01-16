import 'package:flutter/material.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/domain/models/year_progress.dart';

class DotGridPainter extends CustomPainter {
  final YearProgress progress;
  final AppTheme theme;

  DotGridPainter({required this.progress, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    // Background is handled by parent/generator usually
    // But for safety in UI we can keep it?  No, let's make it transparent or optional.
    // Actually, if we paint it here, it will overwrite the ImageGenerator's black bg if we pass a smaller size?
    // In ImageGenerator we pass a smaller size/clip. 
    // If we paint bg here, we paint a black box in the middle of the screen. That's fine if it matches.
    // But let's verify.
    // simpler: just don't paint bg here if we want to be pure.
    // BUT the UI HomeScreen relies on this painter too? 
    // HomeScreen wraps it in Scaffold which has bg color.
    // So we can remove bg paint here safely.
    
    // final bgPaint = Paint()..color = AppColors.background;
    // canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    
    // Grid configuration
    final int cols = theme.gridColumns;
    // Calculate rows based on total days
    final int rows = (progress.totalDays / cols).ceil();
    
    // Define Grid Constraints
    // We want the grid to take up at most ~80% of the width
    final double maxWidth = size.width * 0.80;
    
    // Calculate cell size based on width constraint first
    double cellWidth = maxWidth / cols;
    double cellHeight = cellWidth * 1.15; // Aspect ratio
    
    // Check if this height fits in the available vertical space
    // If not, scale down keeping aspect ratio
    if ((rows * cellHeight) > size.height) {
      cellHeight = size.height / rows;
      cellWidth = cellHeight / 1.15;
    }
    
    // Calculate actual dimensions of the resulting grid
    final double actualGridWidth = cols * cellWidth;
    final double actualGridHeight = rows * cellHeight;
    
    // Calculate Centering Offsets
    final double startX = (size.width - actualGridWidth) / 2;
    final double startY = (size.height - actualGridHeight) / 2;

    // Radius of the dot
    final double dotRadius = cellWidth * 0.35; // slightly fuller dots matches reference

    for (int i = 1; i <= progress.totalDays; i++) {
        // 0-indexed position
        final int index = i - 1;
        final int col = index % cols;
        final int row = index ~/ cols;

        final double cx = startX + (col * cellWidth) + (cellWidth / 2);
        final double cy = startY + (row * cellHeight) + (cellHeight / 2);

        if (i < progress.dayOfYear) {
          dotPaint.color = theme.dotPassed;
        } else if (i == progress.dayOfYear) {
          dotPaint.color = theme.dotToday;
        } else {
          dotPaint.color = theme.dotFuture;
        }

        if (theme.dotStyle == DotStyle.round) {
          canvas.drawCircle(Offset(cx, cy), dotRadius, dotPaint);
        } else {
          // Square with slight rounding for specialized style
          final double size = dotRadius * 2;
          final rect = Rect.fromCenter(center: Offset(cx, cy), width: size, height: size);
          // Small corner radius for "squircle" look
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(size * 0.2)), dotPaint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
     return oldDelegate.progress.dayOfYear != progress.dayOfYear ||
            oldDelegate.progress.totalDays != progress.totalDays ||
            oldDelegate.theme.id != theme.id;
  }
}
