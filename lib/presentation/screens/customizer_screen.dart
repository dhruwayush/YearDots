import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';
import 'package:year_dots/presentation/widgets/phone_frame_preview.dart';

class CustomizerScreen extends StatelessWidget {
  const CustomizerScreen({super.key});

  // Curated Palette for Dark Mode
  static const List<Color> _colorPalette = [
    // Essentials
    Colors.white,
    AppColors.primary, // Cyan
    Color(0xFFFFD740), // Amber Accent
    
    // Vibrant
    Color(0xFFFF4081), // Pink Accent
    Color(0xFF00E676), // Green Accent
    Color(0xFF76FF03), // Light Green (Acid)
    Color(0xFFD500F9), // Purple Accent
    Color(0xFFFF6D00), // Deep Orange
    
    // Pastel / Soft
    Color(0xFF80DEEA), // Cyan 200
    Color(0xFFFFAB91), // Deep Orange 200 (Peach)
    Color(0xFFF48FB1), // Pink 200
    Color(0xFFCE93D8), // Purple 200
    
    // Cool / Deep
    Color(0xFF2979FF), // Blue Accent
    Color(0xFF3D5AFE), // Indigo Accent
    Color(0xFF607D8B), // Blue Grey
  ];

  static const List<Color> _backgroundPalette = [
    AppColors.backgroundDark, // Default
    Colors.black,
    Color(0xFF1A237E), // Deep Indigo
    Color(0xFF000051), // Navy
    Color(0xFF1B5E20), // Dark Green
    Color(0xFF263238), // Blue Grey Dark
    Color(0xFF3E2723), // Dark Brown
    Color(0xFF212121), // Grey 900
    Color(0xFF311B92), // Deep Purple
    Color(0xFF0D47A1), // Deep Blue
    Color(0xFFB71C1C), // Red darken
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final theme = viewModel.selectedTheme;
    final progress = viewModel.yearProgress;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text("Customize Wallpaper", style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                         // Reset logic if needed, or just set default
                         viewModel.setTheme(AppTheme.defaults);
                    },
                    child: const Text("Reset", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            // Preview Area (Top Half)
            Expanded(
              flex: 5,
              child: Center(
                child: SizedBox(
                   width: 240, 
                   child: PhoneFramePreview(progress: progress, theme: theme)
                ),
              ),
            ),

            // Controls Area (Bottom Half)
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  // Removed explicit top border to avoid conflict with borderRadius. 
                  // Visual separation handled by color difference or shadow if needed.
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -4))
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Drag Handle
                    Container(width: 48, height: 6, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(3))),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Section: Dot Style
                          _buildSectionHeader("Dot Style"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStyleOption(
                                "Round", 
                                Icons.circle, 
                                theme.dotStyle == DotStyle.round,
                                () => _updateThemeStyle(viewModel, DotStyle.round),
                              ),
                              const SizedBox(width: 16),
                              _buildStyleOption(
                                "Square", 
                                Icons.square_rounded, 
                                theme.dotStyle == DotStyle.square,
                                () => _updateThemeStyle(viewModel, DotStyle.square),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          const SizedBox(height: 32),
                          // Section: Highlight Color (Dot)
                          _buildSectionHeader("Highlight Color"),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _colorPalette.length,
                              itemBuilder: (context, index) {
                                return _buildColorOption(viewModel, _colorPalette[index], isText: false);
                              },
                            ),
                          ),

                          const SizedBox(height: 32),
                          // Section: Background Color
                          _buildSectionHeader("Background Color"),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _backgroundPalette.length,
                              itemBuilder: (context, index) {
                                return _buildColorOption(viewModel, _backgroundPalette[index], isText: false, isBackground: true);
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 32),

                          // Section: Layout Adjustments (Scale & Position)
                          _buildSectionHeader("Layout Adjustments"),
                          const SizedBox(height: 16),
                          
                          // Scale Slider
                          Row(
                            children: [
                                const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text("Scale: ${(theme.scale * 100).toInt()}%", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                            Slider(
                                                value: theme.scale,
                                                min: 0.5,
                                                max: 1.5,
                                                divisions: 20,
                                                activeColor: AppColors.primary,
                                                inactiveColor: Colors.white10,
                                                onChanged: (val) {
                                                    _updateThemeLayout(viewModel, scale: val);
                                                },
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                          ),
                          
                          // Position Slider
                          Row(
                            children: [
                                const Icon(Icons.unfold_more, color: Colors.white70, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            Text("Position Y: ${theme.yOffset.toInt()}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                            Slider(
                                                value: theme.yOffset,
                                                min: -400,
                                                max: 400,
                                                divisions: 40,
                                                activeColor: AppColors.primary,
                                                inactiveColor: Colors.white10,
                                                onChanged: (val) {
                                                    _updateThemeLayout(viewModel, yOffset: val);
                                                },
                                            ),
                                        ],
                                    ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 32),
                          // Section: Text Visibility & Color
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               _buildSectionHeader("Text Details"),
                               Switch(
                                 value: theme.showText,
                                 activeColor: AppColors.primary,
                                 onChanged: (val) {
                                   _updateThemeTextVisibility(viewModel, val);
                                 },
                               )
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          if (theme.showText) ...[
                            SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _colorPalette.length,
                                itemBuilder: (context, index) {
                                  return _buildColorOption(viewModel, _colorPalette[index], isText: true);
                                },
                              ),
                            ),
                          ] else 
                             const Text("Text overlay hidden on wallpaper.", style: TextStyle(color: Colors.white24, fontSize: 12)),
                          
                          const SizedBox(height: 80), // Specs
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Apply Button Floating
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width - 48,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: ElevatedButton(
          onPressed: () {
            viewModel.setWallpaperNow();
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wallpaper Updated!")));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surfaceDarker,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Apply to Lock Screen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.wallpaper)
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white70),
    );
  }

  Widget _buildStyleOption(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : AppColors.surfaceDarker,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : Colors.white24),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(HomeViewModel viewModel, Color color, {required bool isText, bool isBackground = false}) {
    Color currentVal;
    if (isBackground) {
        currentVal = viewModel.selectedTheme.background;
    } else if (isText) {
        currentVal = viewModel.selectedTheme.textPrimary;
    } else {
        currentVal = viewModel.selectedTheme.dotToday;
    }
    
    final isSelected = currentVal.value == color.value;
    
    return GestureDetector(
      onTap: () {
        if (isBackground) {
             _updateThemeBackgroundColor(viewModel, color);
        } else if (isText) {
          _updateThemeTextColor(viewModel, color);
        } else {
          _updateThemeColor(viewModel, color);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : Border.all(color: Colors.white10),
          boxShadow: [if (isSelected) BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)],
        ),
        child: isSelected ? Icon(Icons.check, color: color.computeLuminance() > 0.5 ? Colors.black54 : Colors.white) : null,
      ),
    );
  }

  void _updateThemeStyle(HomeViewModel vm, DotStyle style) {
     final current = vm.selectedTheme;
     final newTheme = _createNewTheme(current, style: style);
     vm.setTheme(newTheme);
  }

  void _updateThemeColor(HomeViewModel vm, Color color) {
     final current = vm.selectedTheme;
     final newTheme = _createNewTheme(current, dotToday: color);
     vm.setTheme(newTheme);
  }

  void _updateThemeTextColor(HomeViewModel vm, Color color) {
     final current = vm.selectedTheme;
     // When updating text color, we update Primary and derived Secondary
     final newTheme = _createNewTheme(current, textPrimary: color, textSecondary: color.withOpacity(0.6));
     vm.setTheme(newTheme);
  }

  void _updateThemeBackgroundColor(HomeViewModel vm, Color color) {
     final current = vm.selectedTheme;
     final newTheme = _createNewTheme(current, background: color);
     vm.setTheme(newTheme);
  }
  
  void _updateThemeTextVisibility(HomeViewModel vm, bool visible) {
      final current = vm.selectedTheme;
      final newTheme = _createNewTheme(current, showText: visible);
      vm.setTheme(newTheme);
  }

  void _updateThemeLayout(HomeViewModel vm, {double? scale, double? yOffset}) {
     final current = vm.selectedTheme;
     final newTheme = _createNewTheme(current, scale: scale, yOffset: yOffset);
     vm.setTheme(newTheme);
  }

  AppTheme _createNewTheme(AppTheme current, {DotStyle? style, Color? dotToday, Color? textPrimary, Color? textSecondary, bool? showText, Color? background, double? scale, double? yOffset}) {
     return AppTheme(
       id: 'custom_${DateTime.now().millisecondsSinceEpoch}', 
       name: 'Custom',
       background: background ?? current.background,
       surface: current.surface,
       dotPassed: current.dotPassed,
       dotToday: dotToday ?? current.dotToday,
       dotFuture: current.dotFuture,
       textPrimary: textPrimary ?? current.textPrimary,
       textSecondary: textSecondary ?? current.textSecondary,
       dotStyle: style ?? current.dotStyle,
       showText: showText ?? current.showText,
       scale: scale ?? current.scale,
       yOffset: yOffset ?? current.yOffset,
     );
  }
}
