import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/main.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/routers/navigator.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:images_picker/images_picker.dart';
import 'package:scan/scan.dart';

import '../core/controller/im.dart';
import '../utils/pi_utils.dart';

class PiScan extends StatelessWidget {
  const PiScan({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    IconData lightIcon = Icons.flash_on;
    final ScanController controller = ScanController();

    return Scaffold(
      body: Stack(
        children: [
          ScanView(
            controller: controller,
            scanLineColor: Styles.primaryColor,
            onCapture: (data) {
              controller.pause();
              getResult(data, context);
            },
          ),
          Positioned(
            left: 100.w,
            bottom: 100.h,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return MaterialButton(
                    child: Icon(
                      lightIcon,
                      size: 40.w,
                      color: Styles.primaryColor,
                    ),
                    onPressed: () {
                      controller.toggleTorchMode();
                      if (lightIcon == Icons.flash_on) {
                        lightIcon = Icons.flash_off;
                      } else {
                        lightIcon = Icons.flash_on;
                      }
                      setState(() {});
                    });
              },
            ),
          ),
          Positioned(
            right: 100.w,
            bottom: 100.h,
            child: MaterialButton(
              child: Icon(
                Icons.image,
                size: 40.w,
                color: Styles.primaryColor,
              ),
              onPressed: () async {
                List<Media>? res =
                    await ImagesPicker.pick(count: 1, maxSize: 1024);
                if (res != null) {
                  controller.pause();
                  Media image = res.first;
                  String? result = await Scan.parse(image.path);
                  if (result != null) {
                    getResult(result, context);
                  }
                }else{
                  controller.resume();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void getResult(String result, BuildContext context) async{
    final imController = Get.find<IMController>();
    print(result);
    if(result.startsWith('login')){
      bool isLogin = PiUtils.getBool('isLogin');
      if(isLogin){
        ToastManager.showToast('请先退出当前帐号!');
        Get.back();
        return;
      }
      String token = result.split(":")[1];
      imController.init(token);
      ToastManager.showToast('登录成功');
      PiUtils.setString('token', token);
      PiUtils.setBool('isLogin', true);
      AppNavigator.closeAllToHome();
    }
  }
}
