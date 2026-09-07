import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/controllers/settings_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';

/// Privacy policy. The settings API returns the text already stripped of
/// HTML, so it is laid out here as headings, bullets and paragraphs.
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final SettingsController _controller = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    _controller.fetchPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.privacy),
      body: Obx(() {
        if (_controller.isLoadingPrivacyPolicy.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          );
        }

        if (_controller.hasErrorPrivacyPolicy.value) {
          return AppMessageView(
            title: l10n.failedToLoadData,
            action: AppButton(
              label: l10n.retry,
              onPressed: _controller.fetchPrivacyPolicy,
            ),
          );
        }

        final content = _controller.privacyPolicyContent.value.trim();
        if (content.isEmpty) {
          return Center(
            child: Text(
              l10n.noDataAvailable,
              style: AppTextStyles.body(color: AppColors.mist),
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 24.h),
          children: [
            for (final line in _lines(content)) _PolicyLine(text: line),
          ],
        );
      }),
    );
  }

  List<String> _lines(String content) => content
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

/// Renders one line as a heading, a bullet, or body text.
class _PolicyLine extends StatelessWidget {
  const _PolicyLine({required this.text});

  final String text;

  /// "1.1 Information You Provide", "2. Data" — numbered section headings.
  bool get _isHeading => RegExp(r'^\d+(\.\d+)*\.?\s').hasMatch(text);

  bool get _isBullet =>
      text.startsWith('•') || text.startsWith('-') || text.startsWith('*');

  @override
  Widget build(BuildContext context) {
    if (_isBullet) {
      final body = text.replaceFirst(RegExp(r'^[•\-*]\s*'), '');
      return Padding(
        padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 7.h, right: 10.w),
              child: Container(
                width: 5.w,
                height: 5.w,
                decoration: const BoxDecoration(
                  color: AppColors.leafGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Text(
                body,
                style: AppTextStyles.body(color: AppColors.slateGreen),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: _isHeading ? 8.h : 12.h),
      child: Text(
        text,
        style: _isHeading
            ? AppTextStyles.h4()
            : AppTextStyles.body(color: AppColors.slateGreen),
      ),
    );
  }
}
