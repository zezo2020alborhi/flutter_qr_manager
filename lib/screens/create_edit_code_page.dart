import 'package:flutter/material.dart';

import '../app.dart';
import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';

class CreateEditCodePage extends StatefulWidget {
  const CreateEditCodePage({this.existing, super.key});
  final QrCode? existing;

  @override
  State<CreateEditCodePage> createState() => _CreateEditCodePageState();
}

class _CreateEditCodePageState extends State<CreateEditCodePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lessonController;
  late final TextEditingController _bookController;
  late final TextEditingController _chapterController;
  late final TextEditingController _contentTitleController;
  late final TextEditingController _contentValueController;
  late final TextEditingController _descriptionController;
  late ContentType _type;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final code = widget.existing;
    _lessonController = TextEditingController(text: code?.title ?? '');
    _bookController = TextEditingController(text: code?.bookName ?? '');
    _chapterController = TextEditingController(text: code?.chapterName ?? '');
    _contentTitleController = TextEditingController(text: code?.target.title ?? '');
    _contentValueController = TextEditingController(text: code?.target.value ?? '');
    _descriptionController = TextEditingController(text: code?.target.description ?? '');
    _type = code?.target.type ?? ContentType.link;
  }

  @override
  void dispose() {
    _lessonController.dispose();
    _bookController.dispose();
    _chapterController.dispose();
    _contentTitleController.dispose();
    _contentValueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _valueLabel => _type == ContentType.text ? 'النص الذي سيظهر للطالب' : 'رابط المحتوى أو رابط Google Drive';
  String get _valueHint => _type == ContentType.text ? 'اكتب النص التعليمي هنا' : 'https://drive.google.com/...';

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final controller = QrManagerScope.codesOf(context);
    final target = ContentTarget(
      type: _type,
      title: _contentTitleController.text.trim(),
      value: _contentValueController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      version: (widget.existing?.target.version ?? 0) + 1,
    );
    try {
      final QrCode saved;
      if (_editing) {
        saved = await controller.updateTarget(widget.existing!.id, target);
      } else {
        saved = await controller.create(QrCodeDraft(
          title: _lessonController.text.trim(),
          bookName: _bookController.text.trim(),
          chapterName: _chapterController.text.trim(),
          target: target,
        ));
      }
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر حفظ التغييرات. تحقق من اتصال الخادم وحاول مرة أخرى.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(_editing ? 'تعديل المحتوى' : 'إنشاء رمز جديد')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                if (_editing)
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
                    child: const Text('سيبقى رمز QR المطبوع والرابط العام ثابتين. سيتم فقط تغيير المحتوى الذي يراه الطالب عند المسح.', style: TextStyle(color: AppColors.ink, height: 1.5)),
                  )
                else ...<Widget>[
                  const Text('بيانات الدرس', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lessonController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'عنوان الدرس أو النشاط'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'اكتب عنوانًا واضحًا للرمز.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bookController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'اسم الكتاب'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'اكتب اسم الكتاب.' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _chapterController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'الفصل أو الوحدة'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'اكتب اسم الفصل أو الوحدة.' : null,
                  ),
                  const SizedBox(height: 24),
                ],
                const Text('المحتوى المرتبط', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 12),
                DropdownButtonFormField<ContentType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'نوع المحتوى'),
                  items: ContentType.values.map((type) => DropdownMenuItem<ContentType>(value: type, child: Text(type.arabicLabel))).toList(growable: false),
                  onChanged: (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentTitleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'عنوان المحتوى الظاهر'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'اكتب عنوانًا للمحتوى.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentValueController,
                  minLines: _type == ContentType.text ? 5 : 1,
                  maxLines: _type == ContentType.text ? 8 : 2,
                  keyboardType: _type == ContentType.text ? TextInputType.multiline : TextInputType.url,
                  decoration: InputDecoration(labelText: _valueLabel, hintText: _valueHint, alignLabelWithHint: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب.';
                    final uri = Uri.tryParse(value.trim());
                    if (_type != ContentType.text && (uri == null || !uri.hasScheme)) return 'أدخل رابطًا صحيحًا يبدأ بـ https://';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'وصف أو ملاحظة (اختياري)', alignLabelWithHint: true),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border), color: Colors.white),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.info_outline_rounded, color: AppColors.primary),
                      SizedBox(width: 10),
                      Expanded(child: Text('للملفات والصور والفيديو: الصق رابط المشاركة من Google Drive. تأكد من أن إعداد المشاركة يسمح للمستلمين بعرض الملف.', style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.5))),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
                  label: Text(_editing ? 'حفظ المحتوى الجديد' : 'إنشاء الرمز'),
                ),
              ],
            ),
          ),
        ),
      );
}
