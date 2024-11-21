import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  final FlutterBluePlus flutterBlePlus = FlutterBluePlus();

  Future<void> startScan({required Duration timeout}) async {
    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (e) {
      print('Lỗi khi quét thiết bị: $e');
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {
      print('Lỗi khi kết nối tới thiết bị: $e');
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      print('Lỗi khi ngắt kết nối với thiết bị: $e');
    }
  }
}
