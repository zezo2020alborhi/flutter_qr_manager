enum ContentType {
  link,
  text,
  pdf,
  image,
  video,
}

extension ContentTypeLabel on ContentType {
  String get arabicLabel => switch (this) {
        ContentType.link => 'رابط',
        ContentType.text => 'نص',
        ContentType.pdf => 'PDF',
        ContentType.image => 'صورة',
        ContentType.video => 'فيديو',
      };

  String get apiValue => name;

  static ContentType fromApi(String? value) => ContentType.values.firstWhere(
        (type) => type.name.toLowerCase() == value?.toLowerCase(),
        orElse: () => ContentType.link,
      );
}

class ContentTarget {
  const ContentTarget({
    required this.type,
    required this.title,
    required this.value,
    this.driveFileId,
    this.description,
    this.version = 1,
  });

  final ContentType type;
  final String title;
  final String value;
  final String? driveFileId;
  final String? description;
  final int version;

  bool get isExternalUrl => type != ContentType.text;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type.apiValue,
        'title': title,
        'value': value,
        'driveFileId': driveFileId,
        'description': description,
      };

  factory ContentTarget.fromJson(Map<String, dynamic> json) => ContentTarget(
        type: ContentTypeLabel.fromApi(json['type'] as String?),
        title: json['title'] as String? ?? '',
        value: json['value'] as String? ?? '',
        driveFileId: json['driveFileId'] as String?,
        description: json['description'] as String?,
        version: json['version'] as int? ?? 1,
      );
}
