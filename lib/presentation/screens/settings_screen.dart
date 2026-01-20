import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/data/services/background_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
          _buildDonateCard(),
          const SizedBox(height: 30),

          _buildSectionTitle("LIVE WALLPAPER"),
          const SizedBox(height: 10),
          _buildInfoCard(context),
          
          const SizedBox(height: 30),
          _buildSectionTitle("SUPPORT"),
          const SizedBox(height: 10),
          _buildSupportCard(context),

          const SizedBox(height: 30),
          _buildSectionTitle("TROUBLESHOOTING"),
          const SizedBox(height: 10),
          _buildTroubleshootingCard(context),

          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  "Made by Dhruwayush ⚡", // Updated footer
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6)
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "YearDots v1.8",
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDonateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.pink.shade400], // Cheerful gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                "Support Development",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "If you enjoy using YearDots, consider supporting its focused development! Your support keeps the dots moving.",
            style: GoogleFonts.inter(
              fontSize: 14, 
              height: 1.5, 
              color: Colors.white.withOpacity(0.9)
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _launchUrl('upi://pay?pa=paytmqr28100505010119630dcxadmy@paytm&pn=Paytm%20Merchant&mc=5499&mode=02&orgid=000000&paytmqr=28100505010119630DCXADMY&sign=MEUCIGxKP4ucXxOCaNOYr5HDimqzUxRF7N9W9DOEKvP3oop+AiEAgA85+WNYmc77eGWPn+J8j70KhpinRIgkX5YXOH43BI4=&tn=YearDots'), // Placeholder
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.pink.shade500,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism, size: 20),
                  SizedBox(width: 8),
                  Text("Support via UPI", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.lightbulb_outline,
            color: Colors.amber,
            title: "Request Feature",
            subtitle: "Have an idea? Let me know!",
            trailing: const Icon(Icons.arrow_outward, size: 16, color: Colors.white30),
            onTap: () => _launchUrl('https://yeardots.vercel.app/request.html'),
          ),
           const Divider(height: 1, color: Colors.white10, indent: 60, endIndent: 20),
          _buildActionRow(
            icon: Icons.bug_report_outlined,
            color: Colors.redAccent,
            title: "Report Bug",
            subtitle: "Something not working?",
            trailing: const Icon(Icons.arrow_outward, size: 16, color: Colors.white30),
            onTap: () => _launchUrl('https://yeardots.vercel.app/bug.html'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error quietly or show snackbar
      debugPrint('Could not launch $url');
    }
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
      borderRadius: BorderRadius.circular(24), // Match container radius for ink effect
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
