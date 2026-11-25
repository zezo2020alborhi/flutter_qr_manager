import 'package:flutter/widgets.dart';

import 'app.dart';
import 'controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await SettingsController.create();
  runApp(QrManagerApp(settingsController: settings));
}
