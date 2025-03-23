import 'package:flutter/material.dart';
import 'update_profile_screen.dart';
import 'update_login_infor_screen.dart';
import '../models/mock_data.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ Người Dùng'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0), // Giảm padding cho hai bên
        child: SingleChildScrollView(
          // Đảm bảo không bị tràn khi có quá nhiều nội dung
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .start, // Căn bắt đầu (giảm khoảng cách với appbar)
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn giữa các widget
            children: [
              TextField(
                controller: TextEditingController(text: mockUsers[0]['name']),
                decoration: const InputDecoration(labelText: 'Tên'),
              ),
              TextField(
                controller: TextEditingController(text: mockUsers[0]['email']),
                decoration: const InputDecoration(labelText: 'Email'),
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
                  backgroundColor: Colors.blue, // Màu nền cho button
                ),
                child: const Text('Cập nhật thông tin cá nhân'),
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
                  backgroundColor: const Color.fromARGB(
                      255, 156, 125, 78), // Màu nền cho button
                ),
                child: const Text('Thay đổi thông tin đăng nhập'),
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
                  backgroundColor: const Color.fromARGB(255, 81, 156, 78), // Màu nền cho button
                ),
                child: const Text('Thông tin người thân'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Logic đăng xuất
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 180, 23, 12), // Màu nền đỏ cho button Đăng xuất
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
