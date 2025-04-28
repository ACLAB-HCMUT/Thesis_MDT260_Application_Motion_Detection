import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);
 

 //Dashboard screen
  @override
  String get dashboard => 'Bảng điều khiển';

  @override
  String get hello => 'Xin chào';

  @override
  String get notifications => 'Phát hiện hành động:';
  
  @override
  String get step_count => 'Số bước hôm nay:';

  @override
  String get step => 'Bước';

 //Settings screen
  @override
  String get dart_mode => 'Chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get settings => 'Cài đặt';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get ble_connect => 'Kết nối Bluetooth';

  @override
  String get no_device_connect => 'Không có thiết bị kết nối';

  @override
  String get connected_device => 'Đã kết nối';
  

  
  


}
