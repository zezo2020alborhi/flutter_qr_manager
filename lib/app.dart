import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/qr_codes_controller.dart';
import 'controllers/settings_controller.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

class QrManagerScope extends InheritedNotifier<QrCodesController> {
  const QrManagerScope({
    required QrCodesController controller,
    required this.settingsController,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  final SettingsController settingsController;

  static QrCodesController codesOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QrManagerScope>()!.notifier!;

  static SettingsController settingsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<QrManagerScope>()!.settingsController;
}

class QrManagerApp extends StatefulWidget {
  const QrManagerApp({required this.settingsController, super.key});
  final SettingsController settingsController;

  @override
  State<QrManagerApp> createState() => _QrManagerAppState();
}

class _QrManagerAppState extends State<QrManagerApp> {
  late final QrCodesController _codesController;

  @override
  void initState() {
    super.initState();
    _codesController = QrCodesController(widget.settingsController.value)..reload();
    widget.settingsController.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    _codesController.changeSettings(widget.settingsController.value);
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_onSettingsChanged);
    _codesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'مدير الرموز',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('ar'),
        supportedLocales: const <Locale>[Locale('ar')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: QrManagerScope(
            controller: _codesController,
            settingsController: widget.settingsController,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
        home: const HomeShell(),
      );
}
