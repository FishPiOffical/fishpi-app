/// 私聊数据
class ChatData {
  /// 接收 id
  String toId;

  /// 预览内容
  String preview;

  /// 用户会话
  String userSession;

  /// 发送者头像
  String senderAvatar;

  /// markdown
  String markdown;

  /// 接收者头像
  String receiverAvatar;

  /// ID
  String oId;

  /// 时间
  String time;

  /// 发送 id
  String fromId;

  /// 发送者用户名
  String senderUserName;

  /// 内容
  String content;

  /// 接收者用户名
  String receiverUserName;

  ChatData({
    required this.toId,
    required this.preview,
    required this.userSession,
    required this.senderAvatar,
    required this.markdown,
    required this.receiverAvatar,
    required this.oId,
    required this.time,
    required this.fromId,
    required this.senderUserName,
    required this.content,
    required this.receiverUserName,
  });

  ChatData.from(Map<String, dynamic> data)
      : toId = data['toId'] ?? '',
        preview = data['preview'] ?? '',
        userSession = data['user_session'] ?? '',
        senderAvatar = data['senderAvatar'] ?? '',
        markdown = data['markdown'] ?? '',
        receiverAvatar = data['receiverAvatar'] ?? '',
        oId = data['oId'] ?? '',
        time = data['time'] ?? '',
        fromId = data['fromId'] ?? '',
        senderUserName = data['senderUserName'] ?? '',
        content = data['content'] ?? '',
        receiverUserName = data['receiverUserName'] ?? '';

  Map<String, dynamic> toJson() => {
        'toId': toId,
        'preview': preview,
        'user_session': userSession,
        'senderAvatar': senderAvatar,
        'markdown': markdown,
        'receiverAvatar': receiverAvatar,
        'oId': oId,
        'time': time,
        'fromId': fromId,
        'senderUserName': senderUserName,
        'content': content,
        'receiverUserName': receiverUserName,
      };

  @override
  String toString() {
    return 'ChatData{ toId: $toId, preview: $preview, userSession: $userSession, senderAvatar: $senderAvatar, markdown: $markdown, receiverAvatar: $receiverAvatar, oId: $oId, time: $time, fromId: $fromId, senderUserName: $senderUserName, content: $content, receiverUserName: $receiverUserName }';
  }
}

/// 私聊通知
class ChatNotice {
  /// 命令
  String command;

  /// 发送用户 ID
  String userId;

  /// 预览内容
  String? preview;

  /// 发送者头像
  String? senderAvatar;

  /// 发送者用户名
  String? senderUserName;

  ChatNotice({
    required this.command,
    required this.userId,
    this.preview,
    this.senderAvatar,
    this.senderUserName,
  });

  ChatNotice.from(Map<String, dynamic> data)
      : command = data['command'] ?? '',
        userId = data['userId'] ?? '',
        preview = data['preview'],
        senderAvatar = data['senderAvatar'],
        senderUserName = data['senderUserName'];

  Map<String, dynamic> toJson() => {
        'command': command,
        'userId': userId,
        'preview': preview,
        'senderAvatar': senderAvatar,
        'senderUserName': senderUserName,
      };

  @override
  String toString() {
    return 'NoticeMsg{ command: $command, userId: $userId, preview: $preview, senderAvatar: $senderAvatar, senderUserName: $senderUserName }';
  }
}

/// 撤回消息，被撤回消息的 oId
typedef ChatRevoke = String;

/// 聊天消息类型
enum ChatMsgType {
  /// 新聊天通知
  notice,

  /// 聊天内容
  data,

  /// 撤回聊天
  revoke,
}

/// 聊天消息监听
typedef ChatListener = void Function(
  /// 消息类型
  ChatMsgType type, {
  /// 新聊天通知
  ChatNotice? notice,

  /// 聊天内容
  ChatData? data,

  /// 撤回聊天
  ChatRevoke? revoke,
});
