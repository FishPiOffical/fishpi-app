import 'package:fishpi/fishpi.dart';

mixin IMCallback {
  Function(OnlineMsg msg)? onRecvOnlineMessage;
  Function(ChatRoomMessage msg)? onRecvNewMessage;
  Function(DiscussMsg msg)? onRecvDiscussMessage;
  Function(BarragerMsg msg)? onRecvBarrageMessage;
  Function(RevokeMsg msg)? onRecvRevokeMessage;
  Function(ChatRoomMessage msg)? onRecvRedPacketMessage;
  Function(RedPacketStatusMsg msg)? onRecvRedPacketStatusMessage;
  Function(CustomMsg msg)? onRecvCustomMessage;

  void recvOnlineMessage(OnlineMsg msg) {
    onRecvOnlineMessage?.call(msg);
  }

  void recvNewMessage(ChatRoomMessage msg) {
    onRecvNewMessage?.call(msg);
  }

  void recvDiscussMessage(DiscussMsg msg) {
    onRecvDiscussMessage?.call(msg);
  }

  void recvBarrageMessage(BarragerMsg msg) {
    onRecvBarrageMessage?.call(msg);
  }

  void recvRevokeMessage(RevokeMsg msg) {
    onRecvRevokeMessage?.call(msg);
  }

  void recvRedPacketMessage(ChatRoomMessage msg) {
    onRecvRedPacketMessage?.call(msg);
  }

  void recvRedPacketStatusMessage(RedPacketStatusMsg msg) {
    onRecvRedPacketStatusMessage?.call(msg);
  }

  void recvCustomMessage(CustomMsg msg) {
    onRecvCustomMessage?.call(msg);
  }
}
