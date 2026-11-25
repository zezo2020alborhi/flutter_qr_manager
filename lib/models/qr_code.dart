import 'content_target.dart';

class QrCode {
  const QrCode({
    required this.id,
    required this.publicKey,
    required this.title,
    required this.bookName,
    required this.chapterName,
    required this.target,
    required this.isActive,
    required this.scanCount,
    required this.createdAt,
    required this.updatedAt,
    this.lastScanAt,
  });

  final String id;
  final String publicKey;
  final String title;
  final String bookName;
  final String chapterName;
  final ContentTarget target;
  final bool isActive;
  final int scanCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastScanAt;

  QrCode copyWith({
    String? title,
    String? bookName,
    String? chapterName,
    ContentTarget? target,
    bool? isActive,
    int? scanCount,
    DateTime? updatedAt,
    DateTime? lastScanAt,
  }) =>
      QrCode(
        id: id,
        publicKey: publicKey,
        title: title ?? this.title,
        bookName: bookName ?? this.bookName,
        chapterName: chapterName ?? this.chapterName,
        target: target ?? this.target,
        isActive: isActive ?? this.isActive,
        scanCount: scanCount ?? this.scanCount,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastScanAt: lastScanAt ?? this.lastScanAt,
      );

  factory QrCode.fromJson(Map<String, dynamic> json) => QrCode(
        id: json['id'].toString(),
        publicKey: json['publicKey'] as String,
        title: json['title'] as String,
        bookName: json['bookName'] as String? ?? '',
        chapterName: json['chapterName'] as String? ?? '',
        target: ContentTarget.fromJson(json['target'] as Map<String, dynamic>),
        isActive: json['isActive'] as bool? ?? true,
        scanCount: json['scanCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        lastScanAt: json['lastScanAt'] == null
            ? null
            : DateTime.parse(json['lastScanAt'] as String),
      );
}

class QrCodeDraft {
  const QrCodeDraft({
    required this.title,
    required this.bookName,
    required this.chapterName,
    required this.target,
  });

  final String title;
  final String bookName;
  final String chapterName;
  final ContentTarget target;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'bookName': bookName,
        'chapterName': chapterName,
        'target': target.toJson(),
      };
}
