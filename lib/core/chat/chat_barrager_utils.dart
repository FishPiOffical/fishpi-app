import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi_app/core/sql/black_list.dart';
import 'package:fishpi_app/core/sql/chat_room_block_list.dart';

class ChatBarragerUtils {
  static const int maxContentLength = 60;
  static const List<String> colors = [
    '#FFFFFF',
    '#FFE66D',
    '#FF9F1C',
    '#FF5A5F',
    '#4ECDC4',
    '#7B61FF',
  ];

  static String? validateContent(String content) {
    final text = normalizeContent(content);
    if (text.isEmpty) return '请输入弹幕内容';
    if (text.length > maxContentLength) {
      return '弹幕不能超过 $maxContentLength 个字符';
    }
    return null;
  }

  static String normalizeContent(String content) => content.trim();

  static String normalizeColor(String color) {
    final normalized = color.trim().toUpperCase();
    return colors.contains(normalized) ? normalized : colors.first;
  }

  static bool isBlockedBarrager(
    BarragerMsg msg,
    Iterable<BlackUser> blackUsers, {
    Iterable<ChatRoomBlockedUser> chatRoomBlockedUsers = const [],
  }) {
    final userName = msg.userName.trim();
    return BlackList.isBlockedUser(
          blackUsers,
          userName: userName,
        ) ||
        ChatRoomBlockList.isBlockedUser(
          chatRoomBlockedUsers,
          userName: userName,
        );
  }

  static String displayName(BarragerMsg msg) {
    if (msg.userNickname.trim().isNotEmpty) return msg.userNickname.trim();
    return msg.userName.trim();
  }
}

class ChatBarragerItem {
  final String id;
  final BarragerMsg message;
  final int track;

  const ChatBarragerItem({
    required this.id,
    required this.message,
    required this.track,
  });
}
