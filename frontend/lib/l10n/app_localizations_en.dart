import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  //Home screen
  @override
  String get home => 'Home';

  @override
  String get hello => 'Hello';

  @override
  String get notifications => 'Notifications';

  @override
  String get step_today => "Steps Today: ";

  @override
  String get step => "steps";

  @override
  String get calories_burned => "Calories Burned Today: ";

  @override
  String get all_logs => "All Logs";

  //Acivity Chart
  @override
  String get idle => "Idle";

  @override
  String get running => "Running";

  @override
  String get walking => "Walking";

  @override
  String get stepping_stairs => "Stepping Stairs";

  @override
  String get hours => "hours";

  //Details screen
  @override
  String get activity_log => "Activity Log";

  @override
  String get from => "From";

  @override
  String get to => "To";

  @override
  String get total_steps => "Total Steps";

  @override
  String get calo_burned => "Calories Burned";

  @override
  String get total_idle_time => "Total Idle Time";

  @override
  String get total_walking_time => "Total Walking Time";

  @override
  String get total_running_time => "Total Running Time";

  @override
  String get total_stepping_stair_time => "Total Stepping Stair Time";

  @override
  String get no_data => "No Data";

  //Live Detection Screen
  @override
  String get live_detection => "Live Detection";

  @override
  String get live_motion_detection => "Live Motion Detection";

  @override
  String get stand_still => "Stand still";

  //Settings screen
  @override
  String get dart_mode => 'Dark Mode';

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

  @override
  String get disconnect_BLE => 'Disconnect BLE';

  @override
  String get are_you_sure => 'Are you sure you want to disconnect?';

  @override
  String get cancel => 'Cancel';

  @override
  String get disconnect => 'Disconnect';

  //User Profile Screen
  @override
  String get profile => 'Profile';

  @override
  String get user_profile => 'User Profile';

  @override
  String get full_name => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get date_of_birth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get update_personal_infor => 'Update Personal Information';

  @override
  String get change_infor_login => 'Change Login Information';

  @override
  String get log_out => 'Log out';

  @override
  String get save => 'Save';

  @override
  String get user_name => 'Username';

  @override
  String get old_password => 'Old Password';

  @override
  String get new_password => 'New Password';

  @override
  String get update => 'Update';

  @override
  String get average_per_day => 'Average per day';

  @override
  String get ble_connection => 'Bluetooth Connection';

  @override
  String get scan_for_devices => 'Scan for Devices';

  @override
  String get scanning => 'Scanning...';

  @override
  String get show_error => 'The end time must be after the start time.';
}
