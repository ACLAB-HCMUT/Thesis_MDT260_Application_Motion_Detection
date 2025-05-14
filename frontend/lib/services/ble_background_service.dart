import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/global_data.dart';
import '../services/submit_data_service.dart';

// Lớp service BLE chạy liên tục trong nền
class BluetoothBackgroundService {
  // Singleton pattern
  static final BluetoothBackgroundService _instance = BluetoothBackgroundService._internal();
  factory BluetoothBackgroundService() => _instance;
  BluetoothBackgroundService._internal();

  // Các thuộc tính của BLE Service
  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  
  StreamSubscription<List<int>>? _notificationSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  final ActivityService _activityService = ActivityService();
  
  // Trạng thái live detection
  bool _isLive = false;
  bool get isLive => _isLive;
  void setLiveStatus(bool status) {
    _isLive = status;
    _liveStatusController.add(status);
  }
  
  // Buffer và trạng thái cho flash data
  List<int> _flashDataBuffer = [];
  bool _flashDataReceived = false;
  List<Map<String, dynamic>> activityData = [];
  List<Map<String, dynamic>> tempDataBuffer = [];
  
  // Stream controllers để thông báo sự kiện ra UI
  final _activityController = StreamController<String>.broadcast();
  Stream<String> get activityStream => _activityController.stream;
  
  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;
  
  final _liveStatusController = StreamController<bool>.broadcast();
  Stream<bool> get liveStatusStream => _liveStatusController.stream;
  
  // Timer để tự động gửi dữ liệu xuống backend theo định kỳ
  Timer? _sendDataTimer;
  
  // Khởi tạo service
  Future<void> initialize() async {
    // Đầu tiên kiểm tra các thiết bị đã kết nối
    await checkBluetoothConnection();
    
    // Khởi tạo timer để gửi dữ liệu định kỳ
    _sendDataTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (tempDataBuffer.isNotEmpty) {
        _processAndSendData();
      }
    });
  }
  
  void dispose() {
    _notificationSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _sendDataTimer?.cancel();
    _activityController.close();
    _connectionController.close();
    _liveStatusController.close();
  }

  // Kiểm tra kết nối Bluetooth
  Future<void> checkBluetoothConnection() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
      if (devices.isNotEmpty) {
        _connectedDevice = devices.first;
        _connectionController.add(true);
        
        // Đăng ký lắng nghe trạng thái kết nối
        _setupConnectionStateListener();
        
        // Đọc flash data
        await readFlashData();
      } else {
        _connectionController.add(false);
      }
    } catch (e) {
      print('Error retrieving connected devices: $e');
      _connectionController.add(false);
    }
  }
  
  // Theo dõi trạng thái kết nối của thiết bị
  void _setupConnectionStateListener() {
    if (_connectedDevice == null) return;
    
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = _connectedDevice!.connectionState.listen((state) {
      print('Connection state changed: $state');
      if (state == BluetoothConnectionState.disconnected) {
        _connectionController.add(false);
        _connectedDevice = null;
      } else if (state == BluetoothConnectionState.connected) {
        _connectionController.add(true);
        // Khi kết nối lại, thiết lập lại notifications
        _setupNotifications();
      }
    });
  }
  
  // Bắt đầu live detection
  Future<void> startLiveDetection() async {
    if (_connectedDevice == null) {
      print('No device connected. Cannot start live detection.');
      return;
    }
    
    setLiveStatus(true);
    await readFlashData();
  }
  
  // Dừng live detection
  void stopLiveDetection() {
    setLiveStatus(false);
    print('Live detection stopped');
  }
  
  // Kết nối tới thiết bị
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _connectionController.add(true);
      
      // Đăng ký lắng nghe trạng thái kết nối
      _setupConnectionStateListener();
      
      print('Connected to device: ${device.name}');
      
      // Đọc flash data khi kết nối
      await readFlashData();
    } catch (e) {
      print('Error connecting to device: $e');
      _connectionController.add(false);
    }
  }
  
  // Ngắt kết nối thiết bị
  Future<void> disconnectDevice() async {
    if (_connectedDevice != null) {
      try {
        stopLiveDetection();
        _notificationSubscription?.cancel();
        _connectionStateSubscription?.cancel();
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _connectionController.add(false);
        print('Device disconnected');
      } catch (e) {
        print('Error disconnecting device: $e');
      }
    }
  }
  
  // Đọc flash data từ thiết bị Bluetooth đã kết nối
  Future<void> readFlashData() async {
    if (_connectedDevice == null) {
      print('No device connected.');
      return;
    }

    try {
      print('Discovering services...');
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      print('Services discovered: ${services.length}');

      _flashDataBuffer.clear();
      _flashDataReceived = false;

      DateTime? lastDataReceived;
      Timer? timeoutTimer;

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == '4d7d1108-ee27-40b2-836c-17505c1044d7') {
            print('Found characteristic for flash data.');

            if (characteristic.properties.notify) {
              print('Setting up notifications for flash data...');
              await characteristic.setNotifyValue(true);
              await _notificationSubscription?.cancel();

              _notificationSubscription = characteristic.lastValueStream.listen((value) {
                DateTime now = DateTime.now();

                // Calculate time between data receptions
                if (lastDataReceived != null) {
                  final timeDiff = now.difference(lastDataReceived!).inMilliseconds;
                  print('Time since last packet: $timeDiff ms');

                  if (timeDiff > 3000) {
                    print('Detected end of flash data (gap > 3000ms). Switching to live mode.');
                    _flashDataReceived = true;
                    _processFlashData(); // Call processing here
                    _setupNotifications(); // Start receiving live data
                    return;
                  }
                }

                // Update reception time
                lastDataReceived = now;

                if (value.isNotEmpty) {
                  try {
                    String asciiData = utf8.decode(value, allowMalformed: true);
                    print('Flash Data Received: $asciiData');
                    _flashDataBuffer.addAll(value);
                  } catch (e) {
                    print('Error decoding data: $e');
                  }
                } else {
                  print('Received empty packet!');
                }
              }, onError: (error) {
                print('Notification stream error: $error');
                _processFlashData();
              });

              // Set a safety timeout in case the flash data transfer gets stuck
              timeoutTimer = Timer(const Duration(seconds: 3), () {
                if (!_flashDataReceived) {
                  print('Flash data timeout reached. Switching to live mode.');
                  _processFlashData();
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error reading flash data: $e');
      _processFlashData();
    }
  }

  void _processFlashData() {
    if (_flashDataReceived) return; // Avoid duplicate calls

    _flashDataReceived = true;
    print('Flash data reception completed. Total bytes: ${_flashDataBuffer.length}');

    // Process and send the flash data
    if (_flashDataBuffer.isNotEmpty) {
      _parseAndSendFlashData();
    }

    // Start receiving live data
    _setupNotifications();
  }

  // Parse flash data and handle activity extraction
  void _parseAndSendFlashData() {
    if (_flashDataBuffer.isEmpty) {
      print('Flash data buffer is empty, nothing to parse');
      return;
    }

    print('Parsing flash data buffer with ${_flashDataBuffer.length} bytes');

    try {
      // Decode the entire buffer into a string
      String decodedData = utf8.decode(_flashDataBuffer, allowMalformed: true);
      print('Decoded flash data: "$decodedData"');

      // Known activity patterns
      List<String> knownPatterns = ['idle', 'walking', 'running', 'stepping'];

      // Find all activity patterns in the string
      for (String pattern in knownPatterns) {
        int startIdx = 0;
        while (true) {
          int patternIdx = decodedData.indexOf(pattern, startIdx);
          if (patternIdx == -1) break; // No more patterns found

          // Extract steps after the pattern
          String remaining = decodedData.substring(patternIdx + pattern.length);
          RegExp numberRegex = RegExp(r'\s*(\d+)');
          Match? match = numberRegex.firstMatch(remaining);

          int steps = 0;
          if (match != null && match.groupCount >= 1) {
            steps = int.tryParse(match.group(1) ?? '0') ?? 0;
          }

          // Handle special pattern for "stepping"
          String activityType = pattern;
          if (activityType == 'stepping') {
            activityType = 'stepping_stair';
          }

          // Add activity to the list
          print('Extracted activity: $activityType with $steps steps');
          activityData.add({
            'activity': activityType,
            'steps': steps,
          });

          // Move start index for the next search
          startIdx = patternIdx + pattern.length;

          // If steps are found, move forward in the string
          if (match != null) {
            startIdx += match.group(0)!.length;
          }
        }
      }

      print('Parsed flash data into ${activityData.length} activity records');
      _sendDataToBackend();
    } catch (e) {
      print('Error parsing flash data: $e');
    }
  }

  // Send parsed data to the backend
  Future<void> _sendDataToBackend() async {
    if (activityData.isEmpty) {
      print('No activities parsed from flash data, nothing to send');
      return;
    }

    try {
      DateTime currentTime = DateTime.now();
      DateTime previousTime = currentTime; // Đặt thời gian hiện tại làm dấu thời gian cho dữ liệu cuối cùng

      // Lặp qua bộ đệm dữ liệu ngược (bắt đầu từ dữ liệu nhận được cuối cùng)
      for (int i = activityData.length - 1; i >= 0; i--) {
        // Trừ đi 2 phút cho mỗi mục trong danh sách
        DateTime adjustedTime = previousTime.subtract(Duration(minutes: (activityData.length - 1 - i) * 2));
        String formattedAdjustedTime = adjustedTime.toIso8601String();

        // Cập nhật dấu thời gian cho mỗi mục
        activityData[i]['timestamp'] = formattedAdjustedTime;
      }

      print("Sending activity data: $activityData");
      GlobalData.updateFromLastActivity(activityData);
      await _activityService.submitActivityData(activityData);

      // After sending, clear the data buffer
      activityData.clear();

      print('Flash data sent to backend successfully.');
    } catch (e) {
      print('Error processing flash data: $e');
    }
  }

  // Thiết lập notifications cho đặc tính BLE
  Future<void> _setupNotifications() async {
    if (_connectedDevice == null) return;

    try {
      List<BluetoothService> services = await _connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            print('Subscribed to characteristic: ${characteristic.uuid}');

            // Cancel existing subscription and listen to new characteristic values
            await _notificationSubscription?.cancel();

            // Listen to characteristic value changes
            _notificationSubscription = characteristic.lastValueStream.listen((value) {
              // Convert List<int> to Uint8List
              Uint8List byteData = Uint8List.fromList(value);

              // Handle received data even if we're not in live mode
              _handleReceivedData(byteData);
            }, onError: (error) {
              print('Notification error: $error');
            });
          }
        }
      }
    } catch (e) {
      print('Error setting up notifications: $e');
    }
  }

  // Xử lý dữ liệu nhận được từ Xiao Sense qua BLE
  void _handleReceivedData(Uint8List value) {
    final timestamp = DateTime.now().toIso8601String();
    print('[$timestamp] Received data from Xiao: $value');

    try {
      // Attempt to decode byte data as UTF-8 (from Uint8List to String)
      String decodedData = utf8.decode(value, allowMalformed: true);

      // Pass the decoded data to parse activity
      _parseActivityFromCharacteristic(decodedData);
    } catch (e) {
      print('Error decoding data: $e');
      // Process raw data if unable to decode as string
      print('Raw received data: $value');
    }
  }

  // Parse activity (e.g., running, idle, etc.) from received data
  void _parseActivityFromCharacteristic(String data) {
    data = data.trim().toLowerCase();
    print("Parsed Data: $data");

    // Known activity patterns
    List<String> knownPatterns = ['idle', 'walking', 'running', 'stepping'];
    String pattern = '';
    int number = 0;

    // Check for known patterns in the message
    for (String known in knownPatterns) {
      if (data.contains(known)) {
        pattern = known;
        int patternIndex = data.indexOf(known);
        String remaining = data.substring(patternIndex + known.length);

        // Extract number after the pattern (steps)
        RegExp numberRegex = RegExp(r'\s*(\d+)');
        Match? match = numberRegex.firstMatch(remaining);
        if (match != null && match.groupCount >= 1) {
          number = int.tryParse(match.group(1) ?? '0') ?? 0;
        }

        break;
      }
    }

    if (pattern.isNotEmpty) {
      // A valid pattern was found
      print('Valid motion data extracted: $pattern $number');

      // If the pattern is 'stepping', change it to 'stepping_stair'
      if (pattern == 'stepping') {
        pattern = 'stepping_stair';
      }

      // Thông báo hoạt động hiện tại để cập nhật UI (nếu đang ở màn hình Live Detection)
      _activityController.add(pattern);

      // Thêm dữ liệu vào buffer tạm thời, bất kể có đang ở chế độ live hay không
      tempDataBuffer.add({
        'timestamp': DateTime.now().toIso8601String(),
        'activity': pattern,
        'steps': number,
      });

      // Kiểm tra nếu có 10 mục trong buffer, gửi xuống backend
      if (tempDataBuffer.length >= 10) {
        _processAndSendData();
      }
    } else {
      print('No valid pattern found in: $data');
    }
  }

  // Xử lý và gửi dữ liệu khi có 10 mục đã được thu thập
  Future<void> _processAndSendData() async {
    if (tempDataBuffer.isEmpty) return;

    try {
      // Tạo bản sao của dữ liệu hiện tại
      final dataToSend = List<Map<String, dynamic>>.from(tempDataBuffer);
      
      // Làm trống buffer
      tempDataBuffer.clear();
      
      // Gửi dữ liệu được thu thập xuống backend
      await _activityService.submitActivityData(dataToSend);
      print('Data sent to backend successfully: ${dataToSend.length} records');
      
      // Cập nhật GlobalData nếu cần
      GlobalData.updateFromLastActivity(dataToSend);
    } catch (e) {
      print('Error processing and sending data: $e');
    }
  }
}