import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  //Dashboard screen
  @override
  String get home => 'Trang chủ';

  @override
  String get hello => 'Xin chào!';

  @override
  String get notifications => 'Thông báo';

  @override
  String get step_today => 'Số bước hôm nay: ';

  @override
  String get step => 'bước';

  @override
  String get calories_burned => "Calo tiêu thụ hôm nay: ";

  @override
  String get all_logs => "Tất cả nhật ký";

  //Acivity Chart
  @override
  String get idle => "Đứng yên";

  @override
  String get running => "Chạy bộ";

  @override
  String get walking => "Đi bộ";

  @override
  String get stepping_stairs => "Đi cầu thang";

  @override
  String get hours => "giờ";

  //Detail Screen
  @override
  String get activity_log => "Nhật ký hoạt động";

  @override
  String get from => "Từ";

  @override
  String get to => "Đến";

  @override
  String get total_steps => "Tổng số bước chân";

  @override
  String get calo_burned => "Tổng calo tiêu thụ";

  @override
  String get total_idle_time => "Tổng thời gian đứng yên";

  @override
  String get total_walking_time => "Tống thời gian đi bộ";

  @override
  String get total_running_time => "Tổng thời gian chạy bộ";

  @override
  String get total_stepping_stair_time => "Tổng thời gian đi cầu thang";

  @override
  String get no_data => "Không có dữ liệu";

  //Live Detection Screen
  @override
  String get live_detection => "Phát hiện theo thời gian thực";

  @override
  String get live_motion_detection => "Phát hiện hành động";

  @override
  String get stand_still => "Đứng yên";

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

  @override
  String get disconnect_BLE => 'Ngắt kết nối BLE';

  @override
  String get are_you_sure => 'Bạn có chắc muốn ngắt kết nối không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get disconnect => 'Ngắt kết nối';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get user_profile => 'Hồ sơ người dùng';

  @override
  String get full_name => 'Họ và Tên';

  @override
  String get email => 'Email';

  @override
  String get date_of_birth => 'Ngày sinh';

  @override
  String get gender => 'Giới tính';

  @override
  String get weight => 'Cân nặng';

  @override
  String get height => 'Chiều cao';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get update_personal_infor => 'Cập nhật thông tin cá nhân';

  @override
  String get change_infor_login => 'Thay đổi thông tin đăng nhập';

  @override
  String get log_out => 'Đăng xuất';

  @override
  String get save => 'Lưu';

  @override
  String get user_name => 'Tên đăng nhập';

  @override
  String get old_password => 'Mật khẩu cũ';

  @override
  String get new_password => 'Mật khẩu mới';

  @override
  String get update => 'Cập nhật';
}
