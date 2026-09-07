import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/models/protection_draft.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';
import '../../widgets/ui/ui.dart';

/// Last step of the add-protection wizard: confirm what is about to be saved,
/// then write it through [AppLimitStorageService].
class ProtectionReviewScreen extends StatefulWidget {
  const ProtectionReviewScreen({super.key, required this.draft});

  final ProtectionDraft draft;

  @override
  State<ProtectionReviewScreen> createState() => _ProtectionReviewScreenState();
}

class _ProtectionReviewScreenState extends State<ProtectionReviewScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.review, titleStyle: AppTextStyles.h3()),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 100.h),
        children: [
          SizedBox(height: 8.h),
          Center(
            child: AppLogoTile(
              packageName: draft.app.packageName,
              appName: draft.app.appName,
              preloadedIcon: draft.app.appIcon,
              size: 64.w,
              radius: 16.r,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            draft.app.appName,
            textAlign: TextAlign.center,
            style: AppTextStyles.h3(),
          ),
          SizedBox(height: 24.h),

          AppSoftCard(
            color: AppColors.mint,
            padding: EdgeInsets.all(16.w),
            child: _Field(
              label: l10n.protectionTypeLabel,
              value: _typeLabel(l10n),
              valueColor: AppColors.fern,
              labelColor: AppColors.fern,
            ),
          ),
          SizedBox(height: 12.h),

          AppCard(
            padding: EdgeInsets.all(16.w),
            child: _Field(label: l10n.settingLabel, value: _settingLabel(l10n)),
          ),
          SizedBox(height: 12.h),

          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Text(
              _explainer(l10n),
              style: AppTextStyles.small(color: AppColors.mist),
            ),
          ),
        ],
      ),
      bottomBar: AppButton(
        label: l10n.activate,
        loading: _isSaving,
        onPressed: _isSaving ? null : _activate,
      ),
    );
  }

  String _typeLabel(AppLocalizations l10n) => switch (widget.draft.type) {
        ProtectionType.delayOpening => l10n.delayAppOpening,
        ProtectionType.dailyLimit => l10n.dailyTimeLimit,
        ProtectionType.maxOpens => l10n.openingLimit,
        ProtectionType.timeBlock => l10n.timeBlock,
      };

  String _settingLabel(AppLocalizations l10n) {
    final draft = widget.draft;
    switch (draft.type) {
      case ProtectionType.delayOpening:
        return l10n.secondsLong(draft.delaySeconds);
      case ProtectionType.dailyLimit:
        final h = (draft.dailyLimitMinutes ~/ 60).toString().padLeft(2, '0');
        final m = (draft.dailyLimitMinutes % 60).toString().padLeft(2, '0');
        return '${h}h ${m}m';
      case ProtectionType.maxOpens:
        return l10n.openingsPerDayValue(draft.maxOpens);
      case ProtectionType.timeBlock:
        return '${ProtectionDraft.formatTime(draft.blockStart)} – '
            '${ProtectionDraft.formatTime(draft.blockEnd)}';
    }
  }

  String _explainer(AppLocalizations l10n) => switch (widget.draft.type) {
        ProtectionType.delayOpening => l10n.delayExplainer,
        ProtectionType.dailyLimit => l10n.dailyLimitExplainer,
        ProtectionType.maxOpens => l10n.openingLimitExplainer,
        ProtectionType.timeBlock => l10n.timeBlockExplainer,
      };

  Future<void> _activate() async {
    setState(() => _isSaving = true);

    try {
      final service = Get.find<AppLimitStorageService>();
      final limits = await service.getAppLimits();

      // Re-protecting an app replaces its previous rule rather than stacking.
      final existing = limits
          .where((l) => l.packageName == widget.draft.app.packageName)
          .firstOrNull;
      limits.removeWhere(
        (l) => l.packageName == widget.draft.app.packageName,
      );
      limits.add(
        widget.draft.toLimit(
          createdAt: existing?.createdAt,
          customMessage: existing?.customMessage,
        ),
      );

      final saved = await service.saveAppLimits(limits);
      if (!mounted) return;

      if (!saved) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSavingSettings)),
        );
        return;
      }

      context.pushReplacementNamed(
        AppRoutes.protectionSuccessScreen,
        extra: {'appName': widget.draft.app.appName},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.errorSavingSettings}: $e')),
      );
    }
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label(color: labelColor ?? AppColors.mist)
              .copyWith(letterSpacing: 0.6),
        ),
        SizedBox(height: 6.h),
        Text(value, style: AppTextStyles.h4(color: valueColor)),
      ],
    );
  }
}
