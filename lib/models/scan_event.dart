class ScanEvent {
  const ScanEvent({
    required this.id,
    required this.qrTitle,
    required this.scannedAt,
    this.deviceType,
    this.countryCode,
  });

  final String id;
  final String qrTitle;
  final DateTime scannedAt;
  final String? deviceType;
  final String? countryCode;

  factory ScanEvent.fromJson(Map<String, dynamic> json) => ScanEvent(
        id: json['id'].toString(),
        qrTitle: json['qrTitle'] as String? ?? '',
        scannedAt: DateTime.parse(json['scannedAt'] as String),
        deviceType: json['deviceType'] as String?,
        countryCode: json['countryCode'] as String?,
      );
}
