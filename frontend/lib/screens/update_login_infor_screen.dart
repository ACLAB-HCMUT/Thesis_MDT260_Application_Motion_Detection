import 'package:flutter/material.dart';

class UpdateLoginInfoScreen extends StatefulWidget {
  const UpdateLoginInfoScreen({super.key});

  @override
  _UpdateLoginInfoScreenState createState() => _UpdateLoginInfoScreenState();
}

class _UpdateLoginInfoScreenState extends State<UpdateLoginInfoScreen> {
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thay đổi thông tin đăng nhập'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Tên đăng nhập',
                  prefixIcon: Icon(Icons.person), // Icon user
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email), // Icon email
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Mật khẩu cũ
              TextField(
                obscureText: _obscureOldPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu cũ',
                  prefixIcon: const Icon(Icons.lock), // Icon password
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mật khẩu mới
              TextField(
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  prefixIcon: const Icon(Icons.lock_outline), // Icon password mới
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Hủy và Cập nhật trên cùng một hàng
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nút Hủy
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Quay lại màn hình trước đó
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Màu đỏ cho nút Hủy
                    ),
                    child: const Text('Hủy'),
                  ),

                  // Nút Cập nhật
                  ElevatedButton(
                    onPressed: () {
                      // Logic cập nhật thông tin đăng nhập
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Màu xanh cho nút Cập nhật
                    ),
                    child: const Text('Cập nhật'),
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
