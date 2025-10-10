import 'package:get/get.dart';
import 'package:limit_it_app/core/models/app_bock_item.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class SchedulesLimitsController extends GetxController {
  final RxBool isExpanded = true.obs;

  final RxList<AppBlockItem> appBlocks = <AppBlockItem>[
    AppBlockItem(
      name: 'Facebook',
      icon: Assets.icons.facebook,
      usage: '45 mins • 4/10 Opens',
      isEnabled: true.obs,
      startTime: '10:00 PM'.obs,
      endTime: '06:00 AM'.obs,
    ),
    AppBlockItem(
      name: 'YouTube',
      icon: Assets.icons.youtube,
      usage: '45 mins • 4/10 Opens',
      isEnabled: false.obs,
      startTime: '10:00 PM'.obs,
      endTime: '06:00 AM'.obs,
    ),
    AppBlockItem(
      name: 'Snapchat',
      icon: Assets.icons.snapshot,
      usage: '45 min today • 12 Opens',
      isEnabled: true.obs,
      startTime: '10:00 PM'.obs,
      endTime: '06:00 AM'.obs,
    ),
  ].obs;
}
