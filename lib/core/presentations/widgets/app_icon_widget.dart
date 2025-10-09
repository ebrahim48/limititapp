import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIconWidget extends StatelessWidget {
  final String appName;
  const AppIconWidget({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (appName) {
      case 'Facebook':
        icon = Icons.facebook;
        color = Colors.blue;
        break;
      case 'Instagram':
        icon = Icons.camera_alt;
        color = Colors.purple;
        break;
      case 'Snapchat':
        icon = Icons.chat;
        color = Colors.yellow;
        break;
      case 'Netflix':
        icon = Icons.play_circle_fill;
        color = Colors.red;
        break;
      case 'TikTok':
        icon = Icons.music_note;
        color = Colors.black;
        break;
      default:
        icon = Icons.apps;
        color = Colors.grey;
    }

    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 16.r),
    );
  }
}
