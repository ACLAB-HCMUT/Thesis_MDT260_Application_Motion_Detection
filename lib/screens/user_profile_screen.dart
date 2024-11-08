import 'package:flutter/material.dart';
import '../models/mock_data.dart';

class UserProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ Sơ Người Dùng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: mockUser['name']),
              decoration: InputDecoration(labelText: 'Tên'),
            ),
            TextField(
              controller: TextEditingController(text: mockUser['email']),
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Cập Nhật Thông Tin'),
            ),
          ],
        ),
      ),
    );
  }
}
