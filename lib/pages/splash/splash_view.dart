import 'package:fishpi_app/pages/splash/splash_logic.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _lottieAnimation;
  var expanded = false;
  final transitionDuration = const Duration(seconds: 1);
  bool isLogin = false;
  final logic = Get.find<SplashLogic>();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _lottieAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    Future.delayed(const Duration(seconds: 1))
        .then((value) => setState(() => expanded = true))
        // .then((value) => const Duration(seconds: 1))
        .then(
          (value) => Future.delayed(const Duration(seconds: 1)).then((value) {
            _lottieAnimation.forward().then((value) {
              logic.toStartApp();
            });
          }),
        );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Styles.primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedCrossFade(
              firstCurve: Curves.fastOutSlowIn,
              crossFadeState: !expanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: transitionDuration,
              firstChild: Container(),
              secondChild: _logoRemainder(),
              alignment: Alignment.center,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoRemainder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LottieBuilder.asset(
          'assets/logo_lottie.json',
          onLoaded: (composition) {
            _lottieAnimation.duration = const Duration(seconds: 2);
          },
          frameRate: FrameRate.max,
          fit: BoxFit.contain,
          repeat: true,
          animate: false,
          height: 120.w,
          width: 120.w,
          controller: _lottieAnimation,
        ),
        Image.asset(
          'assets/images/logo_word.png',
          width: 120.w,
        )
      ],
    );
  }
}
