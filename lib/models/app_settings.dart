class AppSettings {
  const AppSettings({
    required this.apiBaseUrl,
    required this.publicBaseUrl,
    required this.useDemoData,
    required this.adminApiKey,
  });

  final String apiBaseUrl;
  final String publicBaseUrl;
  final bool useDemoData;
  final String adminApiKey;

  AppSettings copyWith({
    String? apiBaseUrl,
    String? publicBaseUrl,
    bool? useDemoData,
    String? adminApiKey,
  }) =>
      AppSettings(
        apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
        publicBaseUrl: publicBaseUrl ?? this.publicBaseUrl,
        useDemoData: useDemoData ?? this.useDemoData,
        adminApiKey: adminApiKey ?? this.adminApiKey,
      );

  static const AppSettings initial = AppSettings(
/*   apiBaseUrl: 'http://localhost:57510',
   publicBaseUrl: 'http://10.3.190.8:57510',
     useDemoData: false,
     adminApiKey: 'sddadminkeyiinncdpwd', */

     apiBaseUrl: 'https://taiztwo.bsite.net',
  publicBaseUrl: 'https://taiztwo.bsite.net',
    useDemoData: false,
    adminApiKey: 'sddadminkeyiinncdpwd', 
  );
}
