import 'dart:async';
import 'dart:io';

import 'package:fishpi_app/core/chat/chat_voice_message_utils.dart';
import 'package:fishpi_app/core/controller/im.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:fishpi_app/core/network/app_error_message.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';

/// 聊天页语音录制能力。
///
/// 从 [ChatLogic] 抽出的自包含模块：拥有自己的录音状态、计时器和临时文件管理，
/// 只依赖宿主提供的 [isGroupChat]、[imController] 和 [scrollToBottom]。宿主需在
/// onClose 中调用 [disposeVoice] 释放资源。
mixin ChatVoiceMixin on GetxController {
  // 宿主需要实现的依赖。
  bool get isGroupChat;
  IMController get imController;
  void scrollToBottom({int? delay});

  final isRecordingVoice = false.obs;
  final isSendingVoice = false.obs;
  final voiceRecordSeconds = 0.obs;

  AudioRecorder? _voiceRecorder;
  Timer? _voiceTimer;
  DateTime? _voiceStartedAt;
  String? _voiceRecordPath;
  bool _isStoppingVoice = false;

  Future<void> startVoiceRecord() async {
    if (!isGroupChat) {
      ToastManager.showToast('私聊暂不支持语音消息');
      return;
    }
    if (isRecordingVoice.value || isSendingVoice.value) return;

    try {
      final recorder = _voiceRecorderInstance;
      final hasPermission = await recorder.hasPermission();
      if (!hasPermission) {
        ToastManager.showToast('需要麦克风权限才能发送语音消息');
        return;
      }

      final path = _voiceTempPath();
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );

      _voiceRecordPath = path;
      _voiceStartedAt = DateTime.now();
      voiceRecordSeconds.value = 0;
      isRecordingVoice.value = true;
      _startVoiceTimer();
    } catch (e) {
      await _resetVoiceRecordState(cancelRecorder: true);
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '开始录音失败'),
      );
    }
  }

  Future<void> finishVoiceRecord() async {
    await _stopVoiceRecord(shouldSend: true);
  }

  Future<void> cancelVoiceRecord() async {
    await _stopVoiceRecord(shouldSend: false);
  }

  Future<void> _stopVoiceRecord({required bool shouldSend}) async {
    if (!isRecordingVoice.value || _isStoppingVoice) return;
    _isStoppingVoice = true;

    final duration = _currentVoiceDurationSeconds();
    try {
      final path = await _voiceRecorder?.stop() ?? _voiceRecordPath;
      _stopVoiceTimer();
      isRecordingVoice.value = false;
      voiceRecordSeconds.value = duration;

      if (!shouldSend) {
        _deleteVoiceFile(path);
        ToastManager.showToast('已取消语音');
        return;
      }

      if (duration < ChatVoiceMessageUtils.minRecordSeconds) {
        _deleteVoiceFile(path);
        ToastManager.showToast('录音时间太短');
        return;
      }

      if (path == null || !File(path).existsSync()) {
        ToastManager.showToast('录音文件不存在');
        return;
      }

      await _sendVoiceRecord(path, duration);
    } catch (e) {
      ToastManager.showToast(
        AppErrorMessage.friendly(e, fallback: '语音发送失败'),
      );
    } finally {
      _voiceRecordPath = null;
      _voiceStartedAt = null;
      _isStoppingVoice = false;
      isRecordingVoice.value = false;
      voiceRecordSeconds.value = 0;
    }
  }

  Future<void> _sendVoiceRecord(String path, int durationSeconds) async {
    isSendingVoice.value = true;
    try {
      final result = await imController.fishpi.upload([path]);
      if (result.success.isEmpty) {
        throw result.errs.isEmpty ? '上传失败' : result.errs.join('，');
      }
      final url = result.success.first.url.trim();
      if (url.isEmpty) throw '上传地址为空';

      final message = ChatVoiceMessageUtils.buildMusicMessage(
        url: url,
        durationSeconds: durationSeconds,
      );
      await imController.fishpi.chatroom.send(message);
      scrollToBottom(delay: 300);
    } finally {
      isSendingVoice.value = false;
      _deleteVoiceFile(path);
    }
  }

  void _startVoiceTimer() {
    _stopVoiceTimer();
    _voiceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final seconds = _currentVoiceDurationSeconds();
      voiceRecordSeconds.value = seconds;
      if (seconds >= ChatVoiceMessageUtils.maxRecordSeconds) {
        finishVoiceRecord();
      }
    });
  }

  int _currentVoiceDurationSeconds() {
    final startedAt = _voiceStartedAt;
    if (startedAt == null) return 0;
    final seconds = DateTime.now().difference(startedAt).inSeconds;
    return seconds.clamp(0, ChatVoiceMessageUtils.maxRecordSeconds);
  }

  void _stopVoiceTimer() {
    _voiceTimer?.cancel();
    _voiceTimer = null;
  }

  String _voiceTempPath() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${Directory.systemTemp.path}/fishpi_voice_$timestamp.m4a';
  }

  void _deleteVoiceFile(String? path) {
    if (path == null) return;
    final file = File(path);
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  Future<void> _resetVoiceRecordState({required bool cancelRecorder}) async {
    _stopVoiceTimer();
    if (cancelRecorder) {
      try {
        await _voiceRecorder?.cancel();
      } catch (_) {}
    }
    _deleteVoiceFile(_voiceRecordPath);
    _voiceRecordPath = null;
    _voiceStartedAt = null;
    _isStoppingVoice = false;
    isRecordingVoice.value = false;
    voiceRecordSeconds.value = 0;
  }

  AudioRecorder get _voiceRecorderInstance {
    return _voiceRecorder ??= AudioRecorder();
  }

  /// 宿主在 onClose 中调用，停止计时器并释放录音器。
  void disposeVoice() {
    _stopVoiceTimer();
    _voiceRecorder?.dispose();
  }
}
