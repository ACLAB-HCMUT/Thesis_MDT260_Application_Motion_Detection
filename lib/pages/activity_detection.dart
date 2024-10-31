import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// class ActivityDetectionPage extends StatelessWidget {
//   const ActivityDetectionPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Text('YOU ARE RUNNING!'),
//           SizedBox(height: 20),
//           Lottie.asset(
//             'assets/animations/running_animation.json',
//             width: 200,
//             height: 200,
//             fit: BoxFit.fill,
//           )
//         ],
//       ),
//     );
//   }
// }

class ActivityDetectionPage extends StatefulWidget {
  const ActivityDetectionPage({Key? key}) : super(key: key);

  @override
  _ActivityDetectionPageState createState() => _ActivityDetectionPageState();
}

class _ActivityDetectionPageState extends State<ActivityDetectionPage> {
  String _selectedActivity = 'RUNNING';

  final Map<String, String> _animations = {
    'RUNNING': 'assets/animations/running_animation.json',
    'WALKING': 'assets/animations/walking_animation.json',
  };

  final Map<String, Size> _animationSizes = {
    'RUNNING': const Size(200, 200),
    'WALKING': const Size(50, 150),
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            value: _selectedActivity,
            onChanged: (String? newValue) {
              setState(() {
                _selectedActivity = newValue!;
              });
            },
            items:
                _animations.keys.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Text('YOU ARE $_selectedActivity!'),
          SizedBox(height: 20),
          Lottie.asset(
            _animations[_selectedActivity]!,
            width: _animationSizes[_selectedActivity]!.width,
            height: _animationSizes[_selectedActivity]!.height,
            fit: BoxFit.fill,
          )
        ],
      ),
    );
  }
}
