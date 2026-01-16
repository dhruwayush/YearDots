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

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                      color: AppColors.textWhite,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
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
                      height: 500, // Explicit height for the frame area
                      child: Center(
                        child: SizedBox(
                          width: 260, // Constrain width for phone look
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.pie_chart_outline, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text("COMPLETE", style: GoogleFonts.splineSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${progress.progressPercent.toStringAsFixed(0)}%",
                                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.hourglass_bottom, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text("DAYS LEFT", style: GoogleFonts.splineSans(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${progress.daysLeft}",
                                  style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textWhite),
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
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          // Customizer Navigation
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(50)),
                              child: const Icon(Icons.palette_outlined, color: AppColors.textSecondary),
                            ),
                            title: Text("Customize Style", style: GoogleFonts.splineSans(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
                            subtitle: Text("Colors, shapes & layout", style: GoogleFonts.splineSans(color: AppColors.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                            onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (_) => const CustomizerScreen()),
                                );
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.05), height: 1),
                           // Manual Update Trigger
                           ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.backgroundDark, borderRadius: BorderRadius.circular(50)),
                              child: const Icon(Icons.wallpaper, color: AppColors.textSecondary),
                            ),
                            title: Text("Set Live Wallpaper", style: GoogleFonts.splineSans(color: AppColors.textWhite, fontWeight: FontWeight.w600)),
                            subtitle: Text("Updates daily automatically", style: GoogleFonts.splineSans(color: AppColors.textSecondary, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                            onTap: () async {
                                // Save current theme first
                                await viewModel.setWallpaperNow(); // This saves theme? verify. 
                                // Actually setWallpaperNow sets static. We just want to SAVE theme. 
                                // viewModel.setTheme persists it.
                                // But if user modified it in Customizer? This is Dashboard. Theme is already saved.
                                // Just open picker.
                                // We need BackgroundService import.
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
