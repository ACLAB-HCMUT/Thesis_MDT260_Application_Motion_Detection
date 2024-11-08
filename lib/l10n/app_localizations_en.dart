import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get notifications => 'Detected actions:';
  
  @override
  // TODO: implement language
  String get language => throw UnimplementedError();
  
  @override
  // TODO: implement settings
  String get settings => throw UnimplementedError();
}
