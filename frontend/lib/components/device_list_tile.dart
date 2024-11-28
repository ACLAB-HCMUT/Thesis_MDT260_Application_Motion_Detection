import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceListTile extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  const DeviceListTile({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
          device.platformName.isNotEmpty ? device.platformName : "Thiết bị không xác định"),
      subtitle: Text(device.remoteId.toString()),
      trailing: const Text("Kết nối"),
      onTap: onTap,
    );
  }
}
