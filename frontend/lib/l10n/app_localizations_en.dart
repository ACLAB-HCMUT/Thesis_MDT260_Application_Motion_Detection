import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get hello => 'Hello';

  @override
  String get notifications => 'Detected actions:';
  
  @override
  String get step_count => "Today's step count:";
  
   @override
  String get step => "Steps";
  //Settings screen
  @override
  String get dart_mode => 'Dart Mode';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get english => 'English';

  @override
  String get ble_connect => 'BLE Connection';

  @override
   String get no_device_connect => 'No devices connected';

     @override
  String get connected_device => 'Connected to';
}
