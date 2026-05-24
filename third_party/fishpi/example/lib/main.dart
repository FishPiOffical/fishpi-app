import 'package:fishpi/src/fishpi.dart';
import 'package:fishpi/types/types.dart';

Fishpi fishpi = Fishpi();
void main() async {
  LoginData loginData = LoginData(
    username: 'username',
    passwd: 'password',
    // mfaCode: '123456', // 如果开启了 MFA 验证，需要填写
  );
  // 登录
  await fishpi.login(loginData);

  // 获取用户信息
  UserInfo info = await fishpi.user.info();
  print(info.toString());

  // 监听聊天室
  await fishpi.chatroom.addListener((ChatRoomData data) {
    try {
      switch (data.type) {
        case ChatRoomMessageType.online:
          // 上线消息
          print(data.online!);
          break;
        case ChatRoomMessageType.barrager:
          // 弹幕消息
          print(data.barrager!);
          break;
        case ChatRoomMessageType.discussChanged:
          // 话题变更
          print(data.discuss!);
          break;
        case ChatRoomMessageType.msg:
          // 普通消息
          print(data.msg!);
          break;
        case ChatRoomMessageType.revoke:
          // 撤回消息
          print(data.revoke!);
          break;
        case ChatRoomMessageType.redPacket:
          // 红包消息
          print(data.msg!);
          break;
        case ChatRoomMessageType.redPacketStatus:
          // 红包领取
          print(data.status!);
          break;
        case ChatRoomMessageType.custom:
          // 自定义消息
          print(data.custom!);
          break;
      }
    } catch (e) {
      print('未知异常：$e');
    }
  });

  // 发送消息
  await fishpi.chatroom.send('Hello World!');

  // 发送弹幕
  await fishpi.chatroom.barrage('Hello World!', color: '#FF0000');

  // 发送清风明月
  await fishpi.breezemoon.send('Hello World!');
}
