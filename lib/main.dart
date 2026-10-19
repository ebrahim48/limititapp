import 'dart:ui';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/presentations/controller/theme_controller.dart';
import 'package:limit_it_app/core/presentations/controller/locale_controller.dart';
import 'package:toastification/toastification.dart';
import 'core/config/app_routes/app_routes.dart';
import 'core/config/app_themes/app_themes.dart';
import 'core/services/ad_service.dart';
import 'core/helpers/dependancy_injaction.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase before anything else that depends on it
  // (google_sign_in and firebase_auth both require this).
  // Guarded so a platform without Firebase config (e.g. iOS before
  // GoogleService-Info.plist is added) still launches; social login will fail.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('❌ Firebase init failed: $e');
  }

  PlatformDispatcher.instance.onAccessibilityFeaturesChanged = () {};
  DependencyInjection di = DependencyInjection();
  di.dependencies();
  di.lockDevicePortrait();
  AdService.instance.init();

  runApp(
    DevicePreview(

      enabled:false,
      builder: (context) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return ToastificationWrapper(
      child: ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) {
            return Obx(() => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'LimitIt',
              theme: Themes().lightTheme,
              darkTheme: Themes().lightTheme,
              builder: DevicePreview.appBuilder,
              locale: localeController.locale.value,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
                Locale('it', ''),
                Locale('es', ''),
              ],
              // darkTheme: ThemeData.dark(),
              themeMode: Get.find<ThemeController>().themeMode.value,
              routeInformationParser: AppRoutes.goRouter.routeInformationParser,
              routeInformationProvider:
              AppRoutes.goRouter.routeInformationProvider,
              routerDelegate: AppRoutes.goRouter.routerDelegate,
            ));
          }),
    );
  }
}