import 'dart:io';

import '../main.dart';
import 'base.dart';

class ChatCmd implements CommandInstance {
  String currentUser = '';
  @override
  ArgParser command(ArgParser parser) {
    return parser
      ..addOption('chat', abbr: 'c', help: '私聊对象')
      ..addOption('say', abbr: 's', help: '私聊内容');
  }

  @override
  Future<void> exec(ArgResults args, PrintFn print) async {
    var chat = args['chat'];
    var say = args['say'];

    if (chat != null) {
      currentUser = chat;
      setCurrentPage(CommandPage.chatroom);
      if (say != null) {
        Instance.get.chat.send(chat, say);
        exit(0);
      }
      Instance.get.chat.connect(user: chat);
    }
  }

  @override
  Future<bool> todo(String command) async {
    if (command.trim().isEmpty) return false;
    if (!Instance.get.isLogin) {
      print('请先登录。');
      return false;
    }
    var argv = command.trim().split(' ');
    switch (argv[0]) {
      case ':chat':
        {
          if (Platform.isWindows) {
            print('命令发送消息不支援 Windows 端。请使用 --say 命令行参数发送，--chat 指定接收者。');
            break;
          }
          if (argv.length > 1) {
            currentUser = argv[1];
            await page(':page chat $currentUser');
            if (argv.length > 2) {
              await Instance.get.chat.send(currentUser, argv[2]);
            } else {
              stdout.write('请输入要发送的内容： ');
              await Instance.get.chat.send(currentUser, stdin.readLineSync() ?? '');
            }
          } else {
            currentUser = '';
            await page(':page chat');
          }
          break;
        }
      case ':help':
        {
          print('''${Command.bold}聊天模块命令${Command.restore}
:page chat [username] 查看聊天记录，username 为私聊对象，不传递 username 则为查看聊天列表
:chat [username] [message] 私聊，username 为私聊对象，message 为私聊内容 (Windows 不支持此命令)
<content> 发送消息到当前的聊天者 (Windows 不支持此命令)
''');
          break;
        }
      default:
        {
          if (currentUser.isEmpty) {
            return todo(':chat $command');
          } else if (Platform.isWindows) {
            print('命令发送消息不支援 Windows 端。请使用 --say 命令行参数发送，--chat 指定接收者。');
          } else {
            Instance.get.chat.send(currentUser, command);
          }
        }
    }
    return true;
  }

  @override
  Future<bool> page(String command) async {
    final commands = command.trim().split(' ');
    if (commands.length > 2 && commands[2].isNotEmpty) {
      currentUser = commands[2];
    }
    if (currentUser.isEmpty) {
      print('------ 聊天列表 ------');
      await Instance.get.chat.list().then((value) => {for (var item in value.reversed) print(itemView(item))});
    } else {
      print('------ 聊天历史 [$currentUser] ------');
      Instance.get.chat.get(user: currentUser).then((value) => {for (var item in value.reversed) print(msgView(item))});
      Instance.get.chat.addListener((type, {data, notice, revoke}) {
        if (type == ChatMsgType.data) {
          if (data != null) {
            print(msgView(data));
          }
        }
      });
    }
    return true;
  }

  String msgView(ChatData msg) {
    return '${Command.bold}${msg.senderUserName}${Command.from('#AAAAAA').color} [${msg.time}]${Command.restore}: ${htmlToText(msg.content, userName: Instance.get.user.current.userName).replaceAll('\n', '')}';
  }

  String itemView(ChatData msg) {
    return '${Command.bold}${msg.senderUserName == Instance.get.user.current.userName ? msg.receiverUserName : msg.senderUserName}${Command.from('#AAAAAA').color} [${msg.time}]${Command.restore}\t';
  }
}
