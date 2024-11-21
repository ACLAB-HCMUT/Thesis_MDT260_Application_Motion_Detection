import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart' as bt_service;
import '../components/device_list_tile.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final bt_service.BluetoothService _bluetoothService = bt_service.BluetoothService();
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;
  final List<BluetoothDevice> _availableDevices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _ensureBluetoothIsOn();
    _listenToAdapterState();
  }

  Future<void> _ensureBluetoothIsOn() async {
    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bluetooth hiện đang tắt. Vui lòng bật Bluetooth.'),
          action: SnackBarAction(
            label: 'BẬT',
            onPressed: () async {
              await FlutterBluePlus.turnOn();
            },
          ),
        ),
      );
    }
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothConnect]?.isDenied ?? true) {
      print('Quyền kết nối Bluetooth bị từ chối');
    }
  }

  void _listenToAdapterState() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        _ensureBluetoothIsOn();
      }
      if (state == BluetoothAdapterState.on) {
        print('Bluetooth is ON');
      } else {
        print('Bluetooth is OFF');
      }
    });
  }

  Future<void> _startScan() async {
    if (!(await Permission.bluetoothConnect.isGranted)) {
      print('Quyền kết nối Bluetooth chưa được cấp');
      return;
    }
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _availableDevices.clear();
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (!_availableDevices.contains(result.device) && result.device.platformName.isNotEmpty) {
          setState(() {
            _availableDevices.add(result.device);
          });
        }
      }
    });

    setState(() {
      _isScanning = false;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await _bluetoothService.connectToDevice(device);
      Navigator.pop(context, device);  // Trả về thiết bị sau khi kết nối thành công
      print('Đã kết nối với thiết bị: ${device.platformName}');
    } catch (e) {
      print('Không thể kết nối với thiết bị: $e');
    }
  }

  void _disconnectDevice() async {
    if (_connectedDevice != null) {
      await _bluetoothService.disconnectDevice(_connectedDevice!);
      setState(() {
        _connectedDevice = null;
      });
      print('Đã ngắt kết nối với thiết bị');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kết nối Bluetooth"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_connectedDevice != null) ...[
              Text(
                "Đã kết nối với: ${_connectedDevice!.platformName}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _disconnectDevice,
                child: const Text("Ngắt kết nối"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _startScan,
                child: Text(_isScanning ? "Đang quét..." : "Quét thiết bị"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = _availableDevices[index];
                    return DeviceListTile(
                      device: device,
                      onTap: () => _connectToDevice(device),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
