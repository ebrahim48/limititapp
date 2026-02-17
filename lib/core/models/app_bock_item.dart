import 'package:get/get.dart';

class AppBlockItem {
  final String name;
  final dynamic icon;
  final String usage;
  final RxBool isEnabled;
  final RxString startTime;
  final RxString endTime;
  final String? packageName;

  AppBlockItem({
    required this.name,
    required this.icon,
    required this.usage,
    required this.isEnabled,
    required this.startTime,
    required this.endTime,
    this.packageName,
  });
}
