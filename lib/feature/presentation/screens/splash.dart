import 'package:bwssb/feature/presentation/screens/loginScreen/login_screen.dart';
import 'package:bwssb/feature/presentation/screens/splashSecondScreen.dart';
import 'package:bwssb/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/coreComponents/ImageView.dart';
import '../../../components/styles/appImages.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed( Duration(seconds: 3), () {
      context.pushAndClearNavigator(Splashsecondscreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: SizedBox.expand(
          child: ImageView(
            url: AppImages.bwssbsplashimage,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
