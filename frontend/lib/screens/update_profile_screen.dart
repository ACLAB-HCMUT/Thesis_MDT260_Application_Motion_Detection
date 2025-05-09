import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';  // Đảm bảo bạn đã import AuthService

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  String _gender = 'male'; // Default value

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.update_personal_infor,
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.full_name,
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              // Height
              TextField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: '${AppLocalizations.of(context)!.height} (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Weight
              TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: '${AppLocalizations.of(context)!.weight} (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Date of Birth
              TextField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.date_of_birth,
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      // Mở một DatePicker cho người dùng chọn ngày sinh
                      _selectDate(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.gender,
                  prefixIcon: Icon(Icons.accessibility),
                ),
                items:  [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text(AppLocalizations.of(context)!.male),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text(AppLocalizations.of(context)!.female),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Cancel and Save buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Return to the previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red for Cancel button
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      // Get input values
                      String fullName = _fullNameController.text;
                      String dateOfBirth = _dateOfBirthController.text;
                      double weight = double.tryParse(_weightController.text) ?? 0;
                      double height = double.tryParse(_heightController.text) ?? 0;

                      // Validate inputs before calling updateUser
                      if (fullName.isEmpty || dateOfBirth.isEmpty || weight <= 0 || height <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all fields with valid data')),
                        );
                        return;
                      }

                      // Call the updateUser function
                      var response = await _authService.updateUser(
                        fullName,
                        dateOfBirth,
                        _gender,
                        weight,
                        height,
                      );

                      // Check the response and show feedback
                      if (response.containsKey('error')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response['error'])),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated successfully')),
                        );
                        Navigator.pop(context); // Return to the previous screen
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blue for Save button
                    ),
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show the DatePicker
  Future<void> _selectDate(BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        _dateOfBirthController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
  }
}
