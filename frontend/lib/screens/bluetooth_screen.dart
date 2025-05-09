import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/bluetooth_service.dart' as bt_service;
import '../components/device_list_tile.dart';
import 'dart:async'; // Add this import for StreamSubscription

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
  
  // Add these variables to track subscriptions
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _ensureBluetoothIsOn();
    _listenToAdapterState();
  }

  @override
  void dispose() {
    // Cancel all subscriptions when widget is disposed
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    
    // Stop scanning if in progress
    if (_isScanning) {
      FlutterBluePlus.stopScan().catchError((e) => print('Error stopping scan: $e'));
    }
    
    super.dispose();
  }

  Future<void> _ensureBluetoothIsOn() async {
    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      if (mounted) { // Check if widget is still mounted
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
    // Cancel previous subscription if exists
    _adapterStateSubscription?.cancel();
    
    // Create new subscription
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return; // Skip if widget is no longer mounted
      
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

    if (mounted) {
      setState(() {
        _isScanning = true;
        _availableDevices.clear();
      });
    }

    try {
      // Cancel previous subscription if exists
      await _scanResultsSubscription?.cancel();
      
      // Start scan
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      
      // Create new subscription
      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
        if (!mounted) return; // Skip if widget is no longer mounted
        
        for (ScanResult result in results) {
          if (!_availableDevices.contains(result.device) && 
              result.device.platformName.isNotEmpty) {
            setState(() {
              _availableDevices.add(result.device);
            });
          }
        }
      }, onDone: () {
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      }, onError: (e) {
        print('Scan error: $e');
        if (mounted) {
          setState(() {
            _isScanning = false;
          });
        }
      });
      
      // Set a timeout to ensure _isScanning is reset
      Future.delayed(const Duration(seconds: 6), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
          });
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (!mounted) return; // Skip if widget is no longer mounted
    
    setState(() {
      _connectingDevice = device; // Mark this device as connecting
    });

    try {
      await _bluetoothService.connectToDevice(device);
      
      if (!mounted) return; // Check again if widget is still mounted
      
      setState(() {
        _connectedDevice = device;
        _connectingDevice = null; // Device connected, stop showing connecting state
      });
      Navigator.pop(context, device);  // Return the device after a successful connection
      print('Connected to device: ${device.platformName}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _connectingDevice = null; // Stop showing connecting state in case of error
        });
      }
      print('Unable to connect to the device: $e');
    }
  }

  void _disconnectDevice() async {
    if (_connectedDevice != null) {
      await _bluetoothService.disconnectDevice(_connectedDevice!);
      
      if (mounted) {
        setState(() {
          _connectedDevice = null;
        });
      }
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

