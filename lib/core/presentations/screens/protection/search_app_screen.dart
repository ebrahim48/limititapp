import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import '../../widgets/ui/ui.dart';

/// Pick the app to protect. The list is the device's real installed apps
/// (via [AppUsageService]); on iOS / without usage permission it falls back
/// to the popular apps the design shows as suggestions.
class SearchAppScreen extends StatefulWidget {
  const SearchAppScreen({super.key});

  @override
  State<SearchAppScreen> createState() => _SearchAppScreenState();
}

class _SearchAppScreenState extends State<SearchAppScreen>
    with WidgetsBindingObserver {
  static const String _ownPackage = 'com.limitit.digitalbalance';

  final TextEditingController _searchCtrl = TextEditingController();

  List<AppUsageData> _apps = [];
  String _query = '';
  bool _isLoading = true;
  String? _errorMessage;

  /// Shown when the device list is unavailable (iOS, permission denied).
  static const List<_FallbackApp> _fallbackApps = [
    _FallbackApp('Instagram', 'com.instagram.android'),
    _FallbackApp('TikTok', 'com.zhiliaoapp.musically'),
    _FallbackApp('YouTube', 'com.google.android.youtube'),
    _FallbackApp('Facebook', 'com.facebook.katana'),
    _FallbackApp('WhatsApp', 'com.whatsapp'),
    _FallbackApp('X (Twitter)', 'com.twitter.android'),
    _FallbackApp('Snapchat', 'com.snapchat.android'),
  ];

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
    if (mounted) setState(() => _isLoading = true);

    try {
      if (!Platform.isAndroid) {
        if (!mounted) return;
        setState(() {
          _apps = [];
          _isLoading = false;
          _errorMessage = null;
        });
        return;
      }

      final service = Get.find<AppUsageService>();
      var hasPermission = await service.hasPermission();
      if (!hasPermission) hasPermission = await service.requestPermission();

      if (!hasPermission) {
        if (!mounted) return;
        setState(() {
          _apps = [];
          _isLoading = false;
          _errorMessage = context.l10n.usageAccessNeeded;
        });
        return;
      }

      final all = await service.getAllInstalledApps();
      final seen = <String>{};
      final unique = all.where((app) {
        final pkg = app.packageName.trim();
        if (pkg == _ownPackage || seen.contains(pkg)) return false;
        seen.add(pkg);
        return true;
      }).toList()
        ..sort((a, b) => b.usageTimeMs.compareTo(a.usageTimeMs));

      if (!mounted) return;
      setState(() {
        _apps = unique;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  List<_AppEntry> get _visibleApps {
    final entries = _apps.isNotEmpty
        ? _apps
            .map((a) => _AppEntry(
                  name: a.name,
                  packageName: a.packageName,
                  icon: a.icon,
                  subtitle: '${a.usageString} · ${a.openCount}',
                ))
            .toList()
        : _fallbackApps
            .map((a) => _AppEntry(name: a.name, packageName: a.packageName))
            .toList();

    if (_query.trim().isEmpty) return entries;

    final q = _query.trim().toLowerCase();
    return entries.where((e) => e.name.toLowerCase().contains(q)).toList();
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hintText: l10n.searchForAnApp,
            onChanged: (value) => setState(() => _query = value),
          ),
          SizedBox(height: 20.h),

          if (_errorMessage != null) ...[
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
                      _errorMessage!,
                      style: AppTextStyles.small(color: AppColors.warmText),
                    ),
                  ),
                  GestureDetector(
                    onTap: _loadApps,
                    child: Text(
                      l10n.retry,
                      style: AppTextStyles.label(color: AppColors.warmText)
                          .copyWith(fontWeight: AppFont.semiBold),
                    ),
                  ),
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
    context.pushReplacementNamed(
      AppRoutes.protectionEditorScreen,
      extra: {
        'selectedApp': SelectedAppInfo(
          packageName: app.packageName,
          appName: app.name,
          appIcon: app.icon,
        ),
      },
    );
  }
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

class _FallbackApp {
  const _FallbackApp(this.name, this.packageName);
  final String name;
  final String packageName;
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
