import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/ui/ui.dart';

/// Help & support hub.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'support@limitit.eu';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.helpAndSupport),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          AppCardList(
            children: [
              AppListRow(
                title: l10n.faq,
                subtitle: l10n.faqSubtitle,
                onTap: () => _openFaq(context),
              ),
              AppListRow(
                title: l10n.contactSupport,
                subtitle: l10n.contactSupportSubtitle,
                onTap: () => _contact(context, l10n.contactSupport),
              ),
              AppListRow(
                title: l10n.reportAProblem,
                subtitle: l10n.reportAProblemSubtitle,
                onTap: () => _contact(context, l10n.reportAProblem),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openFaq(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        final faqs = <List<String>>[
          [l10n.faqQ1, l10n.faqA1],
          [l10n.faqQ2, l10n.faqA2],
          [l10n.faqQ3, l10n.faqA3],
          [l10n.faqQ4, l10n.faqA4],
        ];

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              20.h,
              AppSpacing.screenH,
              20.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.faq, style: AppTextStyles.h3()),
                SizedBox(height: 12.h),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: faqs.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, i) => AppSoftCard(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(faqs[i][0],
                              style: AppTextStyles.h4(color: AppColors.fern)),
                          SizedBox(height: 4.h),
                          Text(
                            faqs[i][1],
                            style:
                                AppTextStyles.small(color: AppColors.slateGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Opens the share sheet pre-filled with the support address so the user can
  /// pick their mail client.
  Future<void> _contact(BuildContext context, String subject) async {
    final title = '${context.l10n.appTitle} — $subject';
    try {
      await Share.share(_supportEmail, subject: title);
    } catch (_) {
      ToastMessageHelper.showToastMessage(_supportEmail, title: subject);
    }
  }
}
