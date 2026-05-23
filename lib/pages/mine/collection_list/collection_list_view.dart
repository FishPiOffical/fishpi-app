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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMedalPreview(medal),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    6.verticalSpace,
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
                  ],
                ),
              ),
              updating
                  ? SizedBox(
                      width: 44.w,
                      height: 44.w,
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : Switch(
                      value: medal.display,
                      activeThumbColor: Colors.black,
                      activeTrackColor: Styles.primaryColor,
                      inactiveThumbColor: Colors.black,
                      inactiveTrackColor: const Color(0xFFE8E8E8),
                      onChanged: (_) => logic.toggleDisplay(medal),
                    ),
            ],
          ),
          if (medal.description.isNotEmpty) ...[
            12.verticalSpace,
            Text(
              medal.description,
              style: TextStyle(
                color: Styles.secondaryTextColor,
                fontSize: 13.sp,
                height: 1.45,
              ),
            ),
          ],
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
