import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/presentations/screens/permissions/permissions_setup_screen.dart';
import 'package:limit_it_app/core/presentations/widgets/ui/ui.dart';
import 'package:limit_it_app/core/services/app_blocker_service.dart';

/// Makes sure Android can actually enforce a protection before one is saved.
///
/// Blocking runs in the Accessibility service and needs the overlay
/// permission; without them a saved protection silently does nothing. If
/// either is missing the user is asked to grant them, and the result says
/// whether it is now safe to save. Always `true` on iOS, where Screen Time
/// does the enforcing.
Future<bool> ensureBlockingReady(BuildContext context) async {
  if (!Platform.isAndroid) return true;

  final blocker = Get.find<AppBlockerService>();
  if (await blocker.hasAllPermissions()) {
    await _startMonitoringIfNeeded(blocker);
    return true;
  }
  if (!context.mounted) return false;

  final l10n = context.l10n;
  var wantsSetup = false;
  await showAppConfirmSheet<void>(
    context,
    title: l10n.permissionsRequired,
    message: l10n.toBlockAppsGrantPermissions,
    confirmLabel: l10n.grantPermissions,
    cancelLabel: l10n.cancel,
    confirmVariant: AppButtonVariant.primary,
    onConfirm: () => wantsSetup = true,
  );
  if (!wantsSetup || !context.mounted) return false;

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const PermissionsSetupScreen(popOnFinish: true),
    ),
  );

  // Back from setup — by its button or the back arrow — check for real.
  if (!await blocker.hasAllPermissions()) return false;
  await _startMonitoringIfNeeded(blocker);
  return true;
}

Future<void> _startMonitoringIfNeeded(AppBlockerService blocker) async {
  if (!await blocker.isMonitoringActive()) await blocker.startMonitoring();
}
