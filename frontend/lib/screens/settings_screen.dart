import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<AppLocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            ListTile(
              title: const Text('Ngôn ngữ'),
              trailing: DropdownButton<Locale>(
                value: localeNotifier.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localeNotifier.setLocale(newLocale);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/uk_flag.png', // Đảm bảo đường dẫn ảnh đúng
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Text('English'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: const Locale('vi'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/vn_flag.png', // Đảm bảo đường dẫn ảnh đúng
                          width: 30,
                          height: 30,
                        ),
                        SizedBox(width: 10),
                        Text('Tiếng Việt'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
