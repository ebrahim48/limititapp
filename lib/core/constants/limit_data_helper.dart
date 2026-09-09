import 'package:flutter/material.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/limit_option_model.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';

class LimitDataHelper {
  static List<LimitOption> limitOptions(BuildContext context) {
    final l10n = context.l10n;
    return [
      LimitOption(
        id: LimitOptionId.screenTime,
        title: l10n.screenTime,
        icon: Assets.icons.screentime,
        isPro: false,
      ),
      LimitOption(
        id: LimitOptionId.schedules,
        title: l10n.schedules,
        icon: Assets.icons.schedules,
        isPro: false,
      ),
      LimitOption(
        id: LimitOptionId.pinLock,
        title: l10n.pinLock,
        icon: Assets.icons.pinlock,
        isPro: true,
      ),
      LimitOption(
        id: LimitOptionId.detoxMode,
        title: l10n.detoxMode,
        icon: Assets.icons.detoxmode,
        isPro: true,
      ),
    ];
  }
}
