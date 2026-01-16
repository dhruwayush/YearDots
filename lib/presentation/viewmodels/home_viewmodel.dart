import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:year_dots/core/constants/app_colors.dart';
import 'package:year_dots/domain/logic/date_logic.dart';
import 'package:year_dots/domain/models/year_progress.dart';
import 'package:year_dots/data/services/wallpaper_service.dart';

class HomeViewModel extends ChangeNotifier {
  late YearProgress _yearProgress;
  AppTheme _selectedTheme = AppTheme.defaults;

  YearProgress get yearProgress => _yearProgress;
  AppTheme get selectedTheme => _selectedTheme;

  HomeViewModel() {
    _refreshData();
    _loadTheme();
  }

  void _refreshData() {
    _yearProgress = DateLogic.calculateProgress();
    notifyListeners();
  }
  
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString('theme_id') ?? 'default';

    if (themeId.startsWith('custom_')) {
        // Reconstruct custom theme
        final colorValue = prefs.getInt('theme_color') ?? AppColors.primary.value;
        final styleIndex = prefs.getInt('theme_style') ?? 0;
        final textColorValue = prefs.getInt('theme_text_color');
        final bgColorValue = prefs.getInt('theme_background'); // New
        final showText = prefs.getBool('theme_show_text') ?? true;
        final gridColumns = prefs.getInt('theme_grid_columns') ?? 15;
        
        final base = AppTheme.defaults;
        
        Color textPrimary = base.textPrimary;
        Color textSecondary = base.textSecondary;
        if (textColorValue != null) {
            final col = Color(textColorValue);
            textPrimary = col;
            textSecondary = col.withOpacity(0.6);
        }

        _selectedTheme = AppTheme(
           id: themeId,
           name: 'Custom',
           background: bgColorValue != null ? Color(bgColorValue) : base.background, // Use loaded bg
           surface: base.surface,
           dotPassed: base.dotPassed,
           dotToday: Color(colorValue),
           dotFuture: base.dotFuture,
           textPrimary: textPrimary,
           textSecondary: textSecondary,
           dotStyle: DotStyle.values[styleIndex],
           showText: showText,
           gridColumns: gridColumns,
        );
    } else {
        _selectedTheme = AppTheme.fromId(themeId);
    }
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _selectedTheme = theme;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_id', theme.id);
    
    // Save custom properties if it's a custom theme
    if (theme.id.startsWith('custom_')) {
        await prefs.setInt('theme_color', theme.dotToday.value);
        await prefs.setInt('theme_style', theme.dotStyle.index);
        await prefs.setInt('theme_text_color', theme.textPrimary.value);
        await prefs.setInt('theme_background', theme.background.value); // New
        await prefs.setBool('theme_show_text', theme.showText);
        await prefs.setInt('theme_grid_columns', theme.gridColumns);
    }
  }
  
  void refresh() {
    _refreshData();
  }

  Future<bool> setWallpaperNow() async {
    final service = WallpaperService();
    return await service.updateWallpaper(theme: _selectedTheme);
  }
}
