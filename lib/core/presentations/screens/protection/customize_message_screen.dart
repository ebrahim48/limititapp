import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:limit_it_app/controllers/motivation_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import '../../widgets/ui/ui.dart';

/// Edit the line shown on the pause screen. Suggestions come from the
/// motivation API, with a built-in set as fallback.
class CustomizeMessageScreen extends StatefulWidget {
  const CustomizeMessageScreen({super.key, this.initialMessage});

  final String? initialMessage;

  @override
  State<CustomizeMessageScreen> createState() => _CustomizeMessageScreenState();
}

class _CustomizeMessageScreenState extends State<CustomizeMessageScreen> {
  static const int _maxLength = 100;

  late final TextEditingController _controller =
      TextEditingController(text: widget.initialMessage ?? '');

  final MotivationController _motivation = Get.put(MotivationController());

  String? _selected;

  static const List<String> _fallbackSuggestions = [
    'Breathe. Focus. Choose.',
    'Discipline is freedom.',
    'Less screen, more life.',
    'Your future is created by what you do today.',
  ];

  @override
  void initState() {
    super.initState();
    if (_motivation.motivations.isEmpty) {
      _motivation.getMotivationalPhrases();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(String text) {
    setState(() {
      _selected = text;
      _controller.text = text;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppTopBar(title: l10n.editMessage),
      resizeToAvoidBottomInset: true,
      bottomBar: AppButton(
        label: l10n.save,
        onPressed: () => context.pop(_controller.text.trim()),
      ),
      body: Obx(() {
        final apiSuggestions =
            _motivation.motivations.map((m) => m.content).toList();
        final suggestions =
            apiSuggestions.isNotEmpty ? apiSuggestions : _fallbackSuggestions;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 110.h),
          children: [
            Text(l10n.message, style: AppTextStyles.label(color: AppColors.ink)),
            SizedBox(height: 8.h),
            AppTextField(
              controller: _controller,
              maxLines: 3,
              maxLength: _maxLength,
              showCounter: true,
              hintText: l10n.messageHint,
              autovalidateMode: AutovalidateMode.disabled,
              onChanged: (value) => setState(() => _selected = value),
            ),

            SizedBox(height: 20.h),

            Text(l10n.suggestions,
                style: AppTextStyles.label(color: AppColors.ink)),
            SizedBox(height: 8.h),

            for (final suggestion in suggestions) ...[
              AppSelectableTile(
                selected: _selected == suggestion,
                onTap: () => _apply(suggestion),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                trailing: Icon(
                  Icons.add_rounded,
                  size: 20.sp,
                  color: _selected == suggestion
                      ? AppColors.leafGreen
                      : AppColors.mist,
                ),
                child: Text(
                  suggestion,
                  style: AppTextStyles.bodyMedium(
                    color: _selected == suggestion
                        ? AppColors.fern
                        : AppColors.ink,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ],
        );
      }),
    );
  }
}
