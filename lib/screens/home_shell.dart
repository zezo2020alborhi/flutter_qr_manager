import 'package:flutter/material.dart';

import '../app.dart';
import '../models/qr_code.dart';
import '../theme/app_theme.dart';
import 'analytics_page.dart';
import 'codes_page.dart';
import 'create_edit_code_page.dart';
import 'dashboard_page.dart';
import 'qr_detail_page.dart';
import 'settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  Future<void> _createCode() async {
    final QrCode? created = await Navigator.of(context).push<QrCode>(MaterialPageRoute<QrCode>(builder: (_) => const CreateEditCodePage()));
    if (!mounted || created == null) return;
    await Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => QrDetailPage(code: created)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(onCreate: _createCode, onOpenCodes: () => setState(() => _index = 1)),
      const CodesPage(),
      const AnalyticsPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: _createCode,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إنشاء رمز'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        height: 74,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.qr_code_2_outlined), selectedIcon: Icon(Icons.qr_code_2_rounded), label: 'الرموز'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: 'الإحصاءات'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune_rounded), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
