import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_screen.dart';
import 'dart:async';

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  _LiveDetectionScreenState createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> {
  BluetoothDevice? _connectedDevice;
  String _currentActivity = 'Unknown';
  StreamSubscription<List<int>>? _notificationSubscription;
  List<FlSpot> _dataPoints = [];
  double _currentX = 0.0;
  bool _isConnecting = false;
  String _connectionStatus = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _checkBluetoothConnection();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _disconnectDevice();
    super.dispose();
  }

  Future<void> _disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        print('Device disconnected');
      } catch (e) {
        print('Error disconnecting device: $e');
      }
    }
  }

  Future<void> _checkBluetoothConnection() async {
    try {
      setState(() {
        _isConnecting = true;
        _connectionStatus = 'Checking connected devices...';
      });

      List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
      if (devices.isNotEmpty) {
        setState(() {
          _connectedDevice = devices.first;
          _connectionStatus = 'Connected to ${_connectedDevice!.name}';
        });
        _setupNotifications();
      } else {
        setState(() {
          _connectionStatus = 'No devices connected';
        });
      }
    } catch (e) {
      print('Error retrieving connected devices: $e');
      setState(() {
        _connectionStatus = 'Error retrieving devices';
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _startLiveDetection() async {
    if (_connectedDevice == null) {
      print('Device not connected, navigating to BluetoothScreen.');
      final selectedDevice = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BluetoothScreen()),
      );
      if (selectedDevice != null && selectedDevice is BluetoothDevice) {
        setState(() {
          _connectedDevice = selectedDevice;
          _connectionStatus = 'Connected to ${_connectedDevice!.name}';
        });
        _setupNotifications();
      } else {
        setState(() {
          _connectionStatus = 'No device selected';
        });
      }
    } else {
      // If already connected, ensure notifications are set up
      _setupNotifications();
    }
  }

  Future<void> _setupNotifications() async {
    if (_connectedDevice == null) return;

    try {
      setState(() {
        _connectionStatus = 'Discovering services...';
      });

      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            print('Subscribed to characteristic: ${characteristic.uuid}');

            // Cancel any existing subscription
            await _notificationSubscription?.cancel();

            // Listen to the characteristic's value stream
            _notificationSubscription = characteristic.value.listen((value) {
              if (mounted) {
                _handleReceivedData(value);
              }
            });
            setState(() {
              _connectionStatus = 'Listening for data...';
            });
          }
        }
      }
    } catch (e) {
      print('Error setting up notifications: $e');
      setState(() {
        _connectionStatus = 'Error setting up notifications';
      });
    }
  }

  void _handleReceivedData(List<int> value) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] Received data: $value');

    final newActivity = _parseActivityFromCharacteristic(value);
    if (newActivity != _currentActivity) {
      setState(() {
        _currentActivity = newActivity;
      });
      print('Activity updated to: $_currentActivity');
    }

    double intensity = _parseIntensityFromCharacteristic(value);
    _addDataPoint(intensity);
  }

  String _parseActivityFromCharacteristic(List<int> value) {
    String data = String.fromCharCodes(value).trim().toLowerCase();
    switch (data) {
      case 'walking':
        return 'Walking';
      case 'running':
        return 'Running';
      case 'goingstair':
        return 'Going Stairs';
      default:
        return 'Unknown';
    }
  }

  double _parseIntensityFromCharacteristic(List<int> value) {
    try {
      String data = String.fromCharCodes(value).trim();
      return double.parse(data);
    } catch (e) {
      print('Error parsing intensity: $e');
      return 0.0;
    }
  }

  void _addDataPoint(double y) {
    setState(() {
      _dataPoints.add(FlSpot(_currentX, y));
      _currentX += 1.0;

      // Keep only the latest 10 data points
      if (_dataPoints.length > 10) {
        _dataPoints.removeAt(0);
        _dataPoints = _dataPoints
            .map((spot) => FlSpot(spot.x - 1.0, spot.y))
            .toList();
        _currentX -= 1.0;
      }
    });
    print('Added data point: (${_currentX.toStringAsFixed(1)}, $y)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Text(
              'Status: $_connectionStatus',
              style: TextStyle(
                fontSize: 16,
                color: _connectionStatus.contains('Error') ||
                        _connectionStatus.contains('No')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity Indicators
                  const Text(
                    'Live Motion Detection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActivityColumn(Icons.directions_walk, 'Walking'),
                      _buildActivityColumn(Icons.directions_run, 'Running'),
                      _buildActivityColumn(Icons.stairs, 'Going Stairs'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Real-Time Chart
                  const Text(
                    'Acceleration Intensity Over Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                if (value % 2 == 0) {
                                  return Text('${value.toInt()}s');
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: const Color(0xff37434d),
                            width: 1,
                          ),
                        ),
                        minX: _dataPoints.isNotEmpty ? _dataPoints.first.x : 0,
                        maxX: _dataPoints.isNotEmpty ? _dataPoints.last.x : 10,
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _dataPoints,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Start Live Button
            Center(
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _startLiveDetection,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Start Live'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityColumn(IconData icon, String activity) {
    bool isActive = _currentActivity.toLowerCase() ==
        activity.toLowerCase().replaceAll(' ', '');
    return Column(
      children: [
        Icon(
          icon,
          size: 40,
          color: isActive ? Colors.blue : Colors.grey,
        ),
        const SizedBox(height: 8),
        Text(
          isActive ? activity : 'Idle',
          style: TextStyle(
            fontSize: 16,
            color: isActive ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
