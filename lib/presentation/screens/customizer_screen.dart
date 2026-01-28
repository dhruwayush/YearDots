import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/presentation/viewmodels/home_viewmodel.dart';
import 'package:year_dots/presentation/widgets/phone_frame_preview.dart';
import 'package:year_dots/data/services/background_service.dart';

class CustomizerScreen extends StatelessWidget {
  const CustomizerScreen({super.key});

  // Curated Palette for Dark Mode
  static const List<Color> _colorPalette = [
    Colors.white,
    AppColors.primary,
    Color(0xFFFFD740),
    Color(0xFFFF4081),
    Color(0xFF00E676),
    Color(0xFF76FF03),
    Color(0xFFD500F9),
    Color(0xFFFF6D00),
    Color(0xFF80DEEA),
    Color(0xFFFFAB91),
    Color(0xFFF48FB1),
    Color(0xFFCE93D8),
    Color(0xFF2979FF),
    Color(0xFF3D5AFE),
    Color(0xFF607D8B),
  ];

  static const List<Color> _backgroundPalette = [
    AppColors.backgroundDark,
    Colors.black,
    Color(0xFF1A237E),
    Color(0xFF000051),
    Color(0xFF1B5E20),
    Color(0xFF263238),
    Color(0xFF3E2723),
    Color(0xFF212121),
    Color(0xFF311B92),
    Color(0xFF0D47A1),
    Color(0xFFB71C1C),
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final theme = viewModel.selectedTheme;
    final progress = viewModel.yearProgress;
    final isDark = viewModel.isDarkMode;
    
    // Theme-aware colors
    final backgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textWhite : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surfaceDarkerColor = isDark ? AppColors.surfaceDarker : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text("Customize Wallpaper", style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
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
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, -4))
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Drag Handle
                    Container(width: 48, height: 6, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(3))),
                    
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          // Section: Dot Style
                          _buildSectionHeader("Dot Style", secondaryTextColor),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStyleOption(
                                "Round", 
                                Icons.circle, 
                                theme.dotStyle == DotStyle.round,
                                () => _updateThemeStyle(viewModel, DotStyle.round),
                                isDark,
                                textColor,
                                surfaceDarkerColor,
                              ),
                              const SizedBox(width: 16),
                              _buildStyleOption(
                                "Square", 
                                Icons.square_rounded, 
                                theme.dotStyle == DotStyle.square,
                                () => _updateThemeStyle(viewModel, DotStyle.square),
                                isDark,
                                textColor,
                                surfaceDarkerColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          const SizedBox(height: 32),
                          // Section: Highlight Color (Dot)
                          _buildSectionHeader("Highlight Color", secondaryTextColor),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _colorPalette.length,
                              itemBuilder: (context, index) {
                                return _buildColorOption(viewModel, _colorPalette[index], isText: false, isDark: isDark);
                              },
                            ),
                          ),

                          const SizedBox(height: 32),
                          // Section: Background Color
                          _buildSectionHeader("Background Color", secondaryTextColor),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 60,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _backgroundPalette.length,
                              itemBuilder: (context, index) {
                                return _buildColorOption(viewModel, _backgroundPalette[index], isText: false, isBackground: true, isDark: isDark);
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 32),

                          // Section: Grid Density
                          _buildSectionHeader("Grid Density", secondaryTextColor),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStyleOption(
                                "Large", 
                                Icons.grid_view, 
                                theme.gridColumns == 12,
                                () => _updateThemeGrid(viewModel, 12),
                                isDark,
                                textColor,
                                surfaceDarkerColor,
                              ),
                              const SizedBox(width: 12),
                              _buildStyleOption(
                                "Standard", 
                                Icons.grid_on, 
                                theme.gridColumns == 15,
                                () => _updateThemeGrid(viewModel, 15),
                                isDark,
                                textColor,
                                surfaceDarkerColor,
                              ),
                              const SizedBox(width: 12),
                              _buildStyleOption(
                                "Compact", 
                                Icons.apps, 
                                theme.gridColumns == 19,
                                () => _updateThemeGrid(viewModel, 19),
                                isDark,
                                textColor,
                                surfaceDarkerColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),
                          // Section: Text Visibility & Color
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                               _buildSectionHeader("Text Details", secondaryTextColor),
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
                                  return _buildColorOption(viewModel, _colorPalette[index], isText: true, isDark: isDark);
                                },
                              ),
                            ),
                          ] else 
                             Text("Text overlay hidden on wallpaper.", style: TextStyle(color: secondaryTextColor.withValues(alpha: 0.5), fontSize: 12)),
                          
                          const SizedBox(height: 80),
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
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: ElevatedButton(
          onPressed: () async {
             await BackgroundService.openLiveWallpaperPicker();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surfaceDarker,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Set Live Wallpaper", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.wallpaper)
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: textColor),
    );
  }

  Widget _buildStyleOption(String label, IconData icon, bool isSelected, VoidCallback onTap, bool isDark, Color textColor, Color surfaceDarkerColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
                : surfaceDarkerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primary : (isDark ? Colors.white10 : Colors.black12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : (isDark ? Colors.white24 : Colors.black26)),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? textColor : (isDark ? Colors.white60 : Colors.black54), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(HomeViewModel viewModel, Color color, {required bool isText, bool isBackground = false, required bool isDark}) {
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
          border: isSelected 
              ? Border.all(color: isDark ? Colors.white : Colors.black, width: 3) 
              : Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [if (isSelected) BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)],
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
     final newTheme = _createNewTheme(current, textPrimary: color, textSecondary: color.withValues(alpha: 0.6));
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

  void _updateThemeGrid(HomeViewModel vm, int columns) {
     final current = vm.selectedTheme;
     final newTheme = _createNewTheme(current, gridColumns: columns);
     vm.setTheme(newTheme);
  }

  AppTheme _createNewTheme(AppTheme current, {DotStyle? style, Color? dotToday, Color? textPrimary, Color? textSecondary, bool? showText, Color? background, int? gridColumns}) {
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
       gridColumns: gridColumns ?? current.gridColumns,
     );
  }
}
