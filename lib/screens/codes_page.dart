import 'package:flutter/material.dart';

import '../app.dart';
import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'qr_detail_page.dart';

class CodesPage extends StatefulWidget {
  const CodesPage({super.key});

  @override
  State<CodesPage> createState() => _CodesPageState();
}

class _CodesPageState extends State<CodesPage> {
  String _query = '';
  ContentType? _filter;

  @override
  Widget build(BuildContext context) {
    final controller = QrManagerScope.codesOf(context);
    final filtered = controller.codes.where((QrCode code) {
      final matchesQuery = _query.isEmpty || '${code.title} ${code.bookName} ${code.chapterName}'.toLowerCase().contains(_query.toLowerCase());
      return matchesQuery && (_filter == null || code.target.type == _filter);
    }).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text('الرموز')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'ابحث باسم الدرس أو الكتاب'),
            ),
          ),
          SizedBox(
            height: 42,
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
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.reload,
              child: controller.isLoading && controller.codes.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? ListView(children: const <Widget>[SizedBox(height: 140), EmptyPanel(title: 'لا توجد نتائج', message: 'جرّب كلمة بحث أخرى أو أنشئ رمزًا جديدًا.', icon: Icons.search_off_rounded)])
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final code = filtered[index];
                            return QrCodeTile(code: code, onTap: () => Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => QrDetailPage(code: code))));
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
