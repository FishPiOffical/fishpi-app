// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml_modify/yaml_modify.dart';
import 'base.dart';

export 'package:fishpi/fishpi.dart';
export 'package:args/args.dart';

class Instance {
  static final Fishpi _fishpi = Fishpi();
  static final Config _config = Config();
  static Fishpi get get => _fishpi;
  static Config get cfg => _config;
}

typedef PrintFn = void Function(dynamic msg, [bool newLine]);

/// 命令行实例
abstract class CommandInstance {
  /// 注册命令行参数
  ArgParser command(ArgParser parser);

  /// 执行命令行参数
  Future<void> exec(ArgResults args, PrintFn print);

  /// 执行输入命令
  Future<bool> todo(String command);

  /// 执行切页命令
  Future<bool> page(String command);
}

ArgParser registerCommand(List<CommandInstance> register) {
  var parser = ArgParser();
  for (var item in register) {
    parser = item.command(parser);
  }
  return parser;
}

class Config {
  Map config = {};
  String path =
      p.join(File(Platform.script.toFilePath()).parent.path, 'config.yaml');
  Config([String? path]) {
    if (path != null && path.isNotEmpty) this.path = path;
    load();
  }

  Map load() {
    final file = File(path);
    if (!file.existsSync()) {
      return config;
    }
    config = Map.from(loadYaml(file.readAsStringSync()));
    return config;
  }

  Map save() {
    final file = File(path);
    file.writeAsStringSync(toYamlString(config));
    return config;
  }

  dynamic set(String key, dynamic data) {
    dynamic cfg;
    if (data is Map) {
      cfg = Map.from(config[key] ?? {});
      data.forEach((k, v) {
        cfg[k] = v;
      });
    } else {
      cfg = data;
    }
    config[key] = cfg;
    return cfg;
  }
}

String htmlToText(String html, {String? userName}) {
  return html
      .replaceAllMapped(
          RegExp(r'@<a [^>]*?>([^<]*?)</a>'), (match) => '@${match.group(1)}')
      .replaceAllMapped(
          RegExp(r'<a [^>]*?href="([^"]*?)"[^>]*?>([^<]*?)</a>'),
          (match) =>
              '[${match.group(2)}](${(match.group(1) ?? '').startsWith('https://fishpi.cn/forward?goto=') ? Uri.decodeFull(match.group(1)?.substring((match.group(1)?.indexOf('goto=') ?? 0) + 5) ?? '') : match.group(1)})')
      .replaceAllMapped(
          RegExp(r'<a [^>]*?>([^<]*?)</a>'), (match) => match.group(1) ?? '')
      .replaceAllMapped(
          RegExp(r'<blockquote[^>]*?>'),
          (match) =>
              '${Command.from('#AAAAAA').color}${Command.from('#131415').back}\n${Command.italic}')
      .replaceAllMapped(
          RegExp(r'</blockquote>'), (match) => '${Command.restore}\n')
      .replaceAllMapped(RegExp(r'<li[^>]*?>'), (match) => '- ')
      .replaceAllMapped(RegExp(r'</li>'), (match) => '')
      .replaceAllMapped(
          RegExp(r'<pre[^>]*?>\s*<code[^>]*?>'),
          (match) =>
              '\n${Command.from('#9dd96f').color}${Command.italic}${Command.bold}')
      .replaceAllMapped(
          RegExp(r'</code></pre>'), (match) => '${Command.restore}\n')
      .replaceAllMapped(
          RegExp(r'<code[^>]*?>'),
          (match) =>
              '${Command.from('#444444').back}${Command.italic}${Command.bold} ')
      .replaceAllMapped(RegExp(r'</code>'), (match) => ' ${Command.restore}')
      .replaceAllMapped(
          RegExp(r'<img\s+alt="([^"]*?)"\s+class="emoji"([^>]*?>)'),
          (match) => '[${match.group(1)}]')
      .replaceAllMapped(RegExp(r'<img\s+src="([^"]*?)"\s+alt="图片表情"([^>]*?>)'),
          (match) => '[动画表情]')
      .replaceAllMapped(
          RegExp(r'<img\s+src="([^"]*?)"([^>]*?>)'), (match) => '[图片]')
      .replaceAllMapped(RegExp(r'<audio[^>]*?>.*?<\/audio>'), (match) => '[音乐]')
      .replaceAllMapped(RegExp(r'<video[^>]*?>.*?<\/video>'), (match) => '[视频]')
      .replaceAllMapped(RegExp(r'<(\w+)>(.*?)<\/\1>'),
          (match) => '<span>${match.group(2)}</span>')
      .replaceAllMapped(RegExp(r'<iframe.*?<\/iframe>'), (match) => '[内联网页]')
      .replaceAllMapped(RegExp(r'<(\/)*[^>]*?>'), (match) => '')
      .replaceAllMapped(
          RegExp('@$userName'),
          (match) =>
              '${Command.reverse}@${Command.underline}$userName${Command.restore}')
      .replaceAllMapped(
          RegExp(r'@([^<]*?)( |$)'),
          (match) =>
              '${Command.bold}@${match.group(1)}${Command.restore}${match.group(2)}');
}

class Command {
  int r = 255;
  int g = 255;
  int b = 255;

  Command([this.r = 255, this.g = 255, this.b = 255]);
  Command.from(String rgb) {
    if (rgb.startsWith('#')) {
      r = int.parse(rgb.substring(1, 3), radix: 16);
      g = int.parse(rgb.substring(3, 5), radix: 16);
      b = int.parse(rgb.substring(5, 7), radix: 16);
    } else if (rgb.startsWith('rgb')) {
      final rgbaExp = RegExp(r'rgba*\((\d+),\s*(\d+),\s*(\d+)');
      final match = rgbaExp.firstMatch(rgb);
      if (match != null) {
        r = int.parse(match.group(1)!);
        g = int.parse(match.group(2)!);
        b = int.parse(match.group(3)!);
      }
    }
  }

  get color => '\x1B[38;2;$r;$g;${b}m';
  get back => '\x1B[48;2;$r;$g;${b}m';

  static get restore => '\x1B[0m';
  static get bold => '\x1B[1m';
  static get rbold => '\x1B[21m';
  static get italic => '\x1B[3m';
  static get ritalic => '\x1B[23m';
  static get underline => '\x1B[4m';
  static get runderline => '\x1B[24m';
  static get blink => '\x1B[5m';
  static get rblink => '\x1B[25m';
  static get reverse => '\x1B[7m';
  static get rreverse => '\x1B[27m';
  static get hide => '\x1B[8m';
  static get rhide => '\x1B[28m';
  static get strike => '\x1B[9m';
  static get rstrike => '\x1B[29m';

  static get clearLine => '\x1B[2K';
  static get clearScreen => '\x1B[2J';

  static String moveUp([int n = 1]) => '\x1B[${n}A';
  static String moveDown([int n = 1]) => '\x1B[${n}B';
  static String moveRight([int n = 1]) => '\x1B[${n}C';
  static String moveLeft([int n = 1]) => '\x1B[${n}D';
  static String moveTo(int x, int y) => '\x1B[$y;${x}H';

  @override
  String toString() {
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }
}
