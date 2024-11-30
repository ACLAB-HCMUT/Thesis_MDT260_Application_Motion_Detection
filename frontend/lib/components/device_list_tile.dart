import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceListTile extends StatelessWidget {
  final BluetoothDevice device;
  final bool isConnecting;
  final VoidCallback onTap;

  const DeviceListTile({
    super.key,
    required this.device,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        device.platformName.isNotEmpty ? device.platformName : "Thiết bị không xác định",
      ),
      subtitle: Text(device.remoteId.toString()),
      trailing: Text(isConnecting ? "Đang kết nối" : "Kết nối"), // Change the text based on the connecting state
      onTap: onTap,
    );
  }
}