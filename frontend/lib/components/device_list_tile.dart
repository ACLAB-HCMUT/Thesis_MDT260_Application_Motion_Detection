import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';

class DeviceListTile extends StatelessWidget {
  final Map<String, String> device;

  const DeviceListTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.bluetooth),
      title: Text(device['name'] ?? 'Unknown Device'),
      subtitle: Text(device['mac'] ?? 'No Address'),
      trailing: IconButton(
        icon: Icon(Icons.link),
        onPressed: () {
          // Logic to connect to the device
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        },
      ),
    );
  }
}
