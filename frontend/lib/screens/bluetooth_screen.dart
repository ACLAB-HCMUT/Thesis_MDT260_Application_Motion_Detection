import 'package:flutter/material.dart';
import '../components/device_list_tile.dart';
import '../models/mock_data.dart';
// import 'dashboard_screen.dart';

class BluetoothScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết nối với XIAO SENSE'),
      ),
      body: ListView.builder(
        itemCount: mockDevices.length,
        itemBuilder: (context, index) {
          return DeviceListTile(device: mockDevices[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quét thiết bị logic
        },
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }
}