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
  BluetoothDevice? _connectingDevice; // Track the device being connected

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
          content: const Text('Bluetooth is off. Please turn on Bluetooth.'),
          action: SnackBarAction(
            label: 'TURN ON',
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
      print('Bluetooth connection permission denied');
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
      print('Bluetooth connection permission not granted');
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
    setState(() {
      _connectingDevice = device; // Mark this device as connecting
    });

    try {
      await _bluetoothService.connectToDevice(device);
      setState(() {
        _connectedDevice = device;
        _connectingDevice = null; // Device connected, stop showing connecting state
      });
      Navigator.pop(context, device);  // Return the device after a successful connection
      print('Connected to device: ${device.platformName}');
    } catch (e) {
      setState(() {
        _connectingDevice = null; // Stop showing connecting state in case of error
      });
      print('Unable to connect to the device: $e');
    }
  }

  void _disconnectDevice() async {
    if (_connectedDevice != null) {
      await _bluetoothService.disconnectDevice(_connectedDevice!);
      setState(() {
        _connectedDevice = null;
      });
      print('Disconnected from device');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Connection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_connectedDevice != null) ...[
              Text(
                "Connected to: ${_connectedDevice!.platformName}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _disconnectDevice,
                child: const Text("Disconnect"),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _startScan,
                child: Text(_isScanning ? "Scanning..." : "Scan for Devices"),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = _availableDevices[index];
                    return DeviceListTile(
                      device: device,
                      isConnecting: _connectingDevice == device, // Show "Connecting" for this device
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
