import 'package:flutter/material.dart';
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
  String _currentActivity = 'Stand still'; // Mặc định là Stand still
  StreamSubscription<List<int>>? _notificationSubscription;
  Timer? _standStillTimer; // Timer để kiểm tra trạng thái Stand still
  bool _isLive =
      false; // Biến trạng thái để kiểm tra liệu đang nhận dữ liệu hay không

  @override
  void initState() {
    super.initState();
    _checkBluetoothConnection();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _standStillTimer?.cancel(); // Hủy timer khi thoát
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
      setState(() {});

      List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
      if (devices.isNotEmpty) {
        setState(() {
          _connectedDevice = devices.first;
        });
        _setupNotifications();
      } else {
        setState(() {});
      }
    } catch (e) {
      print('Error retrieving connected devices: $e');
      setState(() {});
    } finally {
      setState(() {});
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
        });
        _setupNotifications();
      } else {
        setState(() {});
      }
    } else {
      // If already connected, ensure notifications are set up
      _setupNotifications();
    }
  }

  Future<void> _setupNotifications() async {
    if (_connectedDevice == null) return;

    try {
      setState(() {});

      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            print('Subscribed to characteristic: ${characteristic.uuid}');

            // Cancel any existing subscription
            await _notificationSubscription?.cancel();

            // Listen to the characteristic's value stream
            _notificationSubscription =
                characteristic.lastValueStream.listen((value) {
              if (mounted) {
                _handleReceivedData(value);
              }
            });
            setState(() {});
          }
        }
      }
    } catch (e) {
      print('Error setting up notifications: $e');
      setState(() {});
    }
  }

  // // Phát hiện và lấy thông tin dữ liệu từ bộ nhớ cục bộ của thiết bị
  // Future<void> _getDeviceServices(BluetoothDevice device) async {
  //   try {
  //     // Lấy danh sách các dịch vụ của thiết bị
  //     List<BluetoothService> services = await device.discoverServices();
  //     for (BluetoothService service in services) {
  //       print('Service UUID: ${service.uuid}');
  //       // Lấy đặc tính (Characteristic) từ mỗi dịch vụ
  //       for (BluetoothCharacteristic characteristic
  //           in service.characteristics) {
  //         print('Characteristic UUID: ${characteristic.uuid}');

  //         // Nếu có đặc tính nào lưu trữ dữ liệu (data) trong bộ nhớ cục bộ
  //         if (characteristic.uuid.toString() == 'UUID_CUA_DAC_TINH') {
  //           // Thay 'UUID_CUA_DAC_TINH' bằng UUID của đặc tính bạn cần
  //           List<int> value =
  //               await characteristic.read(); // Đọc giá trị từ đặc tính
  //           print('Dữ liệu từ bộ nhớ cục bộ: $value');
  //           _handleReceivedData(value); // Xử lý dữ liệu nhận được
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Lỗi khi lấy dịch vụ và đặc tính: $e');
  //   }
  // }

  void _handleReceivedData(List<int> value) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] Received data: $value');

    final newActivity = _parseActivityFromCharacteristic(value);
    if (newActivity != _currentActivity) {
      setState(() {
        _currentActivity = newActivity;
      });
    }

    // Đảm bảo khi nhận dữ liệu, _isLive được set là true
    if (!_isLive) {
      setState(() {
        _isLive = true; // Đánh dấu là đang nhận dữ liệu
      });
    }

    // Reset timer mỗi khi nhận được dữ liệu mới
    _resetStandStillTimer();
  }

  String _parseActivityFromCharacteristic(List<int> value) {
    String data = String.fromCharCodes(value).trim().toLowerCase();
    switch (data) {
      case 'walking':
        return 'Walking';
      case 'running':
        return 'Running';
      case 'stair_climbing':
        return 'Going Stairs';
      default:
        return 'Stand still';
    }
  }

  // Hàm reset timer mỗi khi nhận được dữ liệu mới
  void _resetStandStillTimer() {
    _standStillTimer?.cancel(); // Hủy timer cũ
    _standStillTimer = Timer(const Duration(seconds: 10), () {
      setState(() {
        _currentActivity =
            'Stand still'; // Sau 5s không nhận được dữ liệu sẽ tự động hiển thị Stand still
        _isLive =
            false; // Nếu sau 5s không nhận dữ liệu thì dừng live detection
      });
    });
  }

  void _stopLiveDetection() {
    setState(() {
      _isLive = false;
      _currentActivity = 'Stand still'; // Set lại hoạt động khi dừng
    });
    _notificationSubscription?.cancel();
    print('Live detection stopped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Detection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: _disconnectDevice,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Live Motion Detection',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 300,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.blueAccent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 211, 216, 219)
                                .withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentActivity,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _currentActivity == 'Walking'
                              ? const Icon(Icons.directions_walk,
                                  size: 100, color: Colors.blueAccent)
                              : _currentActivity == 'Running'
                                  ? const Icon(Icons.directions_run,
                                      size: 100, color: Colors.blueAccent)
                                  : _currentActivity == 'Going Stairs'
                                      ? const Icon(Icons.stairs,
                                          size: 100, color: Colors.blueAccent)
                                      : const Icon(Icons.accessibility_new,
                                          size: 100, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ClipOval(
                child: Material(
                  color: _isLive
                      ? Colors.red
                      : Colors.green, // Màu thay đổi khi nhận dữ liệu
                  child: InkWell(
                    onTap: _isLive
                        ? _stopLiveDetection
                        : _startLiveDetection, // Đổi chức năng dựa trên trạng thái
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                        child: Icon(
                          _isLive
                              ? Icons.stop
                              : Icons
                                  .play_arrow, // Biểu tượng thay đổi khi nhận dữ liệu
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
