import 'package:fishpi_app/core/medal/medal_service.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_title_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../widgets/metail_widget.dart';
import 'collection_list_logic.dart';

class CollectionListPage extends StatelessWidget {
  CollectionListPage({super.key});

  final CollectionListLogic logic = Get.find<CollectionListLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PiTitleBar.back(
        title: '典藏馆',
      ),
      body: Obx(
        () => Container(
          width: 1.sw,
          height: 1.sh,
          color: Styles.titleBarColor,
          child: RefreshIndicator(
            color: Colors.black,
            onRefresh: logic.loadMedals,
            child: logic.medals.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    itemCount: logic.medals.length,
                    separatorBuilder: (_, __) => 12.verticalSpace,
                    itemBuilder: (context, index) {
                      return _buildMedalCard(logic.medals[index]);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 220.h),
        Center(
          child: logic.isLoading.value
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
                  '暂无勋章',
                  style: TextStyle(
                    color: Styles.primaryTextColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMedalCard(CollectionMedal medal) {
    final updating = logic.isUpdating(medal);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMedalPreview(medal),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (medal.rawMetal == null)
                      Text(
                        medal.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Styles.primaryTextColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (medal.rawMetal == null) 6.verticalSpace,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _buildStatusChip(medal.display),
                        if (medal.type.isNotEmpty) _buildTypeChip(medal.type),
                        if (medal.expireTime.isNotEmpty)
                          _buildExpireChip(medal.expireTime),
                      ],
                    ),
                    if (medal.description.isNotEmpty) ...[
                      8.verticalSpace,
                      Text(
                        medal.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Styles.secondaryTextColor,
                          fontSize: 13.sp,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton(medal, updating),
          ),
        ],
      ),
    );
  }

  Widget _buildMedalPreview(CollectionMedal medal) {
    if (medal.rawMetal != null) {
      return MedalWidget(medal: medal.rawMetal!);
    }

    if (medal.imageUrl.isEmpty) {
      return _buildMedalFallbackIcon();
    }

    return Container(
      width: 122.w,
      height: 34.h,
      alignment: Alignment.centerLeft,
      child: Image.network(
        medal.imageUrl,
        height: 28.h,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildMedalFallbackIcon(),
      ),
    );
  }

  Widget _buildMedalFallbackIcon() {
    return Container(
      width: 34.w,
      height: 34.w,
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(17.r),
      ),
      child: const Icon(Icons.workspace_premium_outlined),
    );
  }

  Widget _buildActionButton(CollectionMedal medal, bool updating) {
    final text = medal.display ? '取消展示' : '展示勋章';
    final icon = medal.display
        ? Icons.visibility_off_outlined
        : Icons.visibility_outlined;
    return GestureDetector(
      onTap: updating ? null : () => logic.toggleDisplay(medal),
      child: Opacity(
        opacity: updating ? 0.62 : 1,
        child: Container(
          width: 118.w,
          height: 38.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: medal.display ? Colors.white : Colors.black,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: updating
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.black,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18.w,
                      color: medal.display ? Colors.black : Colors.white,
                    ),
                    6.horizontalSpace,
                    Text(
                      text,
                      style: TextStyle(
                        color: medal.display ? Colors.black : Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool display) {
    return _buildChip(
      display ? '展示中' : '已隐藏',
      display ? Styles.primaryColor : const Color(0xFFE8E8E8),
    );
  }

  Widget _buildTypeChip(String text) {
    return _buildChip(text, const Color(0xFFE6F4FF));
  }

  Widget _buildExpireChip(String text) {
    return _buildChip('有效期 $text', const Color(0xFFFFF4CC));
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Styles.primaryTextColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
