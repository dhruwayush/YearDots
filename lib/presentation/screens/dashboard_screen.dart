import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';
import 'package:year_dots/presentation/widgets/glass_card.dart';
import 'package:year_dots/presentation/widgets/phone_frame_preview.dart';
import 'package:year_dots/presentation/screens/customizer_screen.dart';
import 'package:year_dots/presentation/screens/settings_screen.dart';
import 'package:year_dots/data/services/background_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final progress = viewModel.yearProgress;
    final theme = viewModel.selectedTheme;
    final isDark = viewModel.isDarkMode;
    
    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textWhite : Colors.black87;
    final secondaryTextColor = isDark ? AppColors.textSecondary : Colors.black54;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "YearDots",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings_outlined, color: secondaryTextColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content Scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Phone Preview (Hero)
                    SizedBox(
                      height: 500,
                      child: Center(
                        child: SizedBox(
                          width: 260,
                          child: PhoneFramePreview(progress: progress, theme: theme),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pie_chart_outline, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text("COMPLETE", style: GoogleFonts.splineSans(color: secondaryTextColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${progress.progressPercent.toStringAsFixed(0)}%",
                                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.hourglass_bottom, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text("DAYS LEFT", style: GoogleFonts.splineSans(color: secondaryTextColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${progress.daysLeft}",
                                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Actions Card
                    GlassCard(
                      isDark: isDark,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          // Customizer Navigation
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.backgroundDark : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.palette_outlined, color: secondaryTextColor),
                            ),
                            title: Text("Customize Style", style: GoogleFonts.splineSans(color: textColor, fontWeight: FontWeight.w600)),
                            subtitle: Text("Colors, shapes & layout", style: GoogleFonts.splineSans(color: secondaryTextColor, fontSize: 12)),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16, color: secondaryTextColor),
                            onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const CustomizerScreen()),
                                );
                            },
                          ),
                          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05), height: 1),
                           // Manual Update Trigger
                           ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.backgroundDark : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.wallpaper, color: secondaryTextColor),
                            ),
                            title: Text("Set Live Wallpaper", style: GoogleFonts.splineSans(color: textColor, fontWeight: FontWeight.w600)),
                            subtitle: Text("Updates daily automatically", style: GoogleFonts.splineSans(color: secondaryTextColor, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                            onTap: () async {
                                await BackgroundService.openLiveWallpaperPicker();
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
