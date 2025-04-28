import 'package:flutter/material.dart';
import '../models/mock_data.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(mockNotifications[index]['time']!),
              subtitle: Text(mockNotifications[index]['action']!),
            ),
          );
        },
      ),
    );
  }
}
