import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart' hide QrCode;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'create_edit_code_page.dart';

class QrDetailPage extends StatefulWidget {
  const QrDetailPage({required this.code, super.key});
  final QrCode code;

  @override
  State<QrDetailPage> createState() => _QrDetailPageState();
}

class _QrDetailPageState extends State<QrDetailPage> {
  late QrCode _code;
  bool _changingStatus = false;

  @override
  void initState() {
    super.initState();
    _code = widget.code;
  }

  Future<void> _editTarget() async {
    final updated = await Navigator.of(context).push<QrCode>(MaterialPageRoute<QrCode>(builder: (_) => CreateEditCodePage(existing: _code)));
    if (updated != null && mounted) setState(() => _code = updated);
  }

  Future<void> _toggleActive() async {
    setState(() => _changingStatus = true);
    try {
      final updated = await QrManagerScope.codesOf(context).setActive(_code.id, !_code.isActive);
      if (mounted) setState(() => _code = updated);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تغيير حالة الرمز.')));
    } finally {
      if (mounted) setState(() => _changingStatus = false);
    }
  }

  Future<void> _openContent() async {
    if (!_code.target.isExternalUrl) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: SingleChildScrollView(child: Text(_code.target.value, style: const TextStyle(fontSize: 16, height: 1.8))),
        ),
      );
      return;
    }
    final url = Uri.tryParse(_code.target.value);
    if (url == null || !await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح المحتوى. تحقق من الرابط وإعدادات المشاركة.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = QrManagerScope.codesOf(context);
    final publicUrl = controller.publicUrlFor(_code);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الرمز'),
        actions: <Widget>[
          IconButton(onPressed: _editTarget, icon: const Icon(Icons.edit_outlined), tooltip: 'تعديل المحتوى'),
          IconButton(onPressed: () => Share.share('امسح الرمز أو افتح الرابط: $publicUrl', subject: _code.title), icon: const Icon(Icons.share_outlined), tooltip: 'مشاركة'),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  QrImageView(data: publicUrl, version: QrVersions.auto, size: 194, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.ink), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.ink)),
                  const SizedBox(height: 16),
                  Text(_code.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.ink)),
                  const SizedBox(height: 6),
                  Text('${_code.bookName} · ${_code.chapterName}', style: const TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 13),
                  ContentTypeBadge(type: _code.target.type),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'الرابط الثابت للرمز'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.link_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(child: SelectableText(publicUrl, style: const TextStyle(color: AppColors.ink, fontSize: 12))),
                ],
              ),
            ),
          ),
          const SectionHeader(title: 'المحتوى الحالي'),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(backgroundColor: Color(0xFFEAF0FF), child: Icon(Icons.auto_stories_outlined, color: AppColors.primary)),
              title: Text(_code.target.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(_code.target.description ?? _code.target.type.name),
              trailing: const Icon(Icons.open_in_new_rounded),
              onTap: _openContent,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _editTarget, icon: const Icon(Icons.swap_horiz_rounded), label: const Text('تغيير المحتوى مع إبقاء الرمز نفسه')),
          const SectionHeader(title: 'ملخص المسح'),
          Row(children: <Widget>[
            Expanded(child: StatCard(label: 'إجمالي المسحات', value: NumberFormat.decimalPattern('ar').format(_code.scanCount), icon: Icons.qr_code_scanner_rounded)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: 'آخر مسح', value: _code.lastScanAt == null ? '—' : DateFormat('d MMM', 'ar').format(_code.lastScanAt!), icon: Icons.access_time_rounded, accent: AppColors.mint)),
          ]),
          const SectionHeader(title: 'حالة الرمز'),
          Card(
            child: SwitchListTile.adaptive(
              value: _code.isActive,
              onChanged: _changingStatus ? null : (_) => _toggleActive(),
              title: Text(_code.isActive ? 'الرمز نشط' : 'الرمز متوقف', style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(_code.isActive ? 'يفتح المحتوى ويسجل المسحات.' : 'يظهر للطالب أن المحتوى غير متاح مؤقتًا.'),
              secondary: Icon(_code.isActive ? Icons.verified_rounded : Icons.pause_circle_outline_rounded, color: _code.isActive ? AppColors.mint : AppColors.danger),
            ),
          ),
          const SizedBox(height: 12),
          const Text('ملاحظة: تنزيل صورة QR عالية الدقة يمكن إضافته إلى APK عند ربط حزمة التخزين والمشاركة. الرابط المطبوع أعلاه لا يتغير عند تعديل المحتوى.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, height: 1.5, fontSize: 12)),
        ],
      ),
    );
  }
}

