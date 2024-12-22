import 'package:fishpi_app/core/sql/black_list.dart';
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
        body: ListView.builder(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(user.userName ?? "-"),
          GestureDetector(
            onTap: (){
              logic.removeUser(user.oId!);
            },
            child: Container(
              width: 40.w,
              height: 30.w,
              alignment: Alignment.center,
              child:const Icon(
                Icons.delete_forever_outlined,
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
