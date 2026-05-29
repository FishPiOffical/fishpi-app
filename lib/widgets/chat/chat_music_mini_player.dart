import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/core/controller/chat_music_player.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatMusicMiniPlayer extends StatelessWidget {
  const ChatMusicMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ChatMusicPlayerController.createdVersion.value;
      final player = ChatMusicPlayerController.maybeFind();
      if (player == null) return const SizedBox.shrink();
      if (player.queue.isEmpty) return const SizedBox.shrink();
      final track = player.currentTrack.value ?? player.queue.first;
      return Container(
        key: const ValueKey('chat_music_mini_player'),
        width: 1.sw,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Styles.primaryTextColor, width: 2),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              _buildIcon(track),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Styles.primaryTextColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      track.displaySource,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Styles.secondaryTextColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildIconButton(
                key: const ValueKey('chat_music_mini_play_button'),
                icon: player.isPlaying.value ? Icons.pause : Icons.play_arrow,
                onTap: player.togglePlay,
              ),
              6.horizontalSpace,
              _buildIconButton(
                key: const ValueKey('chat_music_mini_next_button'),
                icon: Icons.skip_next,
                onTap: player.next,
              ),
              6.horizontalSpace,
              _buildIconButton(
                key: const ValueKey('chat_music_mini_queue_button'),
                icon: Icons.queue_music,
                onTap: () => _showQueue(player),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIcon(ChatMusicTrack track) {
    return Container(
      width: 32.w,
      height: 32.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Styles.primaryColor,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        track.isVoice ? Icons.mic_none : Icons.music_note,
        size: 18.w,
        color: Styles.primaryTextColor,
      ),
    );
  }

  Widget _buildIconButton({
    required Key key,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, size: 19.w, color: Styles.primaryTextColor),
      ),
    );
  }

  void _showQueue(ChatMusicPlayerController player) {
    Get.bottomSheet(
      ChatMusicQueueSheet(player: player),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}

class ChatMusicQueueSheet extends StatelessWidget {
  final ChatMusicPlayerController player;

  const ChatMusicQueueSheet({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        key: const ValueKey('chat_music_queue_sheet'),
        width: 1.sw,
        constraints: BoxConstraints(maxHeight: 0.62.sh),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Styles.titleBarColor,
          border: Styles.commonBorder,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '播放列表',
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: player.clearQueue,
                  child: Text(
                    '清空',
                    style: TextStyle(
                      color: Styles.secondaryTextColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            12.verticalSpace,
            Flexible(
              child: Obx(
                () => ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final track = player.queue[index];
                    final selected = player.currentTrack.value?.id == track.id;
                    return GestureDetector(
                      onTap: () => player.playAt(index),
                      child: Container(
                        key: ValueKey('chat_music_queue_item_$index'),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? Styles.primaryColor : Colors.white,
                          border: Styles.commonBorder,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              track.isVoice ? Icons.mic_none : Icons.music_note,
                              size: 18.w,
                              color: Styles.primaryTextColor,
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                track.displayTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Styles.primaryTextColor,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => 8.verticalSpace,
                  itemCount: player.queue.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
