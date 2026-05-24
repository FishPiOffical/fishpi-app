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
    final style = _MedalLevelChipStyle.resolve(text);
    return Container(
      key: ValueKey('medal_level_chip_${style.key}'),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        gradient: style.gradient,
        border: Border.all(color: style.borderColor, width: style.borderWidth),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: style.shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (style.markColor != null) ...[
            Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: style.markColor,
                shape: BoxShape.circle,
              ),
            ),
            5.horizontalSpace,
          ],
          Text(
            text,
            style: TextStyle(
              color: style.foregroundColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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

class _MedalLevelChipStyle {
  final String key;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow> shadows;
  final Color? markColor;

  const _MedalLevelChipStyle({
    required this.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.gradient,
    this.shadows = const [],
    this.markColor,
  });

  static _MedalLevelChipStyle resolve(String level) {
    // 等级特效只作用在等级按钮上，勋章本体保持服务端配置的原始样式。
    switch (level.trim()) {
      case '精良':
        return fine;
      case '稀有':
        return rare;
      case '史诗':
        return epic;
      case '传说':
        return legendary;
      case '神话':
        return mythic;
      case '限定':
        return limited;
      case '普通':
      default:
        return normal;
    }
  }

  static const normal = _MedalLevelChipStyle(
    key: 'normal',
    backgroundColor: Color(0xFFF0F0F0),
    foregroundColor: Colors.black,
    borderColor: Colors.black,
  );

  static const fine = _MedalLevelChipStyle(
    key: 'fine',
    backgroundColor: Color(0xFFE6F4FF),
    foregroundColor: Color(0xFF0F3D91),
    borderColor: Color(0xFF2F80ED),
    markColor: Color(0xFF2F80ED),
    shadows: [
      BoxShadow(
        color: Color(0x262F80ED),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const rare = _MedalLevelChipStyle(
    key: 'rare',
    backgroundColor: Color(0xFFF2EAFE),
    foregroundColor: Color(0xFF4C1D95),
    borderColor: Color(0xFF8854D0),
    markColor: Color(0xFF8854D0),
    shadows: [
      BoxShadow(
        color: Color(0x268854D0),
        blurRadius: 9,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const epic = _MedalLevelChipStyle(
    key: 'epic',
    backgroundColor: Color(0xFFFFF4CC),
    foregroundColor: Color(0xFF7A3B00),
    borderColor: Color(0xFFF59E0B),
    markColor: Color(0xFFF59E0B),
    gradient: LinearGradient(
      colors: [Color(0xFFFFF7D6), Color(0xFFFFE2A8)],
    ),
    shadows: [
      BoxShadow(
        color: Color(0x2EF59E0B),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const legendary = _MedalLevelChipStyle(
    key: 'legendary',
    backgroundColor: Color(0xFFFFF0B8),
    foregroundColor: Color(0xFF5F3B00),
    borderColor: Color(0xFFD6A300),
    borderWidth: 1.7,
    markColor: Color(0xFFD6A300),
    gradient: LinearGradient(
      colors: [Color(0xFFFFF6C8), Color(0xFFFFD95A)],
    ),
    shadows: [
      BoxShadow(
        color: Color(0x3DF5C542),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const mythic = _MedalLevelChipStyle(
    key: 'mythic',
    backgroundColor: Color(0xFFEDE9FE),
    foregroundColor: Color(0xFF3B0764),
    borderColor: Color(0xFF7C3AED),
    borderWidth: 1.8,
    markColor: Color(0xFF22D3EE),
    gradient: LinearGradient(
      colors: [Color(0xFFFFF0A3), Color(0xFFEDE9FE), Color(0xFFD9F7FF)],
    ),
    shadows: [
      BoxShadow(
        color: Color(0x407C3AED),
        blurRadius: 13,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const limited = _MedalLevelChipStyle(
    key: 'limited',
    backgroundColor: Color(0xFFFFE8E6),
    foregroundColor: Color(0xFFFFFFFF),
    borderColor: Color(0xFFFFCC33),
    borderWidth: 1.8,
    markColor: Color(0xFFFFCC33),
    gradient: LinearGradient(
      colors: [Color(0xFFE53935), Color(0xFF9F1239)],
    ),
    shadows: [
      BoxShadow(
        color: Color(0x3DE53935),
        blurRadius: 12,
        offset: Offset(0, 2),
      ),
    ],
  );
}
