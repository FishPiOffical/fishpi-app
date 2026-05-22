import 'package:fishpi/fishpi.dart';

class PrivateChatEvent {
  final String user;
  final ChatMsgType type;
  final ChatNotice? notice;
  final ChatData? data;
  final ChatRevoke? revoke;

  const PrivateChatEvent({
    required this.user,
    required this.type,
    this.notice,
    this.data,
    this.revoke,
  });

  bool get isData => type == ChatMsgType.data && data != null;
  bool get isNotice => type == ChatMsgType.notice && notice != null;
  bool get isRevoke => type == ChatMsgType.revoke && revoke != null;
}
