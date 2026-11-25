import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._(this._preferences, this._settings);

  static const String _apiKey = 'api_base_url';
  static const String _publicKey = 'public_base_url';
  static const String _demoKey = 'use_demo_data';
  static const String _adminKey = 'admin_api_key';

  final SharedPreferences _preferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  AppSettings _settings;

  AppSettings get value => _settings;

  static Future<SettingsController> create() async {
    final preferences = await SharedPreferences.getInstance();
    final adminApiKey = await _secureStorage.read(key: _adminKey) ?? '';
    return SettingsController._(
      preferences,
      AppSettings(
        apiBaseUrl: preferences.getString(_apiKey) ?? AppSettings.initial.apiBaseUrl,
        publicBaseUrl: preferences.getString(_publicKey) ?? AppSettings.initial.publicBaseUrl,
        useDemoData: preferences.getBool(_demoKey) ?? AppSettings.initial.useDemoData,
        adminApiKey: adminApiKey,
      ),
    );
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    await Future.wait(<Future<bool>>[
      _preferences.setString(_apiKey, settings.apiBaseUrl),
      _preferences.setString(_publicKey, settings.publicBaseUrl),
      _preferences.setBool(_demoKey, settings.useDemoData),
    ]);
    await _secureStorage.write(key: _adminKey, value: settings.adminApiKey);
    notifyListeners();
  }
}
