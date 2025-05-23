import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/theme_notifier.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<List<BluetoothDevice>>? _connectedDevicesFuture;

  @override
  void initState() {
    super.initState();
    _connectedDevicesFuture =
        _getConnectedDevices(); // Initialize the connected devices future
  }

  Future<List<BluetoothDevice>> _getConnectedDevices() async {
    // Fetch and return the list of connected Bluetooth devices
    return await FlutterBluePlus.connectedDevices;
  }

  // Function to disconnect all connected devices
  Future<void> _disconnectAllDevices() async {
    final devices = await FlutterBluePlus.connectedDevices;
    for (final device in devices) {
      await device.disconnect();
    }

    // After disconnecting, re-fetch the devices to update the UI
    setState(() {
      _connectedDevicesFuture =
          _getConnectedDevices(); // Trigger UI rebuild with new data
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disconnected from BLE device')),
    );
  }

  // Function to show the confirmation dialog before disconnecting
  Future<void> _showDisconnectConfirmation(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.disconnect_BLE),
        content: Text(AppLocalizations.of(context)!.are_you_sure),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.disconnect),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Proceed to disconnect the devices after confirmation
      await _disconnectAllDevices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<AppLocalizationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.dart_mode),
              trailing: Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                },
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.language),
              trailing: DropdownButton<Locale>(
                value: localeNotifier.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    localeNotifier.setLocale(newLocale);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/uk_flag.png', 
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context)!.english),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: const Locale('vi'),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/vn_flag.png', 
                          width: 30,
                          height: 30,
                        ),
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context)!.vietnamese),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<BluetoothDevice>>(
              future:
                  _connectedDevicesFuture, // Use the updated future for connected devices
              builder: (context, snapshot) {
                String subtitle = AppLocalizations.of(context)!.no_device_connect; 

                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final device = snapshot.data!.first;
                    subtitle =
                        AppLocalizations.of(context)!.connected_device +' ${device.platformName}'; // Show connected device's name
                  }
                }

                return ListTile(
                  title: Text(AppLocalizations.of(context)!.ble_connect),
                  subtitle: Text(subtitle),
                  trailing: const Icon(Icons.bluetooth),
                  onLongPress: () async {
                    // Show confirmation dialog before disconnecting
                    await _showDisconnectConfirmation(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
