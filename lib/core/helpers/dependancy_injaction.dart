import 'package:flutter/services.dart';
import 'package:get/get.dart';


class DependencyInjection implements Bindings {

  DependencyInjection();

  @override
  void dependencies() {
    // Get.lazyPut(() => AuthController(), fenix: true);
    // Get.lazyPut(() => CustomerHomeController(), fenix: true);
    // Get.lazyPut(() => CustomerBookingController(), fenix: true);
    // Get.lazyPut(() => MechanicJobController(), fenix: true);
    // Get.lazyPut(() => CurrentLocationController(), fenix: true);
    // Get.lazyPut(() => LiveLocationChangeController(), fenix: true);
    // Get.lazyPut(() => ChatController(), fenix: true);
  }

  void lockDevicePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}