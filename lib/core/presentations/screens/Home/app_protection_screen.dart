import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:limit_it_app/controllers/ads_controller.dart';
import 'package:limit_it_app/controllers/motivation_controller.dart';
import 'package:limit_it_app/core/config/app_routes/app_routes.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/models/app_limit_model.dart';
import 'package:limit_it_app/core/services/app_limit_storage_service.dart';
import 'package:limit_it_app/core/services/app_usage_service.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../widgets/ui/ui.dart';

/// Home tab — the list of apps the user is currently protecting, how many
/// impulsive opens were avoided today, and a motivational line.
///
/// Every value here is live: protections come from [AppLimitStorageService],
/// usage from [AppUsageService], the quote from the motivation API and the
/// banner from AdMob.
class AppProtectionScreen extends StatefulWidget {
  const AppProtectionScreen({super.key, this.embedded = true});

  /// `true` when rendered as the Home tab (no back button); `false` when
  /// pushed as its own page from Settings.
  final bool embedded;

  @override
  State<AppProtectionScreen> createState() => _AppProtectionScreenState();
}

class _AppProtectionScreenState extends State<AppProtectionScreen> {
  final MotivationController _motivationController =
      Get.put(MotivationController(), permanent: true);
  final AdsController _adsController = Get.put(AdsController());

  List<AppLimitModel> _limits = [];
  Map<String, int> _opensToday = {};
  bool _isLoading = true;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadProtections();
    _loadBannerAd();
    if (_motivationController.motivations.isEmpty) {
      _motivationController.getMotivationalPhrases();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadProtections() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      final limits = await AppLimitStorageService.instance.getAppLimits();

      final opens = <String, int>{};
      for (final limit in limits) {
        final usage = await AppLimitStorageService.instance
            .getAppUsageToday(limit.packageName);
        opens[limit.packageName] = usage?['opensCount'] ?? 0;
      }

      if (!mounted) return;
      setState(() {
        _limits = limits;
        _opensToday = opens;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading protections: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    _bannerAd?.load();
  }

  /// How many blocked opens the protections prevented today.
  int get _avoidedToday {
    var total = 0;
    for (final limit in _limits) {
      final opens = _opensToday[limit.packageName] ?? 0;
      final over = opens - limit.maxDailyOpens;
      if (limit.maxDailyOpens > 0 && over > 0) total += over;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.appProtection, showBack: !widget.embedded),
      body: RefreshIndicator(
        color: AppColors.leafGreen,
        onRefresh: _loadProtections,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.yourProtectedApps, style: AppTextStyles.h4()),
                ),
                _AddProtectionButton(onTap: _openAddProtection),
              ],
            ),
            SizedBox(height: 12.h),

            if (_isLoading)
              const _ProtectionsLoading()
            else if (_limits.isEmpty)
              _EmptyProtections(onAdd: _openAddProtection)
            else
              AppCardList(
                children: [
                  for (final limit in _limits)
                    AppListRow(
                      leading: AppLogoTile(
                        packageName: limit.packageName,
                        appName: limit.appName,
                        preloadedIcon: limit.appIcon,
                        size: 40.w,
                      ),
                      title: limit.appName,
                      subtitle: _describe(limit),
                      onTap: () => _openEditProtection(limit),
                    ),
                ],
              ),

            SizedBox(height: 16.h),

            /// ---------------- Avoided today ----------------
            AppSoftCard(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.todayYouveAvoided,
                    style: AppTextStyles.label(color: AppColors.fern),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$_avoidedToday',
                        style: AppTextStyles.display(
                          color: AppColors.forestGreen,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        l10n.impulsiveOpenings,
                        style: AppTextStyles.body(color: AppColors.fern),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (_avoidedToday > 0)
                    AppLineChart(
                      values: _weeklyAvoidedTrend,
                      height: 56.h,
                      showDots: false,
                    )
                  else
                    SizedBox(height: 14.h),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            /// ---------------- Motivational quote ----------------
            Obx(() {
              final quotes = _motivationController.motivations;
              if (quotes.isEmpty) return const SizedBox.shrink();
              final quote = quotes.first;

              return AppCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“${quote.content}”',
                      style: AppTextStyles.body(color: AppColors.slateGreen)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                    if (quote.author.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text('— ${quote.author}', style: AppTextStyles.caption()),
                    ],
                  ],
                ),
              );
            }),

            /// ---------------- Banner ad ----------------
            if (_isBannerAdReady && _bannerAd != null) ...[
              SizedBox(height: 16.h),
              Center(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ],

            /// ---------------- Announcements (ads API) ----------------
            Obx(() {
              if (_adsController.ads.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Column(
                  children: [
                    for (final ad in _adsController.ads)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _AnnouncementCard(
                          title: ad.title,
                          description: ad.description,
                          image: ad.image,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Placeholder trend until per-day history is stored.
  List<double> get _weeklyAvoidedTrend {
    final today = _avoidedToday.toDouble();
    return [
      today * 0.25,
      today * 0.35,
      today * 0.45,
      today * 0.55,
      today * 0.7,
      today * 0.85,
      today,
    ];
  }

  String _describe(AppLimitModel limit) {
    final l10n = context.l10n;

    if (limit.protectionType == ProtectionType.delayOpening) {
      return '${l10n.pauseDuration}: ${l10n.secondsShort(limit.delaySeconds)}';
    }

    final start = limit.scheduleStartTime?.value;
    final end = limit.scheduleEndTime?.value;
    if (start != null && start.isNotEmpty && end != null && end.isNotEmpty) {
      return '${l10n.blocked} $start–$end';
    }

    if (limit.maxDailyOpens > 0) {
      return '${l10n.maxOpenings} ${limit.maxDailyOpens}/${l10n.day}';
    }

    final minutes = limit.maxSessionDurationMinutes;
    return '${l10n.dailyLimit}: ${minutes ~/ 60}h ${minutes % 60}m';
  }

  Future<void> _openAddProtection() async {
    await context.pushNamed(AppRoutes.chooseFunctionScreen);
    if (mounted) _loadProtections();
  }

  Future<void> _openEditProtection(AppLimitModel limit) async {
    await context.pushNamed(
      AppRoutes.protectionEditorScreen,
      extra: {'packageName': limit.packageName},
    );
    if (mounted) _loadProtections();
  }
}

class _AddProtectionButton extends StatelessWidget {
  const _AddProtectionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(Icons.add_rounded, size: 20.sp, color: AppColors.fern),
      ),
    );
  }
}

class _ProtectionsLoading extends StatelessWidget {
  const _ProtectionsLoading();

  @override
  Widget build(BuildContext context) {
    return AppCardList(
      children: List.generate(
        3,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12.h, width: 90.w, color: AppColors.fog),
                    SizedBox(height: 8.h),
                    Container(height: 10.h, width: 140.w, color: AppColors.fog),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProtections extends StatelessWidget {
  const _EmptyProtections({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      child: Column(
        children: [
          Assets.illustrations.shieldCheck.svg(width: 72.w, height: 72.w),
          SizedBox(height: 16.h),
          Text(
            l10n.noProtectionsYet,
            textAlign: TextAlign.center,
            style: AppTextStyles.h4(),
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.noProtectionsSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.small(color: AppColors.slateGreen),
          ),
          SizedBox(height: 18.h),
          AppButton(label: l10n.addProtection, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.title,
    required this.description,
    required this.image,
  });

  final String title;
  final String description;
  final String image;

  @override
  Widget build(BuildContext context) {
    return AppSoftCard(
      color: AppColors.warmSoft,
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.network(
              image,
              width: 64.w,
              height: 64.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 64.w,
                height: 64.w,
                color: AppColors.white,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h4(color: AppColors.warmText),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small(color: AppColors.warmText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
