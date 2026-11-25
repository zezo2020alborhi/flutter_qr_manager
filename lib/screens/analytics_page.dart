import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/analytics.dart';
import '../models/qr_code.dart';
import '../models/scan_event.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = QrManagerScope.codesOf(context);
    final AnalyticsOverview? overview = controller.overview;
    final points = overview?.lastSevenDays ?? <DailyScan>[];
    final max = points.isEmpty ? 1 : points.map((point) => point.count).reduce((a, b) => a > b ? a : b);
    final topCodes = <QrCode>[...controller.codes]..sort((a, b) => b.scanCount.compareTo(a.scanCount));
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصاءات')),
      body: RefreshIndicator(
        onRefresh: controller.reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(child: StatCard(label: 'رموز نشطة', value: '${overview?.activeCodes ?? 0}', icon: Icons.verified_outlined, accent: AppColors.mint)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'إجمالي المسحات', value: NumberFormat.compact(locale: 'ar').format(overview?.totalScans ?? 0), icon: Icons.insights_rounded)),
            ]),
            const SectionHeader(title: 'المسحات خلال 7 أيام'),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                child: SizedBox(
                  height: 184,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: points.map((point) {
                      final ratio = point.count / max;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text('${point.count}', style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              const SizedBox(height: 5),
                              Container(height: 112 * ratio, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6))),
                              const SizedBox(height: 8),
                              Text(DateFormat('E', 'ar').format(point.day), style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                            ],
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ),
              ),
            ),
            const SectionHeader(title: 'الرموز الأعلى مسحًا'),
            ...topCodes.take(5).map((code) => QrCodeTile(code: code, onTap: () {})),
            const SectionHeader(title: 'أحدث عمليات المسح'),
            if (controller.recentScans.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('لا توجد عمليات مسح مسجلة حتى الآن.', textAlign: TextAlign.center)))
            else
              Card(
                child: Column(
                  children: controller.recentScans.map((ScanEvent scan) => ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFEAF0FF), child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 19)),
                    title: Text(scan.qrTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${scan.deviceType ?? 'جهاز غير معروف'}${scan.countryCode == null ? '' : ' · ${scan.countryCode}'}'),
                    trailing: Text(DateFormat('HH:mm', 'ar').format(scan.scannedAt), style: const TextStyle(color: AppColors.muted)),
                  )).toList(growable: false),
                ),
              ),
            const SizedBox(height: 8),
            const Text('يُظهر الخادم بيانات الموقع بصورة تقريبية فقط عند توفرها، ولا يخزن عنوان IP الخام.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
