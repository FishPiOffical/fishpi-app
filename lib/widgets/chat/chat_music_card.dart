import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/core/controller/chat_music_player.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatMusicCard extends StatelessWidget {
  final ChatMusicTrack track;
  final bool isSelf;

  const ChatMusicCard({
    super.key,
    required this.track,
    required this.isSelf,
  });

  @override
  Widget build(BuildContext context) {
    final player = ChatMusicPlayerController.ensure();
    return Obx(() {
      final selected = player.currentTrack.value?.id == track.id;
      final loading = selected && player.isLoading.value;
      final playing = selected && player.isPlaying.value;
      return GestureDetector(
        onTap: () => player.playTrack(track),
        child: track.isVoice
            ? _buildVoice(loading: loading, playing: playing)
            : _buildMusic(
                loading: loading, playing: playing, selected: selected),
      );
    });
  }

  Widget _buildVoice({
    required bool loading,
    required bool playing,
  }) {
    return Container(
      key: const ValueKey('chat_voice_message'),
      width: 190.w,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelf ? Styles.primaryColor : Colors.white,
        border: Styles.commonBorder,
        borderRadius: _borderRadius(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayIcon(loading: loading, playing: playing),
          8.horizontalSpace,
          Expanded(
            child: _buildTitleColumn(
              title: track.displayTitle,
              subtitle: track.displaySource,
              titleSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusic({
    required bool loading,
    required bool playing,
    required bool selected,
  }) {
    return Container(
      key: const ValueKey('chat_music_card'),
      width: 236.w,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isSelf ? Styles.primaryColor : Colors.white,
        border: Styles.commonBorder,
        borderRadius: _borderRadius(),
      ),
      child: Row(
        children: [
          _buildCover(loading: loading, playing: playing),
          10.horizontalSpace,
          Expanded(
            child: _buildTitleColumn(
              title: track.displayTitle,
              subtitle: selected && playing ? '正在播放' : track.displaySource,
              titleSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover({
    required bool loading,
    required bool playing,
  }) {
    final cover = track.coverURL.trim();
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: cover.isEmpty
              ? _buildFallbackCover()
              : PiImage(
                  imgUrl: cover,
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
        ),
        Container(
          width: 30.w,
          height: 30.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .9),
            border: Styles.commonBorder,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: loading
              ? SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: Styles.primaryTextColor,
                  ),
                )
              : Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  size: 18.w,
                  color: Styles.primaryTextColor,
                ),
        ),
      ],
    );
  }

  Widget _buildFallbackCover() {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE3A1),
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        track.isValid ? Icons.music_note : Icons.music_off,
        size: 24.w,
        color: Styles.primaryTextColor,
      ),
    );
  }

  Widget _buildPlayIcon({
    required bool loading,
    required bool playing,
  }) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: loading
          ? SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: Styles.primaryTextColor,
              ),
            )
          : Icon(
              playing ? Icons.pause : Icons.play_arrow,
              size: 18.w,
              color: Styles.primaryTextColor,
            ),
    );
  }

  Widget _buildTitleColumn({
    required String title,
    required String subtitle,
    required double titleSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Styles.primaryTextColor,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        3.verticalSpace,
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF8E93A3),
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
