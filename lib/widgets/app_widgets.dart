import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({required this.label, required this.value, required this.icon, this.accent = AppColors.primary, super.key});
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: accent.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(height: 18),
              Text(value, style: const TextStyle(color: AppColors.ink, fontSize: 23, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
            ],
          ),
        ),
      );
}

class ContentTypeBadge extends StatelessWidget {
  const ContentTypeBadge({required this.type, super.key});
  final ContentType type;

  IconData get _icon => switch (type) {
        ContentType.link => Icons.link_rounded,
        ContentType.text => Icons.notes_rounded,
        ContentType.pdf => Icons.picture_as_pdf_rounded,
        ContentType.image => Icons.image_outlined,
        ContentType.video => Icons.play_circle_outline_rounded,
      };

  Color get _color => switch (type) {
        ContentType.link => AppColors.primary,
        ContentType.text => const Color(0xFF7C3AED),
        ContentType.pdf => AppColors.danger,
        ContentType.image => const Color(0xFFF97316),
        ContentType.video => AppColors.mint,
      };

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: _color.withOpacity(.11), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: 14, color: _color),
            const SizedBox(width: 4),
            Text(type.arabicLabel, style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class QrCodeTile extends StatelessWidget {
  const QrCodeTile({required this.code, required this.onTap, super.key});
  final QrCode code;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(code.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      Text('${code.bookName} · ${code.chapterName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      const SizedBox(height: 9),
                      Row(
                        children: <Widget>[
                          ContentTypeBadge(type: code.target.type),
                          const SizedBox(width: 9),
                          Icon(Icons.qr_code_scanner_rounded, size: 15, color: AppColors.muted),
                          const SizedBox(width: 3),
                          Text(NumberFormat.decimalPattern('ar').format(code.scanCount), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(code.isActive ? Icons.chevron_left_rounded : Icons.pause_circle_outline_rounded, color: code.isActive ? AppColors.muted : AppColors.danger),
              ],
            ),
          ),
        ),
      );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.actionLabel, this.onAction, super.key});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink))),
            if (actionLabel != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({required this.title, required this.message, required this.icon, super.key});
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, height: 1.5)),
            ],
          ),
        ),
      );
}
