import 'dart:async';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkController extends GetxController {
  RxBool isConnection = false.obs;
  StreamSubscription<InternetStatus>? interNetConnectionState;

  @override
  void onInit() {
    super.onInit();
    checkInitialConnection(); // Check the initial connection state

    // Listen to connection status changes
    interNetConnectionState = InternetConnection().onStatusChange.listen((event) {
      print("----------------internet : $event");
      isConnection.value = event == InternetStatus.connected;
    });
  }

  Future<void> checkInitialConnection() async {
    isConnection.value = true;
  }

  @override
  void dispose() {
    interNetConnectionState?.cancel();
    super.dispose();
  }
}
