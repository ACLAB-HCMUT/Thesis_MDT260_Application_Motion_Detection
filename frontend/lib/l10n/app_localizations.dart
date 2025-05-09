import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';


abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// **'Dashboard' Screen
  String get home;
  
  String get hello;

  String get notifications;
  
  String get step_today;
  
  String get step;  
  
  String get calories_burned;

  String get all_logs;
 

  //Acivity Chart 
  String get idle;

  String get running;

  String get walking;

  String get stepping_stairs;
  
  String get hours;


  //Detail Screen
  String get activity_log;

  String get from;
  
  String get to;

  String get total_steps;

  String get calo_burned;
   
  String get total_idle_time;
  
  String get total_walking_time;

  String get total_running_time;

  String get total_stepping_stair_time;

  String get no_data;
  
 //Live Detection Screen 
  String get live_detection;

  String get live_motion_detection;

  String get stand_still;


  //Dashboard screen
  String get dart_mode;

  String get settings;

  String get language;
  
  String get vietnamese;

  String get english;

  String get ble_connect;

  String get no_device_connect;

  String get connected_device;
  
  //Settings Screen

  String get disconnect_BLE;

  String get are_you_sure;

  String get cancel;
  
  String get disconnect;


  String? get darkMode => null;

  String? get selectLanguage => null;

  //User Profile Screen
  String get profile;
  

  String get user_profile;

  String get full_name;

  String get email;
  
  String get date_of_birth;
  
  String get gender;

  String get weight;

  String get height;
  
  String get male;

  String get female;

  String get update_personal_infor;

  String get change_infor_login;

  String get log_out;

  String get save;

  String get user_name;

  String get old_password;

  String get new_password;

  String get update;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
