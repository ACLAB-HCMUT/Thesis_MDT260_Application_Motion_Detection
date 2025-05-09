import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import 'update_profile_screen.dart';
import 'update_login_infor_screen.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = true;
  bool _isLoggingOut = false; // Biến để kiểm soát hiệu ứng xoay
  Map<String, dynamic> _userProfile = {};

  // Lấy thông tin người dùng từ AuthService
  Future<void> _fetchUserProfile() async {
    final authService = AuthService();
    final profile = await authService.getUserProfile();

    if (profile.containsKey("error")) {
      // Xử lý lỗi nếu có
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _userProfile = profile['user'];  // Lấy dữ liệu người dùng từ API
      _isLoading = false;
    });
  }

  // Xử lý đăng xuất
  Future<void> _logOut() async {
    setState(() {
      _isLoggingOut = true; // Bắt đầu hiệu ứng xoay
    });

    // Giả lập quá trình đăng xuất (thực tế sẽ gọi API hoặc thực hiện xử lý đăng xuất ở đây)
    await Future.delayed(const Duration(seconds: 2)); // Giả lập delay khi đăng xuất

    final authService = AuthService();
    await authService.saveToken(''); // Xóa token

    setState(() {
      _isLoggingOut = false; // Kết thúc hiệu ứng xoay
    });

    // Sau khi đăng xuất, điều hướng về màn hình đăng nhập hoặc màn hình chính
    Navigator.pushReplacementNamed(context, '/login'); // Điều hướng tới màn hình đăng nhập
  }

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Gọi hàm lấy thông tin người dùng khi màn hình được tạo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.user_profile),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _isLoading
                  ? const CircularProgressIndicator() // Hiển thị loading khi đang tải dữ liệu
                  : Column(
                      children: [
                        // Hiển thị tên đầy đủ
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['full_name'] ?? ''),
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.full_name),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        // Hiển thị email
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['email'] ?? ''),
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        // Hiển thị ngày sinh
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['date_of_birth'] ?? ''),
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.date_of_birth),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        // Hiển thị giới tính
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['gender'] ?? ''),
                          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.gender),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        // Hiển thị cân nặng
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['weight']?.toString() ?? ''),
                          decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.weight} (kg)'),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        // Hiển thị chiều cao
                        TextField(
                          controller: TextEditingController(
                              text: _userProfile['height']?.toString() ?? ''),
                          decoration: InputDecoration(labelText: '${AppLocalizations.of(context)!.height} (cm)'),
                          readOnly: true, // Không cho phép chỉnh sửa
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpdateProfileScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(AppLocalizations.of(context)!.update_personal_infor),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UpdateLoginInfoScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 156, 125, 78),
                          ),
                          child: Text(AppLocalizations.of(context)!.change_infor_login),
                        ),
                        const SizedBox(height: 10),
                        // Nút Logout với hiệu ứng xoay
                        ElevatedButton(
                          onPressed: _logOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 180, 23, 12),
                          ),
                          child: _isLoggingOut
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(AppLocalizations.of(context)!.log_out),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
