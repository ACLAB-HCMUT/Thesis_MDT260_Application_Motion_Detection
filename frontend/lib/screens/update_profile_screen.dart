import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Personal Information'
        , style: TextStyle(fontSize: 18))
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
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Chiều cao
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Cân nặng
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Ngày sinh
              TextField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
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
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.accessibility),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
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
                    child: const Text('Cancel'),
                  ),
                  
                  // Nút Lưu
                  ElevatedButton(
                    onPressed: () {
                      // Logic cập nhật thông tin
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Màu xanh cho nút Lưu
                    ),
                    child: const Text('Save'),
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
