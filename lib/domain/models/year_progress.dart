class YearProgress {
  final int dayOfYear;
  final int totalDays;
  final int daysLeft;
  final double progressPercent;
  final String monthName;

  YearProgress({
    required this.dayOfYear,
    required this.totalDays,
    required this.daysLeft,
    required this.progressPercent,
    required this.monthName,
  });

  @override
  String toString() {
    return 'YearProgress(day: $dayOfYear, total: $totalDays, left: $daysLeft, month: $monthName)';
  }
}
