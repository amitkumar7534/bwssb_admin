import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bwssb/services/storage/preferences.dart';
import 'package:bwssb/utils/extensions/loader_utils.dart';
import 'package:bwssb/feature/presentation/screens/splash.dart';
import 'package:bwssb/components/styles/ui_theme.dart';

import 'feature/presentation/controller/Get_application_ctrl.dart';
import 'feature/presentation/screens/applicationScreen/application_form_screen.dart';

final GlobalKey<NavigatorState> navState = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.createInstance();
  await Firebase.initializeApp();

  /// Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  /// Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  Get.put(GetApplicationCtrl());
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
  });}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LoaderUtils.loaderInit(
      child: GetMaterialApp(
        navigatorKey: navState,
        debugShowCheckedModeBanner: false,
        title: 'BWSSB App',
        themeMode: ThemeMode.light,
        theme: ThemeData.light().copyWith(
          extensions: <ThemeExtension<dynamic>>[
            lightUiTheme, // Your custom UI theme if needed
          ],
        ),
        home:
        Splash()
        // ApplicationFormScreen()
      ),
    );
  }
}
