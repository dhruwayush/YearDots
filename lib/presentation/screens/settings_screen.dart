import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/data/services/background_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Settings",
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle("LIVE WALLPAPER"),
          const SizedBox(height: 10),
          _buildInfoCard(context),
          
          const SizedBox(height: 30),
          _buildSectionTitle("TROUBLESHOOTING"),
          const SizedBox(height: 10),
          _buildTroubleshootingCard(context),

          const SizedBox(height: 40),
          Center(
            child: Text(
              "YearDots v1.8",
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wallpaper, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Native Live Wallpaper",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "YearDots uses a native Android Live Wallpaper to update your progress efficiently without background service limitations. Ensure it is set as your active wallpaper.",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await BackgroundService.openLiveWallpaperPicker();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Open Wallpaper Settings"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTroubleshootingCard(BuildContext context) {
     return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.refresh,
            color: Colors.orangeAccent,
            title: "Re-open Chooser",
            subtitle: "If wallpaper is stuck or not showing",
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
            onTap: () async {
                 await BackgroundService.openLiveWallpaperPicker();
            },
          ),
        ],
      ),
    );
  }

   Widget _buildActionRow({required IconData icon, required Color color, required String title, required String subtitle, required Widget trailing, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
             Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
