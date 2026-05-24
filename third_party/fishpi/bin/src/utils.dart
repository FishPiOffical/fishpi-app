import 'dart:convert';
import 'dart:io';

import 'base.dart';

class UtilsCmd implements CommandInstance {
  @override
  ArgParser command(ArgParser parser) {
    return parser
      ..addOption('upload', abbr: 'f', help: '上传文件路径')
      ..addOption('origin', abbr: 'o', help: '服务器地址， 默认为 https://fishpi.cn');
  }

  @override
  Future<void> exec(ArgResults args, PrintFn print) async {
    var upload = args['upload'];
    var origin = args['origin'] ?? Instance.cfg.config['origin'];

    if (origin != null) {
      Fishpi.setOrigin(origin);
      Instance.cfg.set('origin', origin);
      Instance.cfg.save();
    }

    if (upload != null) {
      var files = upload.split(',');
      await Instance.get
          .upload(files)
          .then((value) => print(json.encode(value.toJson())))
          .catchError((err) => print(json.encode({'error': err})));
      exit(0);
    }
  }

  @override
  Future<bool> todo(String command) async {
    return false;
  }

  @override
  Future<bool> page(String command) async {
    return false;
  }
}
