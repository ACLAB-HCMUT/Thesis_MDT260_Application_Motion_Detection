import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

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
        title: Text(
          AppLocalizations.of(context)!.change_infor_login,
          style: TextStyle(fontSize: 17), // Adjust font size here
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.user_name,
                  prefixIcon: Icon(Icons.person), // User icon
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextField(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  prefixIcon: Icon(Icons.email), // Email icon
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Old Password
              TextField(
                obscureText: _obscureOldPassword,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.old_password,
                  prefixIcon: const Icon(Icons.lock), // Password icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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

              // New Password
              TextField(
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.new_password,
                  prefixIcon:
                      const Icon(Icons.lock_outline), // New password icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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

              // Cancel and Update buttons on the same row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cancel Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Red color for Cancel button
                    ),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),

                  // Update Button
                  ElevatedButton(
                    onPressed: () {
                      // Logic to update login information
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Blue color for Update button
                    ),
                    child: Text(AppLocalizations.of(context)!.update),
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
