import 'package:fishpi/types/breezemoon.dart';
import 'package:fishpi_app/widgets/pi_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../res/view.dart';
import '../../widgets/pi_breezemoon_item.dart';
import 'breezemoons_logic.dart';

class BreezemoonsPage extends StatelessWidget {
  final BreezemoonsLogic logic = Get.put(BreezemoonsLogic());

  BreezemoonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Container(
          width: 1.sw,
          height: 1.sh,
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
          ),
          child: SmartRefresher(
            controller: logic.refresherController,
            header: Views.buildHeader(),
            footer: Views.buildFooter(),
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: logic.onRefresh,
            onLoading: logic.onLoading,
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20.h),
              shrinkWrap: true,
              itemBuilder: _buildBreezemoonList,
              itemCount: logic.list.length + 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreezemoonList(
    BuildContext context,
    int idx,
  ) {
    if (idx == 0) {
      return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        height: 36.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 290.w,
              height: 36.h,
              child: PiInput(
                controller: logic.textEditingController,
                onInputChanged: logic.onInputChanged,
                hintText: '随便说说...',
                textAlign: TextAlign.left,
              ),
            ),
            GestureDetector(
              onTap: logic.sendBreezemoon,
              child: Image.asset(
                'assets/images/send.png',
                width: 30.w,
                height: 30.w,
              ),
            ),
          ],
        ),
      );
    }
    BreezemoonContent item = logic.list[idx - 1];
    return PiBreezemoonItem(breezemoon: item);
  }
}
