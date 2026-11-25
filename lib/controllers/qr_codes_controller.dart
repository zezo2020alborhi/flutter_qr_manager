import 'package:flutter/foundation.dart';

import '../models/analytics.dart';
import '../models/app_settings.dart';
import '../models/content_target.dart';
import '../models/qr_code.dart';
import '../models/scan_event.dart';
import '../services/qr_repository.dart';

class QrCodesController extends ChangeNotifier {
  QrCodesController(AppSettings settings) : _settings = settings {
    _repository = _buildRepository(settings);
  }

  AppSettings _settings;
  late QrRepository _repository;
  List<QrCode> _codes = <QrCode>[];
  AnalyticsOverview? _overview;
  List<ScanEvent> _recentScans = <ScanEvent>[];
  bool _isLoading = false;
  String? _error;

  List<QrCode> get codes => List<QrCode>.unmodifiable(_codes);
  AnalyticsOverview? get overview => _overview;
  List<ScanEvent> get recentScans => List<ScanEvent>.unmodifiable(_recentScans);
  bool get isLoading => _isLoading;
  String? get error => _error;

  QrRepository _buildRepository(AppSettings settings) =>
      settings.useDemoData ? DemoQrRepository() : ApiQrRepository(settings);

  Future<void> reload({String query = ''}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _codes = await _repository.listCodes(query: query);
      _overview = await _repository.analytics();
      _recentScans = await _repository.recentScans();
    } catch (error) {
      _error = 'تعذر الاتصال بالخادم. تحقق من عنوان API ثم أعد المحاولة.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeSettings(AppSettings settings) async {
    _settings = settings;
    _repository = _buildRepository(settings);
    await reload();
  }

  String publicUrlFor(QrCode code) =>
      '${_settings.publicBaseUrl.replaceFirst(RegExp(r'/$'), '')}/q/${code.publicKey}';

  Future<QrCode> create(QrCodeDraft draft) async {
    final created = await _repository.createCode(draft);
    _codes = <QrCode>[created, ..._codes];
    _overview = await _repository.analytics();
    _recentScans = await _repository.recentScans();
    notifyListeners();
    return created;
  }

  Future<QrCode> updateTarget(String id, ContentTarget target) async {
    final updated = await _repository.updateTarget(id, target);
    _replace(updated);
    return updated;
  }

  Future<QrCode> setActive(String id, bool isActive) async {
    final updated = await _repository.setActive(id, isActive);
    _replace(updated);
    return updated;
  }

  Future<Uri> googleDriveAuthorizationUri() => _repository.googleDriveAuthorizationUri();

  void _replace(QrCode code) {
    _codes = _codes.map((item) => item.id == code.id ? code : item).toList(growable: false);
    notifyListeners();
  }
}
