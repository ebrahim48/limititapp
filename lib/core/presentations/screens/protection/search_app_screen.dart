import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/models/protection_draft.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/l10n/app_localizations.dart';
import '../../widgets/ui/ui.dart';
import 'ios_screen_time_view.dart';

/// Why the banner above the list is showing. Resolved to text at build time so
/// the loaders stay free of `BuildContext`.
enum _Notice { usageAccess, limitedDetection, loadFailed }

/// Pick the app to protect.
///
/// Android enumerates every launchable app through [AppUsageService] and
/// protects them one by one.
///
/// iOS cannot do that: Apple exposes no API to list installed apps, read their
/// usage, or draw our own block screen. The only sanctioned route is Screen
/// Time, so on iOS this screen hands over to [IosScreenTimeView], which drives
/// Apple's picker and shield instead of a list of rows.
class SearchAppScreen extends StatefulWidget {
  const SearchAppScreen({super.key, this.protectionType});

  /// Chosen on the function chooser; lands preselected in the editor.
  final ProtectionType? protectionType;

  @override
  State<SearchAppScreen> createState() => _SearchAppScreenState();
}

class _SearchAppScreenState extends State<SearchAppScreen>
    with WidgetsBindingObserver {
  static const String _ownPackage = 'com.limitit.digitalbalance';

  final TextEditingController _searchCtrl = TextEditingController();

  List<_AppEntry> _entries = [];
  String _query = '';
  bool _isLoading = true;
  _Notice? _notice;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-load apps when the user returns from the system settings screen.
    if (state == AppLifecycleState.resumed) _loadApps();
  }

  Future<void> _loadApps() async {
    if (!Platform.isAndroid) return; // iOS renders [IosScreenTimeView] instead.
    if (mounted) setState(() => _isLoading = true);

    try {
      final result = await _loadAndroidApps();

      if (!mounted) return;
      setState(() {
        _entries = result.entries;
        _notice = result.notice;
        _loadError = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _notice = _Notice.loadFailed;
        _loadError = '$e';
      });
    }
  }

  /// Android lists the real launcher. Usage access is not needed for the list
  /// itself — only for the "45 min today · 12 opens" subtitle — so a denied
  /// permission costs the numbers, never the apps.
  Future<_LoadResult> _loadAndroidApps() async {
    final service = Get.find<AppUsageService>();
    final hasUsageAccess = await service.hasPermission();
    final all = await service.getAllInstalledApps();

    final seen = <String>{};
    final unique = all.where((app) {
      final pkg = app.packageName.trim();
      if (pkg == _ownPackage || seen.contains(pkg)) return false;
      seen.add(pkg);
      return true;
    }).toList()
      ..sort((a, b) {
        final byUsage = b.usageTimeMs.compareTo(a.usageTimeMs);
        return byUsage != 0
            ? byUsage
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return _LoadResult(
      entries: [
        for (final app in unique)
          _AppEntry(
            name: app.name,
            packageName: app.packageName,
            icon: app.icon,
            subtitle: hasUsageAccess
                ? '${app.usageString} · ${app.openCount}'
                : null,
          ),
      ],
      notice: hasUsageAccess ? null : _Notice.usageAccess,
    );
  }

  Future<void> _grantUsageAccess() async {
    await Get.find<AppUsageService>().requestPermission();
    await _loadApps();
  }

  List<_AppEntry> get _visibleApps {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _entries;
    return _entries.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  String _noticeText(AppLocalizations l10n) {
    switch (_notice!) {
      case _Notice.usageAccess:
        return l10n.usageAccessNeeded;
      case _Notice.limitedDetection:
        return l10n.appDetectionLimited;
      case _Notice.loadFailed:
        return _loadError ?? l10n.couldNotLoadApps;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final apps = _visibleApps;

    return AppScaffold(
      appBar: AppTopBar(
        title: l10n.searchApp,
        actions: [
          AppTextLink(
            label: l10n.cancel,
            style: AppTextStyles.bodyMedium(color: AppColors.leafGreen),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      // Apple gives us no app list to search, so the whole list UI is
      // replaced rather than left empty.
      body: !Platform.isAndroid
          ? const IosScreenTimeView()
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hintText: l10n.searchForAnApp,
            onChanged: (value) => setState(() => _query = value),
          ),
          SizedBox(height: 20.h),

          if (_notice != null) ...[
            AppSoftCard(
              color: AppColors.warmSoft,
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18.sp, color: AppColors.warmText),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _noticeText(l10n),
                      style: AppTextStyles.small(color: AppColors.warmText),
                    ),
                  ),
                  if (_notice != _Notice.limitedDetection) ...[
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: _notice == _Notice.usageAccess
                          ? _grantUsageAccess
                          : _loadApps,
                      child: Text(
                        _notice == _Notice.usageAccess ? l10n.grant : l10n.retry,
                        style: AppTextStyles.label(color: AppColors.warmText)
                            .copyWith(fontWeight: AppFont.semiBold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          SectionLabel(
            _query.trim().isEmpty ? l10n.suggestions : l10n.results,
          ),

          Expanded(
            child: _isLoading
                ? const _SearchLoading()
                : apps.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noAppsFound,
                          style: AppTextStyles.body(color: AppColors.mist),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 24.h),
                        child: AppCardList(
                          children: [
                            for (final app in apps)
                              AppListRow(
                                leading: AppLogoTile(
                                  packageName: app.packageName,
                                  appName: app.name,
                                  preloadedIcon: app.icon,
                                  size: 40.w,
                                ),
                                title: app.name,
                                subtitle: app.subtitle,
                                onTap: () => _pick(app),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _pick(_AppEntry app) {
    final selected = SelectedAppInfo(
      packageName: app.packageName,
      appName: app.name,
      appIcon: app.icon,
    );

    // Reached through the function chooser: continue into the wizard. Opened
    // on its own (no type picked), fall back to the all-in-one editor.
    final type = widget.protectionType;
    if (type == null) {
      context.pushReplacementNamed(
        AppRoutes.protectionEditorScreen,
        extra: {'selectedApp': selected},
      );
      return;
    }

    // Pushed, not replaced: Back through the wizard must reach the app picker
    // and the function chooser again.
    context.pushNamed(
      AppRoutes.protectionStepScreen,
      extra: ProtectionDraft(app: selected, type: type),
    );
  }
}

class _LoadResult {
  const _LoadResult({required this.entries, this.notice});

  final List<_AppEntry> entries;
  final _Notice? notice;
}

class _AppEntry {
  const _AppEntry({
    required this.name,
    required this.packageName,
    this.icon,
    this.subtitle,
  });

  final String name;
  final String packageName;
  final dynamic icon;
  final String? subtitle;
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    return AppCardList(
      children: List.generate(
        6,
        (_) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.fog,
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              SizedBox(width: 12.w),
              Container(height: 12.h, width: 110.w, color: AppColors.fog),
            ],
          ),
        ),
      ),
    );
  }
}
