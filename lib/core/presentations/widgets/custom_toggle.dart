import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:limit_it_app/core/constants/app_colors.dart';

class CustomToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const CustomToggle({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.initialValue;
  }

  void toggle() {
    setState(() {
      isOn = !isOn;
    });
    widget.onChanged?.call(isOn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: isOn ? const Color(0xFF3D3D3D) : const Color(0xFFDDA742),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          curve: Curves.easeInOut,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: isOn ? const Color(0xFFDDA742) : AppColors.textColorFFFFFF,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
