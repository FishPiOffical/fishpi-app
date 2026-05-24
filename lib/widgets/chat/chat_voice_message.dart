import 'dart:async';

import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/chat/chat_voice_message_utils.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/res/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class ChatVoiceMessage extends StatefulWidget {
  final MusicMsg music;
  final bool isSelf;

  const ChatVoiceMessage({
    super.key,
    required this.music,
    required this.isSelf,
  });

  @override
  State<ChatVoiceMessage> createState() => _ChatVoiceMessageState();
}

class _ChatVoiceMessageState extends State<ChatVoiceMessage> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isPlaying = false;
  bool _isLoading = false;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        _player.stop();
        _player.seek(Duration.zero);
      }
      setState(() {
        _isPlaying =
            state.playing && state.processingState != ProcessingState.completed;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.music.title.trim().isEmpty ? '语音消息' : widget.music.title.trim();
    final subtitle = ChatVoiceMessageUtils.isVoiceMusic(widget.music)
        ? '点击播放'
        : (widget.music.from.trim().isEmpty ? '音乐' : widget.music.from.trim());

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        key: const ValueKey('chat_voice_message'),
        width: 190.w,
        margin: EdgeInsets.only(top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: widget.isSelf ? Styles.primaryColor : Colors.white,
          border: Styles.commonBorder,
          borderRadius: _borderRadius(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlayIcon(),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Styles.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF9FA4B4),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayIcon() {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Styles.commonBorder,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: _isLoading
          ? SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: Styles.primaryTextColor,
              ),
            )
          : Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              size: 18.w,
              color: Styles.primaryTextColor,
            ),
    );
  }

  BorderRadius _borderRadius() {
    if (widget.isSelf) {
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

  Future<void> _togglePlay() async {
    final source = widget.music.source.trim();
    final uri = Uri.tryParse(source);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      ToastManager.showToast('语音地址无效');
      return;
    }

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      setState(() => _isLoading = true);
      if (_loadedUrl != source) {
        await _player.setUrl(source);
        _loadedUrl = source;
      }
      await _player.play();
    } catch (_) {
      ToastManager.showToast('语音播放失败');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
