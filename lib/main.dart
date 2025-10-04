import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'core/config/app_routes/app_routes.dart';
import 'core/config/app_themes/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onAccessibilityFeaturesChanged = () {};
  // DependencyInjection di = DependencyInjection();
  // di.dependencies();
  // di.lockDevicePortrait();
  //
  // Get.put(ThemeController());
  // runApp(
    // DevicePreview(
    //
    //   enabled:false, // Disable in release mode
    //   builder: (context) => MyApp(), // Wrap your app
    // ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'LimitIt App',
              theme: Themes().lightTheme,
              darkTheme: Themes().lightTheme,
              // builder: DevicePreview.appBuilder, // <== Required for layout simulation
              // useInheritedMediaQuery: true,      // <== Required for responsive behavior
              // locale: DevicePreview.locale(context), // <== Optional: test different locales
              // // darkTheme: ThemeData.dark(),
              // themeMode: Get.find<ThemeController>().themeMode.value,
              routeInformationParser: AppRoutes.goRouter.routeInformationParser,
              routeInformationProvider:
              AppRoutes.goRouter.routeInformationProvider,
              routerDelegate: AppRoutes.goRouter.routerDelegate,
              // builder: (context, child) {
              //   return Scaffold(body: NoInterNetScreen(child: child!));
              // },
            );
          }),
    );
  }
}
