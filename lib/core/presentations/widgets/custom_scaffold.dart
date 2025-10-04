// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import '../../core/constants/app_colors.dart';
//
// class CustomScaffold extends StatelessWidget {
//   const CustomScaffold(
//       {super.key,
//       this.appBar,
//       this.body,
//       this.floatingActionButton,
//       this.bottomNavigationBar,
//       this.paddingSide,
//         this.endDrawer});
//
//   final PreferredSizeWidget? appBar;
//   final Widget? body;
//   final Widget? endDrawer;
//   final Widget? floatingActionButton;
//   final Widget? bottomNavigationBar;
//   final double? paddingSide;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       drawerEnableOpenDragGesture: false,
//       endDrawerEnableOpenDragGesture: false,
//       endDrawer: endDrawer,
//       backgroundColor: AppColors.bgColorWhite,
//       appBar: appBar,
//       body: SafeArea(
//           child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: paddingSide ?? 16.w),
//         child: body,
//       )),
//       floatingActionButton: floatingActionButton,
//       bottomNavigationBar: bottomNavigationBar,
//     );
//   }
// }
