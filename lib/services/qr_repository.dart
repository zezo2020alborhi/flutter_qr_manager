import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/analytics.dart';
import '../models/app_settings.dart';
import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../models/scan_event.dart';

abstract class QrRepository {
  Future<List<QrCode>> listCodes({String query = ''});
  Future<QrCode> createCode(QrCodeDraft draft);
  Future<QrCode> updateTarget(String id, ContentTarget target);
  Future<QrCode> setActive(String id, bool isActive);
  Future<AnalyticsOverview> analytics();
  Future<List<ScanEvent>> recentScans();
  Future<Uri> googleDriveAuthorizationUri();
}

class ApiQrRepository implements QrRepository {
  ApiQrRepository(this.settings, {http.Client? client}) : _client = client ?? http.Client();

  final AppSettings settings;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) => Uri.parse(
        '${settings.apiBaseUrl.replaceAll(RegExp(r'/$'), '')}$path',
      ).replace(queryParameters: query);

  Map<String, String> get _headers => <String, String>{
        if (settings.adminApiKey.isNotEmpty) 'X-Admin-Key': settings.adminApiKey,
      };

  Future<Map<String, dynamic>> _json(http.Response response) async {
    if (response.statusCode < 200 || response.statusCode >= 300) throw ApiException(response.statusCode, response.body);
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  @override
  Future<List<QrCode>> listCodes({String query = ''}) async {
    final response = await _client.get(_uri('/api/qr-codes', <String, String>{'query': query}), headers: _headers);
    final payload = await _json(response);
    return (payload['items'] as List<dynamic>).map((item) => QrCode.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<QrCode> createCode(QrCodeDraft draft) async {
    final response = await _client.post(
      _uri('/api/qr-codes'),
      headers: <String, String>{..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(draft.toJson()),
    );
    return QrCode.fromJson(await _json(response));
  }


@override
Future<QrCode> updateTarget(String id, ContentTarget target) async {
  final response = await _client.put(
    _uri('/api/qr-codes/$id/target'),
    headers: <String, String>{
      ..._headers,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, dynamic>{
      'target': target.toJson(),
    }),
  );

  return QrCode.fromJson(await _json(response));
}


  @override
  Future<QrCode> setActive(String id, bool isActive) async {
    final response = await _client.post(
      _uri('/api/qr-codes/$id/status'),
      headers: <String, String>{..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'isActive': isActive}),
    );
    return QrCode.fromJson(await _json(response));
  }

  @override
  Future<AnalyticsOverview> analytics() async {
    final response = await _client.get(_uri('/api/analytics/overview'), headers: _headers);
    return AnalyticsOverview.fromJson(await _json(response));
  }

  @override
  Future<List<ScanEvent>> recentScans() async {
    final response = await _client.get(_uri('/api/analytics/recent-scans', <String, String>{'take': '20'}), headers: _headers);
    final payload = await _json(response);
    return (payload['items'] as List<dynamic>).map((item) => ScanEvent.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Uri> googleDriveAuthorizationUri() async {
    final response = await _client.get(_uri('/api/integrations/google-drive/authorization-url'), headers: _headers);
    final payload = await _json(response);
    final value = payload['url'] as String?;
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) throw const ApiException(500, 'استجابة OAuth غير صالحة.');
    return uri;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class DemoQrRepository implements QrRepository {
  final List<QrCode> _codes = <QrCode>[
    QrCode(
      id: '1', publicKey: 'f5-lesson-1', title: 'تجربة الماء والملح', bookName: 'علوم الصف الخامس', chapterName: 'الفصل الأول',
      target: const ContentTarget(type: ContentType.video, title: 'فيديو التجربة', value: 'https://drive.google.com/file/d/example/view'),
      isActive: true, scanCount: 248, createdAt: DateTime(2026, 8, 1), updatedAt: DateTime(2026, 8, 20), lastScanAt: DateTime.now().subtract(const Duration(minutes: 17)),
    ),
    QrCode(
      id: '2', publicKey: 'arabic-reading-2', title: 'نشاط القراءة الإثرائي', bookName: 'اللغة العربية', chapterName: 'الوحدة الثانية',
      target: const ContentTarget(type: ContentType.pdf, title: 'ورقة النشاط', value: 'https://drive.google.com/file/d/example2/view'),
      isActive: true, scanCount: 96, createdAt: DateTime(2026, 8, 3), updatedAt: DateTime(2026, 8, 19),
    ),
  ];

  @override
  Future<List<QrCode>> listCodes({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (query.trim().isEmpty) return List<QrCode>.unmodifiable(_codes);
    final value = query.trim().toLowerCase();
    return _codes.where((code) => '${code.title} ${code.bookName} ${code.chapterName}'.toLowerCase().contains(value)).toList(growable: false);
  }

  @override
  Future<QrCode> createCode(QrCodeDraft draft) async {
    final now = DateTime.now();
    final code = QrCode(
      id: now.microsecondsSinceEpoch.toString(), publicKey: 'lesson-${now.microsecondsSinceEpoch}', title: draft.title, bookName: draft.bookName, chapterName: draft.chapterName,
      target: draft.target, isActive: true, scanCount: 0, createdAt: now, updatedAt: now,
    );
    _codes.insert(0, code);
    return code;
  }

   @override
  Future<QrCode> updateTarget(String id, ContentTarget target) async {
    final index = _codes.indexWhere((item) => item.id == id);
    final updated = _codes[index].copyWith(target: target, updatedAt: DateTime.now());
    _codes[index] = updated;
    return updated;
  }  

 

  @override
  Future<QrCode> setActive(String id, bool isActive) async {
    final index = _codes.indexWhere((item) => item.id == id);
    final updated = _codes[index].copyWith(isActive: isActive, updatedAt: DateTime.now());
    _codes[index] = updated;
    return updated;
  }

  @override
  Future<AnalyticsOverview> analytics() async => AnalyticsOverview(
        totalScans: _codes.fold<int>(0, (total, code) => total + code.scanCount),
        todayScans: 18,
        activeCodes: _codes.where((item) => item.isActive).length,
        lastSevenDays: List<DailyScan>.generate(7, (index) => DailyScan(day: DateTime.now().subtract(Duration(days: 6 - index)), count: <int>[9, 16, 11, 23, 18, 31, 18][index])),
      );

  @override
  Future<List<ScanEvent>> recentScans() async => <ScanEvent>[
        ScanEvent(id: 'demo-1', qrTitle: _codes.first.title, scannedAt: DateTime.now().subtract(const Duration(minutes: 17)), deviceType: 'Android', countryCode: 'SA'),
        ScanEvent(id: 'demo-2', qrTitle: _codes.first.title, scannedAt: DateTime.now().subtract(const Duration(hours: 2)), deviceType: 'iPhone', countryCode: 'SA'),
        ScanEvent(id: 'demo-3', qrTitle: _codes.last.title, scannedAt: DateTime.now().subtract(const Duration(hours: 5)), deviceType: 'Android', countryCode: 'AE'),
      ];

  @override
  Future<Uri> googleDriveAuthorizationUri() async => throw StateError('Google Drive غير متاح في وضع العرض التجريبي.');
}
