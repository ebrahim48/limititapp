import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'custom_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
      {super.key,
      this.title,
      this.showLeading = true,
      this.centerTitle = true,
      this.actions,
      this.titleWidget});

  final String? title;
  final Widget? titleWidget;
  final bool showLeading;
  final bool centerTitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: Colors.black),
      title: title != null && title != ''
          ? CustomText(
            text: title.toString(),
            fontsize: 20.h,
            color: Colors.black,
          )
          : titleWidget,
       actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
