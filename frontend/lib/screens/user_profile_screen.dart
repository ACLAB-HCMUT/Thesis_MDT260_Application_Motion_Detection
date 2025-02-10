import 'package:flutter/material.dart';
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
              onPressed: () {},
              child: const Text('Thay đổi thông tin cá nhân'),
            ),

          ],
        ),
      ),
    );
  }
}
