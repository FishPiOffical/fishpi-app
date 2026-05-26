import 'dart:async';

import 'package:fishpi_app/core/chat/chat_music_utils.dart';
import 'package:fishpi_app/core/manager/toast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class ChatMusicPlayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  final queue = <ChatMusicTrack>[].obs;
  final currentTrack = Rxn<ChatMusicTrack>();
  final currentIndex = (-1).obs;
  final isPlaying = false.obs;
  final isLoading = false.obs;

  StreamSubscription<PlayerState>? _playerStateSubscription;

  static ChatMusicPlayerController ensure() {
    if (Get.isRegistered<ChatMusicPlayerController>()) {
      return Get.find<ChatMusicPlayerController>();
    }
    return Get.put(ChatMusicPlayerController(), permanent: true);
  }

  @override
  void onInit() {
    super.onInit();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      isPlaying.value =
          state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed) {
        Future<void>.microtask(_playNextAfterCompleted);
      }
    });
  }

  Future<void> playTrack(ChatMusicTrack track) async {
    if (!track.isValid) {
      ToastManager.showToast('音乐地址无效');
      return;
    }

    final index = _ensureTrack(track);
    final current = currentTrack.value;
    if (current?.id == track.id) {
      await togglePlay();
      return;
    }

    await _playAt(index);
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= queue.length) return;
    await _playAt(index);
  }

  Future<void> togglePlay() async {
    if (currentTrack.value == null && queue.isNotEmpty) {
      await _playAt(0);
      return;
    }
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (_) {
      ToastManager.showToast('音乐播放失败');
    }
  }

  Future<void> next() async {
    if (queue.isEmpty) return;
    final nextIndex =
        currentIndex.value < 0 ? 0 : (currentIndex.value + 1) % queue.length;
    await _playAt(nextIndex);
  }

  void clearQueue() {
    queue.clear();
    currentTrack.value = null;
    currentIndex.value = -1;
    _player.stop();
  }

  int _ensureTrack(ChatMusicTrack track) {
    final existingIndex = queue.indexWhere((item) => item.id == track.id);
    if (existingIndex >= 0) return existingIndex;
    queue.add(track);
    return queue.length - 1;
  }

  Future<void> _playAt(int index) async {
    if (index < 0 || index >= queue.length) return;
    final track = queue[index];
    if (!track.isValid) {
      ToastManager.showToast('音乐地址无效');
      return;
    }

    isLoading.value = true;
    currentIndex.value = index;
    currentTrack.value = track;
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(track.source)));
      await _player.play();
    } catch (_) {
      ToastManager.showToast(track.isVoice ? '语音播放失败' : '音乐播放失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _playNextAfterCompleted() async {
    if (queue.length > 1) {
      await next();
      return;
    }
    await _player.seek(Duration.zero);
    await _player.pause();
  }

  @override
  void onClose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.onClose();
  }
}
