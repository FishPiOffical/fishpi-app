import 'dart:io';

import 'package:dart_console/dart_console.dart';

import '../main.dart';
import 'base.dart';

class UserCmd implements CommandInstance {
  PrintFn print = (dynamic msg, [bool newLine = true]) => stdout.write(msg + (newLine ? '\n' : ''));

  UserCmd();

  @override
  ArgParser command(ArgParser parser) {
    return parser
      ..addOption('username', abbr: 'u', help: '用户名')
      ..addOption('passwd', abbr: 'p', help: '密码')
      ..addOption('token', abbr: 't', help: 'API Key')
      ..addFlag('code', negatable: false, help: '需要二次验证码');
  }

  @override
  Future<void> exec(ArgResults args, PrintFn print) async {
    var username = args['username'] ?? Instance.cfg.config['auth']?['username'];
    String? token = args['token'];
    var code = args['code'];
    var passwd = args['passwd'];

    this.print = print;
    if (username == Instance.cfg.config['auth']?['username'] &&
        token == null &&
        Instance.cfg.config['auth']?['token'] != null) {
      token = (Instance.cfg.config['auth']?['token'] as String).trim().replaceAll('\n', '');
    }

    if (token != null && token.isNotEmpty) {
      Instance.get.token = token;
      var info = await Instance.get.user.info();
      Instance.cfg.set('auth', {'token': token.replaceAll('\n', ''), 'username': info.userName});
    } else if (username != null || code) {
      setCurrentPage(CommandPage.user);

      if (!await login(username, passwd, code)) {
        exit(0);
      }
    }

    if (Instance.get.isLogin) {
      var info = await Instance.get.user.info();
      print('欢迎回来！ ${info.name}~');
      Instance.cfg.save();
    }
  }

  @override
  Future<bool> todo(String command) async {
    if (command.trim().isEmpty) return false;
    var argv = command.trim().split(' ');
    switch (argv[0]) {
      case ':login':
        {
          String username = '', passwd = '';
          if (argv.length > 1) {
            username = argv[1];
          }
          if (argv.length > 2) {
            passwd = argv[2];
          }
          if (await login(username, passwd)) {
            await Instance.get.user.info();
            page(':page user');
          }
          break;
        }
      case ':user':
        {
          page(':page user ${argv.length > 1 ? argv[1] : ''}');
          break;
        }
      case ':help':
        {
          print('''${Command.bold}用户模块命令${Command.restore}
:page user <username> 查看用户信息
:login <username> <passwd> 登录/切换账号
:user <username> 查看用户信息
''');
          break;
        }
      default:
        {
          return false;
        }
    }
    return true;
  }

  @override
  Future<bool> page(String command) async {
    print('${Command.clearScreen}${Command.moveTo(0, 0)}');
    final commands = command.trim().split(' ');
    UserInfo info = UserInfo();
    if (commands.length > 2 && commands[2].isNotEmpty) {
      info = await Instance.get.getUser(commands[2]);
    } else if (!Instance.get.isLogin) {
      return await login();
    } else {
      info = Instance.get.user.current;
    }

    var vip = await Instance.get.vipInfo(info.oId);
    if (vip.state) {
      print('${Command.from('#FFD700').color}💎 ${vip.lvCode} (${vip.expiresDate})${Command.restore}\n');
    }

    print('''
${Command.bold}${info.allName}${Command.restore} - [${info.isOnline ? '${Command.from('#00FF00').color}在线${Command.restore}' : '${Command.from('#AAAAAA').color}离线${Command.restore}'}]
${Command.from('#AAAAAA').color}👤${info.role}${Command.restore}\t${Command.bold}No.${Command.restore}${info.userNo}\t
💲${info.point}\t📍${info.city.isEmpty ? '' : info.city}
${info.intro.isEmpty ? '' : '📝 ${Command.italic}${info.intro}${Command.restore}'}
${info.userURL.isEmpty ? '' : '🔗 ${Command.bold}${info.userURL}${Command.restore}'}''');
    for (var i = 0; i < info.sysMetal.length; i++) {
      print('🏅 ${info.sysMetal[i].name}   ', false);
      if (i % 5 == 4) print('');
    }

    print('');

    if (Instance.get.isLogin && Instance.get.user.current.userName == info.userName) {
      print('当前活跃度：${await Instance.get.user.liveness().catchError((_) => 0.0)}\n');
    }
    return false;
  }

  Future<bool> login([String? username, String? passwd, bool code = true]) async {
    String mfaCode = '';
    Console console = Console();

    if (username == null || username.isEmpty) {
      print('用户名: ', false);
      username = stdin.readLineSync() ?? '';
    }
    if (passwd == null || passwd.isEmpty) {
      print('密码: ', false);
      passwd = console.readLine(
            cancelOnBreak: true,
            callback: (text, lastPressed) {
              if (lastPressed.controlChar == ControlCharacter.backspace) {
                if (text.isNotEmpty) {
                  text = text.substring(0, text.length - 1);
                  console.write('\b \b');
                }
              } else {
                console.write(text.replaceAllMapped(RegExp(r'.'), (match) => '\b'));
                console.write(text.replaceAllMapped(RegExp(r'.'), (match) => '*'));
              }
            },
          ) ??
          '';
    }
    if (code) {
      print('二次验证码: ', false);
      mfaCode = console.readLine(cancelOnBreak: true, cancelOnEscape: true) ?? '';
    }
    try {
      await Instance.get
          .login(LoginData(
        username: username,
        passwd: passwd,
        mfaCode: mfaCode,
      ))
          .then((value) async {
        String token = value.trim();
        Instance.cfg.set('auth', {'token': token, 'username': username});
      }).catchError((err) {
        print('登录失败: $err');
        exit(0);
      });
    } catch (e) {
      print('登录失败: $e');
      return false;
    }
    return true;
  }
}
