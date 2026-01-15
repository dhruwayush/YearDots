import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/domain/models/year_progress.dart';
import 'package:year_dots/presentation/painters/dot_grid_painter.dart';

class PhoneFramePreview extends StatelessWidget {
  final YearProgress progress;
  final AppTheme theme;

  const PhoneFramePreview({
    super.key,
    required this.progress,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // DEBUG PRINT
    debugPrint("PhoneFramePreview Check: showText=${theme.showText}, color=${theme.textPrimary}");
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // ... (existing code, keeping width/height calc)
        final double width = constraints.maxWidth;
        final double height = width * (19.5 / 9);

        return Container(
          // ... (existing decoration)
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceDarker,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.surfaceDark, width: 8),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(color: theme.background),
                
                // Content Layer (Transformed)
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, theme.yOffset), // Apply Y Position
                    child: Transform.scale(
                      scale: theme.scale, // Apply Scale
                      child: Stack(
                        children: [
                            // 2. The Dot Grid (Centered) with Margins for Text
                            Positioned.fill(
                              child: Padding(
                                // Reduced margins to allow dots to be larger
                                padding: EdgeInsets.only(
                                  top: height * 0.11, // Moved UP (was 0.13)
                                  bottom: height * 0.22, 
                                  left: 16, 
                                  right: 16
                                ),
                                child: CustomPaint(
                                  painter: DotGridPainter(progress: progress, theme: theme),
                                ),
                              ),
                            ),
                            
                            if (theme.showText) ...[
                               // Top Month
                               Positioned(
                                 top: height * 0.07, 
                                 left: 10, 
                                 right: 10,
                                 child: Text(
                                   progress.monthName,
                                   textAlign: TextAlign.center,
                                   style: GoogleFonts.roboto(
                                     color: theme.textSecondary.withOpacity(1.0), 
                                     fontSize: width * 0.05, 
                                     fontWeight: FontWeight.w400,
                                     letterSpacing: 3.0, 
                                   ),
                                 ),
                               ),

                               // Bottom Stats
                               Positioned(
                                 bottom: height * 0.14, // Moved UP (was 0.12)
                                 left: 10, 
                                 right: 10,
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   crossAxisAlignment: CrossAxisAlignment.baseline,
                                   textBaseline: TextBaseline.alphabetic,
                                   children: [
                                     Text(
                                       "${progress.dayOfYear} / ${progress.totalDays}",
                                       style: GoogleFonts.outfit( 
                                         color: theme.dotToday, 
                                         fontSize: width * 0.05, 
                                         fontWeight: FontWeight.w600,
                                       ),
                                     ),
                                     SizedBox(width: 16), // Increased spacing (was 8)
                                     Text(
                                       "${progress.daysLeft} left", 
                                       style: GoogleFonts.roboto(
                                         color: theme.textSecondary.withOpacity(0.8),
                                         fontSize: width * 0.035, 
                                         fontWeight: FontWeight.w400,
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                            ],
                        ],
                      ),
                    ),
                  ),
                ),
                
                // ... (Status Bar and others)
                Positioned(
                  top: 12, left: 24,
                  child: Text("9:41", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: width * 0.4, height: 24,
                    decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.vertical(bottom: Radius.circular(16))),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight, end: Alignment.bottomLeft,
                        colors: [Colors.white.withOpacity(0.05), Colors.transparent, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
