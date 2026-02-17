import 'dart:typed_data';

class AppModel {
  final String name;
  final String icon;
  final String? packageName;
  final Uint8List? appIcon;

  AppModel({
    required this.name,
    required this.icon,
    this.packageName,
    this.appIcon,
  });
}
