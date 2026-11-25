import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'qr_detail_page.dart';

class ContentLibraryPage extends StatefulWidget {
  const ContentLibraryPage({super.key});

  @override
  State<ContentLibraryPage> createState() => _ContentLibraryPageState();
}

class _ContentLibraryPageState extends State<ContentLibraryPage> {
  ContentType? _filter;

  Future<void> _preview(QrCode code) async {
    if (code.target.type == ContentType.text) {
      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          child: SingleChildScrollView(child: Text(code.target.value, style: const TextStyle(fontSize: 16, height: 1.8))),
        ),
      );
      return;
    }
    final url = Uri.tryParse(code.target.value);
    if (url != null) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final codes = QrManagerScope.codesOf(context).codes.where((code) => _filter == null || code.target.type == _filter).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('مكتبة المحتوى')),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: <Widget>[
                ChoiceChip(label: const Text('الكل'), selected: _filter == null, onSelected: (_) => setState(() => _filter = null)),
                const SizedBox(width: 8),
                ...ContentType.values.map((type) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(label: Text(type.arabicLabel), selected: _filter == type, onSelected: (_) => setState(() => _filter = type)),
                    )),
              ],
            ),
          ),
          Expanded(
            child: codes.isEmpty
                ? const EmptyPanel(title: 'المكتبة فارغة', message: 'ستظهر هنا المحتويات عندما تنشئ رموز QR جديدة.', icon: Icons.perm_media_outlined)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    itemCount: codes.length,
                    itemBuilder: (context, index) {
                      final code = codes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          leading: ContentTypeBadge(type: code.target.type),
                          title: Text(code.target.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('مستخدم في: ${code.title}', maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              if (action == 'open') _preview(code);
                              if (action == 'details') Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => QrDetailPage(code: code)));
                            },
                            itemBuilder: (context) => const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(value: 'open', child: Text('فتح المحتوى')),
                              PopupMenuItem<String>(value: 'details', child: Text('تفاصيل الرمز')),
                            ],
                          ),
                          onTap: () => _preview(code),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
