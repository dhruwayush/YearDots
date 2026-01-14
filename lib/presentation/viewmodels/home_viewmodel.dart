import 'package:flutter/foundation.dart';
import 'package:year_dots/domain/logic/date_logic.dart';
import 'package:year_dots/domain/models/year_progress.dart';
import 'package:year_dots/data/services/wallpaper_service.dart';

class HomeViewModel extends ChangeNotifier {
  late YearProgress _progress;

  YearProgress get progress => _progress;

  HomeViewModel() {
    _refreshData();
  }

  void _refreshData() {
    _progress = DateLogic.calculateProgress();
    notifyListeners();
  }
  
  void refresh() {
    _refreshData();
  }

  Future<bool> setWallpaper() async {
    final service = WallpaperService();
    // Re-calculate and set
    return await service.updateWallpaper();
  }
}
