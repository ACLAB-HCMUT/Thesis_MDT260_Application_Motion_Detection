import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cập nhật thông tin cá nhân'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Họ và tên
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Họ và Tên',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Chiều cao
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Chiều cao (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Cân nặng
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Ngày sinh
              TextField(
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      // Mở một DatePicker cho người dùng chọn ngày sinh
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Giới tính
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Giới tính',
                  prefixIcon: Icon(Icons.accessibility),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Nam',
                    child: Text('Nam'),
                  ),
                  DropdownMenuItem(
                    value: 'Nữ',
                    child: Text('Nữ'),
                  ),
                  DropdownMenuItem(
                    value: 'Khác',
                    child: Text('Khác'),
                  ),
                ],
                onChanged: (value) {
                  // Xử lý sự thay đổi giới tính ở đây
                },
              ),
              const SizedBox(height: 20),

              // Nút Hủy và Lưu trên cùng một hàng
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
                  
                  // Nút Lưu
                  ElevatedButton(
                    onPressed: () {
                      // Logic cập nhật thông tin
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Màu xanh cho nút Lưu
                    ),
                    child: const Text('Lưu'),
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
