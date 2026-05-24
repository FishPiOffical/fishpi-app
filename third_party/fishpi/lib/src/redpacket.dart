import 'dart:convert';

import 'package:fishpi/fishpi.dart';
import 'package:fishpi/src/request.dart';

/// 红包接口
class Redpacket {
  String token = '';

  /// 打开一个红包
  ///
  /// - `oId` 红包消息 Id
  /// - `gesture` 猜拳类型
  ///
  /// 返回红包信息
  Future<RedPacketInfo> open(String oId, {GestureType? gesture}) async {
    try {
      var rsp = await Request.post(
        'chat-room/red-packet/open',
        data: {
          'oId': oId,
          'gesture': gesture?.toString(),
          'apiKey': token,
        },
      );

      if (rsp['code'] != 0) return Future.error(rsp['msg']);

      return RedPacketInfo.from(rsp);
    } catch (e) {
      return Future.error(e);
    }
  }

  /// 发送一个红包
  ///
  /// [redpacket] 红包对象
  Future send(RedPacketMessage redpacket) async {
    return await Chatroom(token)
        .send('[redpacket]${json.encode(redpacket.toJson())}[/redpacket]');
  }
}
