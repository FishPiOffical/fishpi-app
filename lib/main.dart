import 'package:fishpi_app/core/controller/chat_music_player.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/debug/performance_trace.dart';
import 'package:fishpi_app/core/sql/user_remark.dart';
import 'package:fishpi_app/routers/pages.dart';
import 'package:fishpi_app/utils/pi_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  PerformanceTrace.startApp();
  SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  );
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  WidgetsFlutterBinding.ensureInitialized();
  await PiUtils.getInstance();
  await Hive.initFlutter();
  await UserRemark.init();
  runApp(ScreenUtilInit(
    designSize: const Size(360, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    ensureScreenSize: false,
    builder: (context, child) {
      return GetMaterialApp(
        title: '摸鱼派',
        initialBinding: InitBinding(),
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          textSelectionTheme: const TextSelectionThemeData(
            selectionHandleColor: Colors.orange,
            selectionColor: Colors.orange,
          ), // 设置手柄主题色
        ),
        getPages: AppPages.routes,
        initialRoute: AppRoutes.splash,
        builder: EasyLoading.init(),
        locale: const Locale('zh'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
        ],
      );
    },
  ));
}

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IMController>(IMController());
    Get.put<ChatMusicPlayerController>(
      ChatMusicPlayerController(),
      permanent: true,
    );
  }
}
