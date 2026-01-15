import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';
import 'package:year_dots/data/services/background_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  DateTime _scheduledTime = DateTime.now();
  bool _batterySaver = false;
  bool _updateOnRestart = false;
  bool _isLoading = true;
  int _pickerKey = 0; // Key to force rebuild of picker

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _batterySaver = prefs.getBool('battery_saver') ?? false;
      _updateOnRestart = prefs.getBool('update_on_restart') ?? false;
      
      final hour = prefs.getInt('schedule_hour') ?? 8;
      final minute = prefs.getInt('schedule_minute') ?? 0;
      final now = DateTime.now();
      _scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('battery_saver', _batterySaver);
    await prefs.setBool('update_on_restart', _updateOnRestart);
    await prefs.setInt('schedule_hour', _scheduledTime.hour);
    await prefs.setInt('schedule_minute', _scheduledTime.minute);
    
    // Reschedule background task with new settings
    _rescheduleTask();
  }

  Future<void> _rescheduleTask() async {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, _scheduledTime.hour, _scheduledTime.minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final delay = target.difference(now);
    
    await BackgroundService.registerDailyTask(
      initialDelay: delay,
      requiresBatteryNotLow: _batterySaver,
    );
     if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Schedule updated for ${_scheduledTime.hour}:${_scheduledTime.minute.toString().padLeft(2, '0')}")));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: AppColors.backgroundDark, body: Center(child: CircularProgressIndicator()));

    final viewModel = Provider.of<HomeViewModel>(context);
    
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
          "Schedule & Power",
          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionTitle("SYNC SCHEDULE"),
          const SizedBox(height: 10),
          _buildScheduleCard(),
          
          const SizedBox(height: 30),
          _buildSectionTitle("BATTERY & PERFORMANCE"),
          const SizedBox(height: 10),
          _buildBatteryCard(),

          const SizedBox(height: 30),
          _buildOptimizationCard(),
          
          const SizedBox(height: 30),
          _buildSectionTitle("TROUBLESHOOTING"),
          const SizedBox(height: 10),
          _buildTroubleshootingCard(viewModel),

          const SizedBox(height: 40),
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

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Daily Update Time", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              GestureDetector(
                onTap: () {
                  setState(() {
                      _scheduledTime = DateTime(_scheduledTime.year, _scheduledTime.month, _scheduledTime.day, 0, 0); // Midnight
                      _pickerKey++;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reset to Default (Midnight)")));
                  _saveSettings();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text("AUTO", style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              child: CupertinoDatePicker(
                key: ValueKey(_pickerKey),
                mode: CupertinoDatePickerMode.time,
                initialDateTime: _scheduledTime,
                onDateTimeChanged: (val) {
                  _scheduledTime = val;
                },
                use24hFormat: false,
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 10),
          
           Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Updates will occur daily at ${_scheduledTime.hour}:${_scheduledTime.minute.toString().padLeft(2,'0')}",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBatteryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            icon: Icons.battery_saver,
            iconColor: Colors.greenAccent,
            title: "Battery Saver Friendly",
            subtitle: "Pause updates when Low Power Mode is on",
            value: _batterySaver,
            onChanged: (v) {
                setState(() => _batterySaver = v);
                _saveSettings();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
          _buildSwitchRow(
            icon: Icons.restart_alt,
            iconColor: Colors.blueAccent,
            title: "Update on Restart",
            subtitle: "Refresh wallpaper immediately after restart",
            value: _updateOnRestart,
            onChanged: (v) {
                setState(() => _updateOnRestart = v);
                _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11, height: 1.2)),
              ],
            ),
          ),
           Switch(
            value: value, 
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF131F2D),
            Colors.black.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text("SYSTEM OPTIMIZATION", style: GoogleFonts.spaceGrotesk(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Background Refresh ensures your Year Progress stays accurate without draining your battery. For 100% reliability, allow background activity in system settings.",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await openAppSettings();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Open Settings"),
            ),
          )
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _saveSettings();
    super.dispose();
  }

  Widget _buildTroubleshootingCard(HomeViewModel viewModel) {
     return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildActionRow(
            icon: Icons.wallpaper,
            color: Colors.purpleAccent,
            title: "Test Wallpaper Update",
            subtitle: "Trigger a manual refresh now",
            trailing: IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.white70),
              onPressed: () {
                 viewModel.setWallpaperNow();
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Test Update Triggered")));
              },
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Colors.white.withOpacity(0.05), height: 1)),
          _buildActionRow(
            icon: Icons.build,
            color: Colors.orangeAccent,
            title: "Reset WorkManager",
            subtitle: "Fix stuck background tasks",
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () async {
                 await BackgroundService.registerDailyTask(
                     // Reset to defaults
                 ); 
                 if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Background Task Re-registered")));
              },
            ),
          ),
           Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Divider(color: Colors.white.withOpacity(0.05), height: 1)),
           _buildActionRow(
            icon: Icons.battery_alert,
            color: Colors.redAccent,
            title: "Battery Optimization Guide",
            subtitle: "Disable strict restrictions for OEMs",
            trailing: const Icon(Icons.chevron_right, color: Colors.white30),
          ),
        ],
      ),
    );
  }
   Widget _buildActionRow({required IconData icon, required Color color, required String title, required String subtitle, required Widget trailing}) {
    return Padding(
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
    );
  }
}
