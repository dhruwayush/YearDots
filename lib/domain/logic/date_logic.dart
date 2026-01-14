import 'package:year_dots/domain/models/year_progress.dart';

class DateLogic {
  static YearProgress calculateProgress() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final nextYear = DateTime(now.year + 1, 1, 1);
    
    // Calculate total days in this year (handling leap years)
    final totalDays = nextYear.difference(startOfYear).inDays;
    
    // Calculate day of year (1-based)
    final diff = now.difference(startOfYear);
    final dayOfYear = diff.inDays + 1;
    
    final daysLeft = totalDays - dayOfYear;
    final progressPercent = (dayOfYear / totalDays) * 100;
    
    // Get Month Name (e.g. JANUARY)
    const months = [
      "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
      "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"
    ];
    final monthName = months[now.month - 1];

    return YearProgress(
      dayOfYear: dayOfYear,
      totalDays: totalDays,
      daysLeft: daysLeft,
      progressPercent: progressPercent,
      monthName: monthName,
    );
  }
}
