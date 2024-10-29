import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ActivityDetectionPage extends StatelessWidget {
  const ActivityDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('YOU ARE RUNNING!'),
          SizedBox(height: 20),
          Lottie.asset(
            'assets/animations/running_animation.json',
            width: 200,
            height: 200,
            fit: BoxFit.fill,
          )
        ],
      ),
    );
  }
}
