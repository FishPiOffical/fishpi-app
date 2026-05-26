import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatWeatherCard extends StatelessWidget {
  final WeatherMsg weather;
  final bool isSelf;

  const ChatWeatherCard({
    super.key,
    required this.weather,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    final today = weather.data.isNotEmpty ? weather.data.first : null;
    final description = weather.description.trim().isEmpty
        ? '天气卡片暂不可用'
        : weather.description.trim();

    return Container(
      key: const ValueKey('chat_weather_card'),
      width: 236.w,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isSelf ? Styles.primaryColor : Colors.white,
        border: Styles.commonBorder,
        borderRadius: _borderRadius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7FF),
                  border: Styles.commonBorder,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _weatherIcon(today?.code ?? description),
                  color: Styles.primaryTextColor,
                  size: 22.w,
                ),
              ),
              10.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.city.trim().isEmpty ? '天气' : weather.city.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    3.verticalSpace,
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Styles.secondaryTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (today != null) ...[
            10.verticalSpace,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .72),
                border: Styles.commonBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                '今日 ${_temperatureText(today)}',
                style: TextStyle(
                  color: Styles.primaryTextColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (weather.data.length > 1) ...[
            8.verticalSpace,
            ...weather.data.skip(1).take(3).map(_buildDailyRow),
          ],
        ],
      ),
    );
  }

  Widget _buildDailyRow(WeatherMsgData item) {
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: Row(
        children: [
          Icon(
            _weatherIcon(item.code),
            size: 15.w,
            color: Styles.secondaryTextColor,
          ),
          6.horizontalSpace,
          Expanded(
            child: Text(
              item.date.trim().isEmpty ? '未来天气' : item.date.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Styles.secondaryTextColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _temperatureText(item),
            style: TextStyle(
              color: Styles.secondaryTextColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _temperatureText(WeatherMsgData data) {
    final min = data.min.round();
    final max = data.max.round();
    if (min == 0 && max == 0) return '温度未知';
    return '$min°/$max°';
  }

  IconData _weatherIcon(String value) {
    final text = value.toLowerCase();
    if (text.contains('雨') || text.contains('rain')) {
      return Icons.water_drop_outlined;
    }
    if (text.contains('雪') || text.contains('snow')) {
      return Icons.ac_unit;
    }
    if (text.contains('云') || text.contains('cloud')) {
      return Icons.cloud_outlined;
    }
    if (text.contains('阴')) {
      return Icons.filter_drama_outlined;
    }
    if (text.contains('雷') || text.contains('storm')) {
      return Icons.thunderstorm_outlined;
    }
    if (text.contains('雾') || text.contains('fog')) {
      return Icons.foggy;
    }
    final code = int.tryParse(text);
    if (code != null) {
      if (code >= 300 && code < 600) return Icons.water_drop_outlined;
      if (code >= 600 && code < 700) return Icons.ac_unit;
      if (code >= 801 && code < 900) return Icons.cloud_outlined;
      if (code == 800 || code == 0 || code == 100) return Icons.wb_sunny;
    }
    return Icons.wb_sunny_outlined;
  }

  BorderRadius _borderRadius() {
    if (isSelf) {
      return BorderRadius.only(
        topLeft: Radius.circular(16.w),
        bottomRight: Radius.circular(16.w),
        bottomLeft: Radius.circular(16.w),
      );
    }
    return BorderRadius.only(
      topRight: Radius.circular(16.w),
      bottomRight: Radius.circular(16.w),
      bottomLeft: Radius.circular(16.w),
    );
  }
}
