import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth_screen.dart';
import 'dart:async';
import 'dart:convert';

import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';
import '../services/submit_data_service.dart';
import 'dart:typed_data';
import '../models/global_data.dart';

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  _LiveDetectionScreenState createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> {
  BluetoothDevice? _connectedDevice;
  String _currentActivity = ''; // Default activity
  StreamSubscription<List<int>>? _notificationSubscription;
  Timer? _standStillTimer; // Timer to detect 'Stand still'
  bool _isLive = false; // Check if live data is being received
  List<int> _flashDataBuffer = []; // Buffer for storing flash data
  bool _flashDataReceived =
      false; // Flag to check if flash data is fully received
  List<Map<String, dynamic>> activityData =
      []; // Temporary buffer to hold activity data

  List<Map<String, dynamic>> tempDataBuffer = [];
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentActivity = AppLocalizations.of(context)!.stand_still;
      });
    });
    _checkBluetoothConnection();
  }

  @override
  void dispose() {
    // Cancel all subscriptions and timers
    _notificationSubscription?.cancel();
    _standStillTimer?.cancel();

    // Disconnect from device when screen is disposed
    // _disconnectDevice();

    super.dispose();
  }

  // Disconnect Bluetooth device
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

  // Check Bluetooth connection
  Future<void> _checkBluetoothConnection() async {
    try {
      List<BluetoothDevice> devices = await FlutterBluePlus.connectedDevices;
      if (devices.isNotEmpty && mounted) {
        setState(() {
          _connectedDevice = devices.first;
        });
        _readFlashData(); // Read flash data before starting live detection
      }
    } catch (e) {
      print('Error retrieving connected devices: $e');
    }
  }

  // Start live detection
  Future<void> _startLiveDetection() async {
    if (_connectedDevice == null) {
      final selectedDevice = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BluetoothScreen()),
      );

      // Check if still mounted after returning from navigation
      if (!mounted) return;

      if (selectedDevice != null && selectedDevice is BluetoothDevice) {
        setState(() {
          _connectedDevice = selectedDevice;
          _isLive = true;
        });
        _readFlashData(); // Read flash data before receiving other data
      }
    } else {
      if (mounted) {
        setState(() {
          _isLive = true;
        });
      }
      _readFlashData(); // If already connected, immediately read flash data
    }
  }

  // Set up notifications for BLE characteristics
  Future<void> _setupNotifications() async {
    if (_connectedDevice == null || !mounted) return;

    try {
      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            print('Subscribed to characteristic: ${characteristic.uuid}');

            // Cancel existing subscription and listen to new characteristic values
            await _notificationSubscription?.cancel();

            // Listen to characteristic value changes
            _notificationSubscription =
                characteristic.lastValueStream.listen((value) {
              if (mounted) {
                // Convert List<int> to Uint8List
                Uint8List byteData = Uint8List.fromList(value);

                // Pass the converted Uint8List to handle received data
                _handleReceivedData(byteData); // Handle received data
              }
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

  // Read flash data from the connected Bluetooth device
  Future<void> _readFlashData() async {
    if (_connectedDevice == null || !mounted) {
      print('No device connected or widget unmounted.');
      return;
    }

    try {
      print('Discovering services...');
      List<BluetoothService> services =
          await _connectedDevice!.discoverServices();
      print('Services discovered: ${services.length}');

      _flashDataBuffer.clear();
      _flashDataReceived = false;

      DateTime? lastDataReceived;
      Timer? timeoutTimer;

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() ==
              '4d7d1108-ee27-40b2-836c-17505c1044d7') {
            print('Found characteristic for flash data.');

            if (characteristic.properties.notify) {
              print('Setting up notifications...');
              await characteristic.setNotifyValue(true);
              await _notificationSubscription?.cancel();

              _notificationSubscription =
                  characteristic.lastValueStream.listen((value) {
                if (!mounted) return;

                DateTime now = DateTime.now();

                // Calculate time between data receptions
                if (lastDataReceived != null) {
                  final timeDiff =
                      now.difference(lastDataReceived!).inMilliseconds;
                  print('Time since last packet: $timeDiff ms');

                  if (timeDiff > 3000) {
                    print(
                        'Detected end of flash data (gap > 3000ms). Switching to live mode.');
                    _flashDataReceived = true;
                    _processFlashData(); // Call processing here
                    _startReceivingDataFromXiao();
                    _notificationSubscription?.cancel();
                    return;
                  }
                }

                // Update reception time
                lastDataReceived = now;

                if (value.isNotEmpty) {
                  try {
                    String asciiData = utf8.decode(value, allowMalformed: true);
                    print('Data Received: $asciiData');
                    _flashDataBuffer.addAll(value);
                  } catch (e) {
                    print('Error decoding data: $e');
                  }
                } else {
                  print('Received empty packet!');
                }
              }, onError: (error) {
                print('Notification stream error: $error');
                _processFlashData(); // Call processing on error
              }, onDone: () {
                print('Notification stream closed.');
                _processFlashData(); // Call processing on done
              });

              // Set a safety timeout in case the flash data transfer gets stuck
              timeoutTimer = Timer(const Duration(seconds: 3), () {
                if (mounted && !_flashDataReceived) {
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
      _processFlashData(); // Call processing in case of error
    }
  }

  void _processFlashData() {
    if (_flashDataReceived) return; // Avoid duplicate calls

    _flashDataReceived = true;
    print(
        'Flash data reception completed. Total bytes: ${_flashDataBuffer.length}');

    // Process and send the flash data
    if (_flashDataBuffer.isNotEmpty) {
      _parseAndSendFlashData(); // Call parsing and sending
    }

    // Start receiving live data
    _startReceivingDataFromXiao();
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
      if (activityData.isEmpty) {
        print('No activities parsed from flash data, nothing to send');
        return;
      }

      DateTime currentTime = DateTime.now();
      DateTime previousTime =
          currentTime; // Đặt thời gian hiện tại làm dấu thời gian cho dữ liệu cuối cùng

      // Lặp qua bộ đệm dữ liệu ngược (bắt đầu từ dữ liệu nhận được cuối cùng)
      for (int i = activityData.length - 1; i >= 0; i--) {
        // Trừ đi 2 phút cho mỗi mục trong danh sách
        DateTime adjustedTime = previousTime
            .subtract(Duration(minutes: (activityData.length - 1 - i) * 2));
        String formattedAdjustedTime = adjustedTime.toIso8601String();

        // Cập nhật dấu thời gian cho mỗi mục
        activityData[i]['timestamp'] = formattedAdjustedTime;
      }

      print("Sending activity data: $activityData");
      GlobalData.updateFromLastActivity(activityData);
      await _activityService.submitActivityData(activityData);

      // After sending, clear the data buffer
      activityData.clear();
      _flashDataReceived = false;

      print('Flash data sent to backend successfully.');
    } catch (e) {
      print('Error processing flash data: $e');
    }
  }

  // Start receiving live data from Xiao after flash data is received
  Future<void> _startReceivingDataFromXiao() async {
    if (_flashDataReceived && mounted) {
      print('Flash data received. Starting live detection...');
      await _setupNotifications();
    }
  }

  // Handle data received from Xiao Sense via BLE
  void _handleReceivedData(Uint8List value) {
    if (!mounted) return;

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
    if (!mounted) return;

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

      // Update the current activity based on the pattern
      if (mounted) {
        setState(() {
          if (pattern == "running") {
            _currentActivity = AppLocalizations.of(context)!.running;
          } else if (pattern == "idle") {
            _currentActivity = AppLocalizations.of(context)!.stand_still;
          } else if (pattern == "walking") {
            _currentActivity = AppLocalizations.of(context)!.walking;
          } else if (pattern == "stepping_stair") {
            _currentActivity = AppLocalizations.of(context)!.stepping_stairs;
          } else {
            _currentActivity = AppLocalizations.of(context)!.stand_still;
          }
        });
      }

      // Add the data to the temporary array
      tempDataBuffer.add({
        'timestamp': DateTime.now().toIso8601String(),
        'activity': pattern,
        'steps': number,
      });

      // Check if we have 10 entries in the buffer, if so send to backend
      if (tempDataBuffer.length >= 10) {
        _processAndSendData();
      }
    } else {
      print('No valid pattern found in: $data');
    }
  }

  // Process and send the data when 10 entries have been collected
  Future<void> _processAndSendData() async {
    if (tempDataBuffer.isEmpty || !mounted) return;

    try {
      // Send the collected data to the backend
      await _activityService.submitActivityData(tempDataBuffer);

      // After successfully sending the data, clear the buffer
      tempDataBuffer.clear();
      print('Data sent to backend successfully.');
    } catch (e) {
      print('Error processing and sending data: $e');
    }
  }

  // Stop live detection when not needed
  void _stopLiveDetection() {
    if (!mounted) return;

    setState(() {
      _isLive = false;
      _currentActivity = 'Stand still';
    });
    _notificationSubscription?.cancel();
    print('Live detection stopped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.live_detection,
          style: TextStyle(
            fontSize: 18, // Đặt kích thước chữ tiêu đề là 20
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bluetooth_disabled,
              size: 28, // Đặt kích thước biểu tượng là 28
            ),
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
                    Text(
                      AppLocalizations.of(context)!.live_motion_detection,
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
