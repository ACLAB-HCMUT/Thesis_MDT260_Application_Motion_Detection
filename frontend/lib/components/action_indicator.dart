import 'package:flutter/material.dart';

class ActionIndicator extends StatelessWidget {
  final String status;

  const ActionIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: status == 'Yên tĩnh' ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            status == 'Yên tĩnh' ? Icons.check_circle : Icons.warning,
            color: Colors.white,
          ),
          SizedBox(width: 8.0),
          Text(
            status,
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
