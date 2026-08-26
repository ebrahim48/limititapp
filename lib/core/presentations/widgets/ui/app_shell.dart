import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_spacing.dart';
import '../../../constants/app_text_styles.dart';
import 'app_buttons.dart';

/// Back chevron + left-aligned title. Used on every pushed screen.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.showBack = true,
    this.onBack,
    this.actions,
    this.titleStyle,
    this.background,
  });

  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final Color? background;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: background ?? AppColors.scaffoldBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: showBack ? 0 : AppSpacing.screenH,
      leadingWidth: showBack ? 44.w : 0,
      leading: showBack
          ? IconButton(
              padding: EdgeInsets.only(left: 12.w),
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.chevron_left_rounded,
                size: 30.sp,
                color: AppColors.ink,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: title == null
          ? null
          : Text(title!, style: titleStyle ?? AppTextStyles.h3()),
      actions: [
        ...?actions,
        SizedBox(width: 8.w),
      ],
    );
  }
}

/// Large left-aligned page heading used by the tab roots ("Statistics",
/// "Settings") — no back button, optional trailing widget.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h1())),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// White scaffold with a standard horizontal gutter and an optional pinned
/// bottom CTA that sits above the safe area.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomBar,
    this.bottomNavigationBar,
    this.padded = true,
    this.scrollable = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  /// Pinned CTA area at the bottom of the screen.
  final Widget? bottomBar;
  final Widget? bottomNavigationBar;
  final bool padded;
  final bool scrollable;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (padded) {
      content = Padding(padding: AppSpacing.screenPadding, child: content);
    }

    if (scrollable) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppSpacing.bottomSafe),
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.scaffoldBg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      body: SafeArea(top: appBar == null, child: content),
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomBar == null
          ? null
          : Container(
              color: AppColors.scaffoldBg,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                12.h,
                AppSpacing.screenH,
                MediaQuery.of(context).padding.bottom + 12.h,
              ),
              child: bottomBar,
            ),
    );
  }
}

/// Centred illustration + title + description + optional CTA — used by the
/// locked Statistics state, "You're all set!", "Subscription cancelled".
class AppMessageView extends StatelessWidget {
  const AppMessageView({
    super.key,
    required this.title,
    this.description,
    this.illustration,
    this.action,
    this.extra,
  });

  final String title;
  final String? description;
  final Widget? illustration;
  final Widget? action;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (illustration != null) ...[
          Center(child: illustration!),
          SizedBox(height: 28.h),
        ],
        Text(title, textAlign: TextAlign.center, style: AppTextStyles.h2()),
        if (description != null) ...[
          SizedBox(height: 10.h),
          Text(
            description!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body(color: AppColors.slateGreen),
          ),
        ],
        if (extra != null) ...[
          SizedBox(height: 10.h),
          extra!,
        ],
        if (action != null) ...[
          SizedBox(height: 32.h),
          action!,
        ],
      ],
    );
  }
}

/// Bottom-anchored confirmation sheet — "Delete protection?", "Log out?".
Future<T?> showAppConfirmSheet<T>(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  AppButtonVariant confirmVariant = AppButtonVariant.destructive,
  VoidCallback? onConfirm,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.white,
    barrierColor: AppColors.ink.withValues(alpha: 0.45),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            24.h,
            AppSpacing.screenH,
            16.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.h3()),
              if (message != null) ...[
                SizedBox(height: 8.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small(color: AppColors.slateGreen),
                ),
              ],
              SizedBox(height: 20.h),
              AppButton(
                label: confirmLabel,
                variant: confirmVariant,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  onConfirm?.call();
                },
              ),
              SizedBox(height: 10.h),
              AppButton(
                label: cancelLabel,
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
