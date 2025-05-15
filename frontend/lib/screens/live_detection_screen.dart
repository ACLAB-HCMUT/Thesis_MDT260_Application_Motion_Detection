import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

import '../l10n/app_localizations.dart';
import '../services/ble_background_service.dart';
import 'bluetooth_screen.dart';

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  _LiveDetectionScreenState createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> with WidgetsBindingObserver {
  // Sử dụng service thay vì các thuộc tính riêng lẻ
  final BluetoothBackgroundService _bleService = BluetoothBackgroundService();
  
  // State cho UI
  String _currentActivity = '';
  bool _isLive = false;
  bool _isFrozen = false; // Thêm biến để theo dõi trạng thái đóng băng của activity
  
  // Các Subscriptions
  StreamSubscription? _activitySubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _liveStatusSubscription;

  @override
  void initState() {
    super.initState();
    
    // Đăng ký theo dõi vòng đời ứng dụng
    WidgetsBinding.instance.removeObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentActivity = AppLocalizations.of(context)!.stand_still;
      });
      
      // Đăng ký lắng nghe các sự kiện
      _setupEventListeners();
      
      // Kiểm tra trạng thái kết nối ban đầu
      _bleService.checkBluetoothConnection();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateUIState();
  }

  void _setupEventListeners() {
    // Lắng nghe sự thay đổi hoạt động
    _activitySubscription = _bleService.activityStream.listen((activity) {
      // Chỉ cập nhật UI khi không trong trạng thái đóng băng
      if (!_isFrozen && mounted) {
        setState(() {
          if (activity == "running") {
            _currentActivity = AppLocalizations.of(context)!.running;
          } else if (activity == "idle") {
            _currentActivity = AppLocalizations.of(context)!.stand_still;
          } else if (activity == "walking") {
            _currentActivity = AppLocalizations.of(context)!.walking;
          } else if (activity == "stepping_stair") {
            _currentActivity = AppLocalizations.of(context)!.stepping_stairs;
          } else {
            _currentActivity = AppLocalizations.of(context)!.stand_still;
          }
        });
      }
    });
    
    // Lắng nghe trạng thái kết nối
    _connectionSubscription = _bleService.connectionStream.listen((connected) {
      if (!connected && mounted) {
        setState(() {
          _isLive = false;
          // Nếu mất kết nối, không đóng băng trạng thái
          _isFrozen = false; 
        });
      }
    });
    
    // Lắng nghe trạng thái live detection
    _liveStatusSubscription = _bleService.liveStatusStream.listen((isLive) {
      if (mounted) {
        setState(() {
          _isLive = isLive;
          // Khi bắt đầu lại live detection, bỏ trạng thái đóng băng
          if (isLive) {
            _isFrozen = false;
          }
        });
      }
    });
  }
  
  void _updateUIState() {
    setState(() {
      _isLive = _bleService.isLive;
      // Nếu không trong trạng thái live, đặt _isFrozen = false để chuẩn bị cho lần tiếp theo
      if (!_isLive) {
        _isFrozen = false;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Khi ứng dụng vào background hoặc resume từ background
    if (state == AppLifecycleState.resumed) {
      // Cập nhật UI khi quay lại ứng dụng
      _bleService.checkBluetoothConnection();
      _updateUIState();
    }
  }

  @override
  void dispose() {
    // Hủy đăng ký theo dõi vòng đời ứng dụng
   WidgetsBinding.instance.removeObserver(this);
    
    // Hủy các subscription
    _activitySubscription?.cancel();
    _connectionSubscription?.cancel();
    _liveStatusSubscription?.cancel();
    
    super.dispose();
  }

  // Bắt đầu live detection
  Future<void> _startLiveDetection() async {
    if (_bleService.connectedDevice == null) {
      final selectedDevice = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BluetoothScreen()),
      );

      // Check if still mounted after returning from navigation
      if (!mounted) return;

      if (selectedDevice != null && selectedDevice is BluetoothDevice) {
        await _bleService.connectToDevice(selectedDevice);
        await _bleService.startLiveDetection();
      }
    } else {
      await _bleService.startLiveDetection();
    }
  }

  // Dừng live detection
  void _stopLiveDetection() {
    // Đặt cờ đóng băng để giữ trạng thái activity hiện tại
    setState(() {
      _isFrozen = true;
    });
    _bleService.stopLiveDetection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.live_detection,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bluetooth_disabled,
              size: 28,
            ),
            onPressed: () => _bleService.disconnectDevice(),
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
                    Text(
                      AppLocalizations.of(context)!.live_motion_detection,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                          _currentActivity == AppLocalizations.of(context)!.walking
                              ? const Icon(Icons.directions_walk,
                                  size: 100, color: Colors.blueAccent)
                              : _currentActivity == AppLocalizations.of(context)!.running
                                  ? const Icon(Icons.directions_run,
                                      size: 100, color: Colors.blueAccent)
                                  : _currentActivity == AppLocalizations.of(context)!.stepping_stairs
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
                  color: _isLive ? Colors.red : Colors.green,
                  child: InkWell(
                    onTap: _isLive ? _stopLiveDetection : _startLiveDetection,
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: Center(
                        child: Icon(
                          _isLive ? Icons.stop : Icons.play_arrow,
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