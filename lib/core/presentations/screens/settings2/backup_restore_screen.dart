import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/ui/ui.dart';

/// Back up the saved protections, or restore them from the last backup.
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  static const String _keyBackup = 'protections_backup';
  static const String _keyBackupAt = 'protections_backup_at';

  bool _isWorking = false;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    _loadBackupDate();
  }

  Future<void> _loadBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBackupAt);
    if (mounted && raw != null) {
      setState(() => _lastBackup = DateTime.tryParse(raw));
    }
  }

  Future<void> _backup() async {
    setState(() => _isWorking = true);

    try {
      final limits = await AppLimitStorageService.instance.getAppLimits();
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      await prefs.setString(
        _keyBackup,
        jsonEncode(limits.map((l) => l.toJson()).toList()),
      );
      await prefs.setString(_keyBackupAt, now.toIso8601String());

      if (!mounted) return;
      setState(() => _lastBackup = now);
      _notify(context.l10n.backupCreated(limits.length));
    } catch (e) {
      if (mounted) _notify('${context.l10n.error}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isWorking = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyBackup);

      if (raw == null || raw.isEmpty) {
        if (mounted) _notify(context.l10n.noBackupFound, isError: true);
        return;
      }

      final list = jsonDecode(raw) as List<dynamic>;
      final limits = list
          .map((e) => AppLimitModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await AppLimitStorageService.instance.saveAppLimits(limits);

      if (mounted) _notify(context.l10n.backupRestored(limits.length));
    } catch (e) {
      if (mounted) _notify('${context.l10n.error}: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _notify(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: AppTextStyles.small(color: AppColors.white)),
        backgroundColor: isError ? AppColors.alertRed : AppColors.forestGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.backupAndRestore),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          /// ---------------- Create backup ----------------
          AppSoftCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppIconBox(
                      size: 44.w,
                      background: AppColors.white,
                      child: AppIcon(Assets.icons.ui.cloudUpload,
                          size: 22.w, color: AppColors.fern),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.createBackup,
                              style: AppTextStyles.h3(color: AppColors.fern)),
                          SizedBox(height: 2.h),
                          Text(
                            l10n.createBackupSubtitle,
                            style: AppTextStyles.small(color: AppColors.fern),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppButton(
                  label: l10n.backUpNow,
                  loading: _isWorking,
                  onPressed: _backup,
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          /// ---------------- Restore backup ----------------
          AppSoftCard(
            color: AppColors.infoBlueSoft,
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppIconBox(
                      size: 44.w,
                      background: AppColors.white,
                      child: AppIcon(Assets.icons.ui.restore,
                          size: 22.w, color: AppColors.infoBlue),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l10n.restoreBackup,
                              style:
                                  AppTextStyles.h3(color: AppColors.infoBlue)),
                          SizedBox(height: 2.h),
                          Text(
                            l10n.restoreBackupSubtitle,
                            style:
                                AppTextStyles.small(color: AppColors.infoBlue),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                AppButton(
                  label: l10n.restore,
                  variant: AppButtonVariant.info,
                  loading: _isWorking,
                  onPressed: _restore,
                ),
              ],
            ),
          ),

          if (_lastBackup != null) ...[
            SizedBox(height: 16.h),
            Center(
              child: Text(
                l10n.lastBackup(
                  MaterialLocalizations.of(context)
                      .formatFullDate(_lastBackup!),
                ),
                style: AppTextStyles.caption(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
