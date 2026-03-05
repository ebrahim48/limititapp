import 'dart:typed_data';

class AppInfo {
  final String name;
  final String icon;
  final String usage;
  final String percentage;
  final Uint8List? appIconBytes; // Real app icon bytes from device

  AppInfo({
    required this.name,
    required this.icon,
    required this.usage,
    required this.percentage,
    this.appIconBytes,
  });
}
