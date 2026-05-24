import 'dart:io';

import 'base.dart';
import 'user.dart';

class ChatRoomCmd implements CommandInstance {
  @override
  ArgParser command(ArgParser parser) {
    return parser
      ..addOption('talk', help: '发送消息到聊天室（需曾经登录过或添加 -u 参数）')
      ..addOption('barrager', help: '发送弹幕到聊天室（需曾经登录过或添加 -u 参数）')
      ..addOption('barrager-color', help: '弹幕颜色', defaultsTo: '#FFFFFF');
  }

  @override
  Future<void> exec(ArgResults args, PrintFn print) async {
    if (args['talk'] != null) {
      if (!Instance.get.isLogin && !await UserCmd().login()) {
        exit(0);
      }
      Instance.get.chatroom.send(args['talk']).then(print);
      exit(0);
    }
    if (args['barrager'] != null) {
      if (!Instance.get.isLogin) {
        print('请先登录。');
      } else {
        Instance.get.chatroom
            .barrage(args['barrager'],
                color: args['barrager-color'] ?? '#FFFFFF')
            .then(print);
      }
      exit(0);
    }
    Instance.get.chatroom.addListener((msg) {
      try {
        switch (msg.type) {
          case ChatRoomMessageType.online:
            break;
          case ChatRoomMessageType.barrager:
            print(barragerView(msg.barrager!));
            break;
          case ChatRoomMessageType.discussChanged:
            break;
          case ChatRoomMessageType.msg:
            print(msgView(msg.msg!));
            break;
          case ChatRoomMessageType.revoke:
            break;
          case ChatRoomMessageType.redPacket:
            print(redPacketView(msg.msg!));
            break;
          case ChatRoomMessageType.redPacketStatus:
            break;
          case ChatRoomMessageType.custom:
            print(
                '${Command.from('#888888').color}${msg.custom}${Command.restore}');
            break;
        }
      } catch (e) {
        print('${Command.from('#FF0000')}未知异常：$e${Command.restore}');
      }
    });
    Instance.get.chatroom.reconnect();
  }

  @override
  Future<bool> todo(String command) async {
    if (command.trim().isEmpty) return false;
    var argv = command.trim().split(' ');
    switch (argv[0]) {
      case ':barrage':
        {
          if (!Instance.get.isLogin) {
            print('请先登录。');
            break;
          }
          if (!Platform.isWindows) {
            var content = '';
            var color = '#FFFFFF';
            if (argv.length > 1) {
              if (argv[1].startsWith('#') && argv[1].length == 7) {
                color = argv[1];
                content = argv.skip(2).join(' ');
              } else {
                content = argv.skip(1).join(' ');
              }
            } else {
              stdout.write('请输入要发送的内容： ');
              content = stdin.readLineSync() ?? '';
            }
            await Instance.get.chatroom.barrage(content, color: color);
          } else {
            print('弹幕发送消息不支援 Windows 端。请使用 --barrager 命令行参数发送。');
          }
          break;
        }
      case ':help':
        {
          print('''${Command.bold}聊天室模块命令${Command.restore}
:barrage [#color] <content> 发送弹幕，color 必须 # 开头，6 位颜色代码，如 #FFFFFF，不填写则为白色（Windows 不支持此命令）
<content> 发送消息到聊天室（Windows 不支持此命令）
''');
          break;
        }
      default:
        {
          if (!Instance.get.isLogin) {
            print('请先登录。');
            break;
          }
          if (!Platform.isWindows) {
            await Instance.get.chatroom.send(command);
          } else {
            print('命令发送消息不支援 Windows 端。请使用 --talk 命令行参数发送。');
          }
        }
    }
    return true;
  }

  @override
  Future<bool> page(String command) async {
    List<ChatRoomMessage> msgList =
        await Instance.get.chatroom.more(1, type: ChatContentType.HTML);
    for (var msg in msgList.reversed) {
      print(msgView(msg));
    }
    return true;
  }

  String msgView(ChatRoomMessage msg) {
    if (msg.isRedpacket) return redPacketView(msg);
    return '${Command.bold}${msg.allName}${Command.from('#AAAAAA').color} [${msg.time}]${Command.restore}: ${htmlToText(msg.content, userName: Instance.get.user.current.userName).replaceAll('\n', ' ')}';
  }

  String redPacketView(ChatRoomMessage msg) {
    return '${Command.bold}${msg.allName}${Command.restore} [${msg.time}]: { 收到一个${RedPacketType.toName(msg.redpacket?.type ?? '')} }';
  }

  String barragerView(BarragerMsg msg) {
    return '${Command.bold}${Command.from(msg.barragerColor).color}[${msg.allName}: ${msg.barragerContent}]>~~${Command.restore}';
  }
}
