import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

/// Design-system text field: label above the box, white fill, 1px haze
/// border that turns leaf-green on focus, 12px radius.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hintText,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.showCounter = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String? label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  /// Shows the "22/100" counter used by the Edit message screen.
  final bool showCounter;
  final AutovalidateMode autovalidateMode;
  final TextInputAction? textInputAction;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.label(color: AppColors.ink)),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscured,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          autovalidateMode: widget.autovalidateMode,
          textInputAction: widget.textInputAction,
          cursorColor: AppColors.forestGreen,
          style: AppTextStyles.body(color: AppColors.ink),
          buildCounter: widget.showCounter
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) =>
                  Padding(
                    padding: EdgeInsets.only(top: 6.h, right: 2.w),
                    child: Text(
                      '$currentLength/${maxLength ?? 0}',
                      style: AppTextStyles.caption(),
                    ),
                  )
              : (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) =>
                  null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.body(color: AppColors.mist),
            filled: true,
            fillColor: AppColors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 15.h,
            ),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 10.w),
                    child: widget.prefixIcon,
                  ),
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.isPassword
                ? IconButton(
                    splashRadius: 20,
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20.sp,
                      color: AppColors.mist,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
            border: _border(AppColors.haze),
            enabledBorder: _border(AppColors.haze),
            focusedBorder: _border(AppColors.leafGreen),
            errorBorder: _border(AppColors.alertRed),
            focusedErrorBorder: _border(AppColors.alertRed),
            errorStyle: AppTextStyles.caption(color: AppColors.alertRed),
          ),
        ),
      ],
    );
  }
}

/// Rounded search box used by the "Search app" screen.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      cursorColor: AppColors.forestGreen,
      style: AppTextStyles.body(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body(color: AppColors.mist),
        filled: true,
        fillColor: AppColors.fog,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        prefixIcon: Icon(Icons.search_rounded, size: 20.sp, color: AppColors.mist),
        prefixIconConstraints: BoxConstraints(minWidth: 42.w, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Inline "or" divider between the form and the alternative actions.
class AppLabelledDivider extends StatelessWidget {
  const AppLabelledDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.haze)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(label, style: AppTextStyles.label(color: AppColors.mist)),
        ),
        const Expanded(child: Divider(color: AppColors.haze)),
      ],
    );
  }
}
