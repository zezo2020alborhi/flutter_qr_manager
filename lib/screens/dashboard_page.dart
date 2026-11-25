import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'qr_detail_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.onCreate, required this.onOpenCodes, super.key});
  final VoidCallback onCreate;
  final VoidCallback onOpenCodes;

  @override
  Widget build(BuildContext context) {
    final controller = QrManagerScope.codesOf(context);
    final overview = controller.overview;
    final codes = controller.codes.take(4).toList(growable: false);
    return RefreshIndicator(
      onRefresh: controller.reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('مدير الرموز', style: TextStyle(color: AppColors.ink, fontSize: 25, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text('محتوى كتابك، قابل للتحديث في أي وقت', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(.1), borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (controller.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: const Color(0xFFFFF4F2), borderRadius: BorderRadius.circular(12)),
              child: Row(children: <Widget>[const Icon(Icons.cloud_off_outlined, color: AppColors.danger), const SizedBox(width: 8), Expanded(child: Text(controller.error!, style: const TextStyle(color: AppColors.danger)))]),
            ),
          Row(
            children: <Widget>[
              Expanded(child: StatCard(label: 'إجمالي المسحات', value: NumberFormat.compact(locale: 'ar').format(overview?.totalScans ?? 0), icon: Icons.qr_code_scanner_rounded)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'مسحات اليوم', value: NumberFormat.decimalPattern('ar').format(overview?.todayScans ?? 0), icon: Icons.today_outlined, accent: AppColors.mint)),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(onPressed: onCreate, icon: const Icon(Icons.add_circle_outline_rounded), label: const Text('إنشاء رمز QR ديناميكي')),
          SectionHeader(title: 'أحدث الرموز', actionLabel: 'عرض الكل', onAction: onOpenCodes),
          if (controller.isLoading && codes.isEmpty)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
          else if (codes.isEmpty)
            const EmptyPanel(title: 'لا توجد رموز بعد', message: 'أنشئ أول رمز لربط درس أو نشاط بمحتوى قابل للتعديل.', icon: Icons.qr_code_2_rounded)
          else
            ...codes.map((QrCode code) => QrCodeTile(code: code, onTap: () => Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => QrDetailPage(code: code))))),
        ],
      ),
    );
  }
}
