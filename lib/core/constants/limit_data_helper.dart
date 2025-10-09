import 'package:limit_it_app/core/models/limit_option_model.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LimitDataHelper {
  static final List<LimitOption> limitOptions = [
    LimitOption(
      title: 'Screen time',
      icon: Assets.icons.screentime,
      isPro: false,
    ),
    LimitOption(
      title: 'Schedules',
      icon: Assets.icons.schedules,
      isPro: false,
    ),
    LimitOption(
      title: 'Pin Lock',
      icon: Assets.icons.pinlock,
      isPro: true,
    ),
    LimitOption(
      title: 'Detox Mode',
      icon: Assets.icons.detoxmode,
      isPro: true,
    ),
  ];
}
