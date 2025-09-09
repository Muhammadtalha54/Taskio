// import 'package:flutter/material.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

// class AlarmScreen extends StatefulWidget {
//   final String taskTitle;

//   const AlarmScreen({super.key, required this.taskTitle});

//   @override
//   State<AlarmScreen> createState() => _AlarmScreenState();
// }

// class _AlarmScreenState extends State<AlarmScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Start ringing
//     FlutterRingtonePlayer.play(
//       android: AndroidSounds.alarm,
//       looping: true,
//       volume: 1.0,
//       asAlarm: true,
//     );
//   }

//   @override
//   void dispose() {
//     FlutterRingtonePlayer.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.red[900],
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Task Reminder',
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               widget.taskTitle,
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 50),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.red,
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () {
//                 FlutterRingtonePlayer.stop(); // stop alarm
//                 Navigator.pop(context);
//               },
//               child: Text(
//                 'STOP',
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
