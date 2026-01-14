import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/painters/dot_grid_painter.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final progress = viewModel.progress;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header (Month)
            const SizedBox(height: 60), // Top margin
            Text(
              progress.monthName,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            
            // Middle Grid (Takes available space)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: CustomPaint(
                  painter: DotGridPainter(progress: progress),
                  child: Container(), // needed for Expanded to fill width? actually CustomPaint expands if parent constraints invoke it.
                  // But usually CustomPaint needs a size. Expanded gives it.
                  // We'll trust the painter to use size.
                ),
              ),
            ),

            // Bottom Stats & Footer
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main Stats
                Text(
                  "${progress.dayOfYear} / ${progress.totalDays}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${progress.daysLeft} days left",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                
                const SizedBox(height: 40), 
                
                // Footer Action
                TextButton(
                  onPressed: () async {
                     final success = await viewModel.setWallpaper();
                     if (context.mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(success 
                             ? "Wallpaper set successfully!" 
                             : "Failed to set wallpaper."),
                           duration: const Duration(seconds: 1),
                         ),
                       );
                     }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Updates automatically daily",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Bottom margin
              ],
            ),
          ],
        ),
      ),
    );
  }
}
