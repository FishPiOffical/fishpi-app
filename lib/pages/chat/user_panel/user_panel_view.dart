import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/loading.dart';
import 'package:fishpi_app/widgets/pi_article_item.dart';
import 'package:fishpi_app/widgets/pi_avatar.dart';
import 'package:fishpi_app/widgets/pi_breezemoon_item.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/pi_menu_item.dart';
import 'user_panel_logic.dart';

class UserPanelPage extends StatelessWidget {
  final UserPanelLogic logic = Get.find();

  UserPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: PiTitleBar.back(
          title: logic.userName.value ?? '用户信息',
          showUnderline: false,
        ),
        body: logic.isLoading.value
            ? const Loading()
            : ListView(
                children: [
                  Container(
                    width: 1.sw,
                    height: 250.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                      border: const Border(
                        top: BorderSide.none,
                        bottom: BorderSide(
                          color: Styles.primaryTextColor,
                          width: 4,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r),
                            ),
                            child: PiImage(
                              imgUrl: logic.userInfo.value.cardBg,
                              width: 1.sw,
                              height: 250.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (logic.userInfo.value.canFollow != 'hide')
                          Positioned(
                            top: 16.h,
                            left: 16.w,
                            child: GestureDetector(
                              onTap: () {
                                logic.toFollow();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16.r),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      logic.userInfo.value.canFollow == 'yes'
                                          ? 'assets/images/star_no.png'
                                          : 'assets/images/star.png',
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                    5.horizontalSpace,
                                    Text(
                                      logic.userInfo.value.canFollow == 'yes'
                                          ? '关注'
                                          : '取消关注',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Styles.primaryTextColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: 1.sw,
                            height: 115.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.r),
                                bottomRight: Radius.circular(12.r),
                              ),
                              color: Colors.white.withOpacity(.9),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 1.sw - 110.w,
                                  child: Text(
                                    logic.userInfo.value.name,
                                    style: TextStyle(
                                      color: Styles.primaryTextColor,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  logic.userInfo.value.intro,
                                  style: TextStyle(
                                    color: const Color(0xFF474A57),
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/location.png',
                                          width: 24.w,
                                          height: 24.w,
                                        ),
                                        2.horizontalSpace,
                                        Text(
                                          logic.userInfo.value.city == ''
                                              ? '未知'
                                              : logic.userInfo.value.city,
                                          style: TextStyle(
                                            color: Styles.primaryTextColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    10.horizontalSpace,
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/coin_line.png',
                                          width: 24.w,
                                          height: 24.w,
                                        ),
                                        2.horizontalSpace,
                                        Text(
                                          logic.userInfo.value.point.toString(),
                                          style: TextStyle(
                                            color: Styles.primaryTextColor,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: 80.h,
                          child: Container(
                            width: 70.w,
                            height: 70.w,
                            child: PiAvatar(
                              userName: logic.userInfo.value.name,
                              avatarURL: logic.userInfo.value.avatarURL,
                              width: 70.w,
                              height: 70.w,
                            ),
                          ),
                        ),
                        if (logic.userInfo.value.isOnline)
                          Positioned(
                            right: 16.w,
                            bottom: 130.h,
                            child: Container(
                              width: 14.w,
                              height: 14.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.w),
                                  color: const Color(0xFF56F92C),
                                  border: Border.all(
                                      width: 2.w, color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  20.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            logic.changeTab(0);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.w,
                                color: Styles.primaryTextColor,
                              ),
                              borderRadius: BorderRadius.circular(50.r),
                              color: logic.tabIndex.value == 0
                                  ? const Color(0xFF00C6AE)
                                  : Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Ta 的帖子',
                              style: TextStyle(
                                color: Styles.primaryTextColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () {
                            logic.changeTab(1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.w,
                                color: Styles.primaryTextColor,
                              ),
                              borderRadius: BorderRadius.circular(50.r),
                              color: logic.tabIndex.value == 1
                                  ? const Color(0xFF00C6AE)
                                  : Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Ta 的清风明月',
                              style: TextStyle(
                                color: Styles.primaryTextColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () {
                            logic.changeTab(2);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2.w,
                                color: Styles.primaryTextColor,
                              ),
                              borderRadius: BorderRadius.circular(50.r),
                              color: logic.tabIndex.value == 2
                                  ? const Color(0xFF00C6AE)
                                  : Colors.white,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '更多',
                              style: TextStyle(
                                color: Styles.primaryTextColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (logic.tabIndex.value == 0)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      itemBuilder: _buildArticleItem,
                      itemCount: logic.userArticles.length,
                    ),
                  if (logic.tabIndex.value == 1)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      itemBuilder: _buildBreezemoonItem,
                      itemCount: logic.userBreezemoons.length,
                    ),
                  if (logic.tabIndex.value == 2)
                    Container(
                      width: 1.sw - 32.w,
                      padding: EdgeInsets.all(10.w),
                      margin: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        border: Styles.commonBorder,
                        color: Colors.white,
                      ),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          PiMenuItem(
                            title: '转账',
                            image: Image.asset(
                              'assets/images/menu_transfer.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                            onTap: logic.toTransfer,
                          ),
                          PiMenuItem(
                            title: '私聊',
                            image: Image.asset(
                              'assets/images/menu_chat.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                            onTap: logic.toChat,
                          ),
                          PiMenuItem(
                            title: '备注',
                            image: Image.asset(
                              'assets/images/menu_label.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                            isShowArrow: false,
                            onTap: logic.toSetLabel,
                          ),
                          PiMenuItem(
                            title: '拉黑',
                            image: Icon(
                              Icons.list_alt_outlined,
                              size: 24.w,
                            ),
                            isShowArrow: false,
                            onTap: logic.toggleBlackList,
                          ),
                          PiMenuItem(
                            title: '在线时长',
                            image: ClipRRect(
                              borderRadius: BorderRadius.circular(50.r),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 24.w,
                                height: 24.w,
                              ),
                            ),
                            isShowArrow: false,
                            rightText:
                                '累计已摸鱼${logic.userInfo.value.onlineMinute}分钟',
                            onTap: logic.toSetLabel,
                          ),
                        ],
                      ),
                    )
                ],
              ),
      ),
    );
  }

  Widget _buildArticleItem(BuildContext context, int index) {
    return PiArticleItem(article: logic.userArticles[index]);
  }

  Widget _buildBreezemoonItem(BuildContext context, int index) {
    return PiBreezemoonItem(breezemoon: logic.userBreezemoons[index]);
  }
}
