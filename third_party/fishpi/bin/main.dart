import 'dart:convert';
import 'dart:io';

import 'package:fishpi/src/version.g.dart';

import 'src/base.dart';
import 'src/utils.dart';
import 'src/user.dart';
import 'src/chatroom.dart';
import 'src/chat.dart';
import 'src/breezemoon.dart';
import 'src/article.dart';

enum CommandPage {
  utils,
  user,
  chatroom,
  chat,
  breezemoon,
  article,
}

var commands = {
  CommandPage.utils: UtilsCmd(),
  CommandPage.user: UserCmd(),
  CommandPage.chatroom: ChatRoomCmd(),
  CommandPage.chat: ChatCmd(),
  CommandPage.breezemoon: BreezemoonCmd(),
  CommandPage.article: ArticleCmd(),
};

CommandPage currentPage = CommandPage.user;
void setCurrentPage(CommandPage page) {
  currentPage = page;
}

PrintFn pagePrint(CommandPage page) {
  return (dynamic msg, [bool newLine = true]) {
    if (currentPage != page) return;
    if (lstCommandCode.isNotEmpty) {
      stdout.write('${Command.clearLine}\r');
    }
    (newLine ? print : stdout.write)(msg);
    if (lstCommandCode.isNotEmpty) {
      stdout.write(
          '${Command.clearLine}\r${Utf8Decoder().convert(lstCommandCode)}');
    }
  };
}

List<int> lstCommandCode = [];
readCommand() async {
  stdin.echoMode = false;
  stdin.lineMode = false;
  stdin.listen((data) {
    if (data.last == 8) {
      lstCommandCode.addAll(data);
      lstCommandCode.removeLast();
      if (lstCommandCode.isNotEmpty) {
        var strList = Utf8Decoder().convert(lstCommandCode).split('');
        strList.removeLast();
        lstCommandCode = List.from(strList.join('').codeUnits);
      }
    } else if (data.last == 127 && lstCommandCode.isNotEmpty) {
      var last = lstCommandCode.last;
      if (last > 0x7f) {
        // last is utf 8 byte, need to remove 3 bytes
        lstCommandCode.removeLast();
        lstCommandCode.removeLast();
        lstCommandCode.removeLast();
      } else {
        lstCommandCode.removeLast();
      }
    } else {
      lstCommandCode.addAll(data);
    }
    stdout.write(
        '${Command.clearLine}\r${Utf8Decoder().convert(lstCommandCode)}');
    if (data.last == 10 || data.last == 13) {
      var command = Utf8Decoder().convert(lstCommandCode).trim();
      if (command.isEmpty) {
        return;
      }

      lstCommandCode.clear();
      var commandArgs = command.split(' ');

      switch (commandArgs[0]) {
        case ':quit':
        case ':q':
          stdin.lineMode = true;
          stdin.echoMode = true;
          exit(0);
        case ':page':
          if (commandArgs.length < 2) break;
          for (var element in CommandPage.values) {
            if (element.name == commandArgs[1]) {
              currentPage = element;
            }
          }
          stdout.write('${Command.clearScreen}${Command.moveTo(0, 0)}');
          commands[currentPage]?.page(command);
          break;
        case ':help':
          stdout.write('${Command.clearScreen}${Command.moveTo(0, 0)}');
          print('''${Command.bold}公共命令${Command.restore}
:page <page> 切换页面 page: ${CommandPage.values.map((e) => e.name).skip(1).join(', ')}
:quit/:q 退出
:help 帮助
''');
          if (commands[currentPage] != null) {
            commands[currentPage]?.todo(command);
          }
          break;
        default:
          stdout.write('${Command.moveUp(1)}${Command.clearLine}');
          if (commands[currentPage] != null) {
            commands[currentPage]?.todo(command);
          }
          break;
      }
    }
  });
}

void main(List<String> arguments) async {
  var parser = registerCommand(commands.values.toList())
    ..addOption('page',
        help: '切换启动页面',
        allowed: CommandPage.values.skip(1).map((e) => e.name).toList(),
        defaultsTo: 'chatroom')
    ..addFlag('version', abbr: 'v')
    ..addFlag('help', abbr: 'h');

  late ArgResults args;

  try {
    args = parser.parse(arguments);
  } catch (e) {
    print('命令行参数错误！\n');
    print(parser.usage);
    return;
  }

  if (args['version']) {
    print(packageVersion);
    return;
  }

  if (args['help']) {
    print('version $packageVersion\n\n命令行参数：\n');
    print(parser.usage);
    return;
  }

  for (var cmd in commands.entries) {
    await cmd.value.exec(args, pagePrint(cmd.key));
  }

  if (args['page'] != null) {
    CommandPage.values
        .where((element) => element.name == args['page'])
        .forEach((element) {
      currentPage = element;
    });
  }

  await commands[currentPage]?.page('');

  readCommand();
}
