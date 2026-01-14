import 'package:flutter/material.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/domain/models/year_progress.dart';

class DotGridPainter extends CustomPainter {
  final YearProgress progress;

  DotGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    
    // Grid configuration
    const int cols = 15; // Width
    final int rows = (progress.totalDays / cols).ceil(); // Height based on total days
    
    // We base everything on width to keep dots round and spacing consistent
    
    // Reference image shows the grid is fairly compact horizontally
    final double horizontalPadding = size.width * 0.12; 
    final double availableWidth = size.width - (horizontalPadding * 2);

    // Initial calculation based on WIDTH
    double cellWidth = availableWidth / cols;
    double cellHeight = cellWidth * 1.15; 
    
    // Check if HEIGHT is the limiting factor
    final double requiredHeight = rows * cellHeight;
    if (requiredHeight > size.height) {
      // Height is too small! Scale down based on height.
      // We'll leave zero vertical padding in this extreme case, or a small margin.
      cellHeight = size.height / rows;
      cellWidth = cellHeight / 1.15; // Maintain aspect ratio
    }

    // Re-calculate centering offsets based on final cell sizes
    final double totalGridWidth = cols * cellWidth;
    final double totalGridHeight = rows * cellHeight;
    
    // Center horizontally and vertically in the available space
    final double startX = (size.width - totalGridWidth) / 2;
    final double startY = (size.height - totalGridHeight) / 2;

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
          dotPaint.color = AppColors.dotPassed;
        } else if (i == progress.dayOfYear) {
          dotPaint.color = AppColors.dotToday;
        } else {
          dotPaint.color = AppColors.dotFuture;
        }

        canvas.drawCircle(Offset(cx, cy), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
     return oldDelegate.progress.dayOfYear != progress.dayOfYear ||
            oldDelegate.progress.totalDays != progress.totalDays;
  }
}
