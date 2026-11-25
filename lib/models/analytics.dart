class AnalyticsOverview {
  const AnalyticsOverview({
    required this.totalScans,
    required this.todayScans,
    required this.activeCodes,
    required this.lastSevenDays,
  });

  final int totalScans;
  final int todayScans;
  final int activeCodes;
  final List<DailyScan> lastSevenDays;

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) => AnalyticsOverview(
        totalScans: json['totalScans'] as int? ?? 0,
        todayScans: json['todayScans'] as int? ?? 0,
        activeCodes: json['activeCodes'] as int? ?? 0,
        lastSevenDays: (json['lastSevenDays'] as List<dynamic>? ?? <dynamic>[])
            .map((item) => DailyScan.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

class DailyScan {
  const DailyScan({required this.day, required this.count});

  final DateTime day;
  final int count;

  factory DailyScan.fromJson(Map<String, dynamic> json) => DailyScan(
        day: DateTime.parse(json['day'] as String),
        count: json['count'] as int? ?? 0,
      );
}
