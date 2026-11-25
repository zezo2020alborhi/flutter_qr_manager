import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/app_settings.dart';
import '../theme/app_theme.dart';
import 'content_library_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apiController;
  late final TextEditingController _publicController;
  late final TextEditingController _adminKeyController;
  late bool _demo;
  bool _saving = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final settings = QrManagerScope.settingsOf(context).value;
    _apiController = TextEditingController(text: settings.apiBaseUrl);
    _publicController = TextEditingController(text: settings.publicBaseUrl);
    _adminKeyController = TextEditingController(text: settings.adminApiKey);
    _demo = settings.useDemoData;
  }

  @override
  void dispose() {
    _apiController.dispose();
    _publicController.dispose();
    _adminKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final settings = AppSettings(
      apiBaseUrl: _apiController.text.trim(),
      publicBaseUrl: _publicController.text.trim(),
      useDemoData: _demo,
      adminApiKey: _adminKeyController.text.trim(),
    );
    await QrManagerScope.settingsOf(context).update(settings);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات وتحديث مصدر البيانات.')));
  }

  Future<void> _connectGoogleDrive() async {
    if (_demo) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أوقف وضع العرض التجريبي واحفظ عنوان API أولًا.')));
      return;
    }
    try {
      final url = await QrManagerScope.codesOf(context).googleDriveAuthorizationUri();
      if (!await launchUrl(url, mode: LaunchMode.externalApplication) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح صفحة ربط Google Drive.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر بدء ربط Google Drive. احفظ إعدادات API وتحقق من مفتاح الإدارة.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: <Widget>[
              const Text('وضع البيانات', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile.adaptive(
                  value: _demo,
                  onChanged: (value) => setState(() => _demo = value),
                  title: Text(_demo ? 'وضع العرض التجريبي مفعّل' : 'الاتصال بالخادم مفعّل', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(_demo ? 'بيانات نموذجية على الجهاز لاختبار الواجهة.' : 'سيستخدم التطبيق ASP.NET Core API الحقيقي.'),
                  secondary: Icon(_demo ? Icons.science_outlined : Icons.cloud_done_outlined, color: _demo ? AppColors.primary : AppColors.mint),
                ),
              ),
              const SizedBox(height: 22),
              const Text('الخادم والروابط العامة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apiController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'عنوان ASP.NET Core API', hintText: 'https://api.yourdomain.com'),
                validator: (value) => Uri.tryParse(value?.trim() ?? '')?.hasScheme == true ? null : 'أدخل عنوان HTTPS صحيحًا.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _publicController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'النطاق العام لرموز QR', hintText: 'https://qr.yourdomain.com'),
                validator: (value) => Uri.tryParse(value?.trim() ?? '')?.hasScheme == true ? null : 'أدخل رابطًا عامًا صحيحًا.',
              ),
              const SizedBox(height: 10),
              const Text('يجب أن يبقى النطاق العام ثابتًا لأنه هو الرابط الذي سيُطبع داخل كل رمز QR.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminKeyController,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'مفتاح إدارة API', hintText: 'يوضع في الحقل X-Admin-Key'),
                validator: (value) => !_demo && (value == null || value.trim().length < 16) ? 'أدخل مفتاح إدارة قويًا من 16 حرفًا على الأقل.' : null,
              ),
              const SizedBox(height: 22),
              const Text('المحتوى', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFF0ECFF), child: Icon(Icons.perm_media_outlined, color: Color(0xFF7C3AED))),
                  title: const Text('مكتبة المحتوى', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('استعرض الروابط والنصوص والملفات المستخدمة في رموزك.'),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () => Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const ContentLibraryPage())),
                ),
              ),
              const SizedBox(height: 22),
              const Text('Google Drive', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFEAF0FF), child: Icon(Icons.folder_copy_outlined, color: AppColors.primary)),
                  title: const Text('ربط Google Drive', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: const Text('يفتح تفويض OAuth الآمن من الخادم. لا تضع بيانات Google السرية في التطبيق.'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: _connectGoogleDrive,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined),
                label: const Text('حفظ الإعدادات'),
              ),
              const SizedBox(height: 18),
              const Text('الإصدار 1.0.0 · Android', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
        ),
      );
}
