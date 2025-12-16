import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'black_list_logic.dart';

class BlackListPage extends StatelessWidget {
  final BlackListLogic logic = Get.put(BlackListLogic());

  BlackListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(
          title: '黑名单',
        ),
        body: logic.blackList.isEmpty
            ? const Center(
              child: Text('暂无数据'),
            )
            : ListView.builder(
                itemBuilder: _buildBlackItem,
                itemCount: logic.blackList.length,
              ),
      ),
    );
  }

  Widget _buildBlackItem(BuildContext context, int index) {
    BlackUser user = logic.blackList[index];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PiAvatar(
                avatarURL: user.avatarURL,
                width: 30.w,
                height: 30.w,
              ),
              SizedBox(
                width: 10.w,
              ),
              SizedBox(
                width: 200.w,
                child: Text(
                  '${user.userName}',
                  style: TextStyle(fontSize: 20.sp),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              logic.removeUser(user.oId!);
            },
            child: Container(
              width: 72.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Styles.primaryColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.black,
                  width: 1.w,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "移出",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
