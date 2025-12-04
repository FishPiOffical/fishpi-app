import 'dart:math';

import 'package:fishpi_app/widgets/pi_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/pi_hero.dart';
import '../widgets/pi_msg_dom.dart';

class PiUtils {
  static SharedPreferences? _prefs;

  static PiUtils? _instance;

  static Future<PiUtils?> getInstance() async {
    _instance ??= await PiUtils._()._init();

    return _instance;
  }

  PiUtils._();

  Future _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getString(String key, {String defValue = ''}) {
    if (_prefs == null) return defValue;
    return _prefs?.getString(key) ?? defValue;
  }

  static Future<bool>? setString(String key, String value) {
    if (_prefs == null) return null;
    return _prefs?.setString(key, value);
  }

  static bool getBool(String key, {bool defValue = false}) {
    if (_prefs == null) return defValue;
    return _prefs?.getBool(key) ?? defValue;
  }

  static Future<bool>? setBool(String key, bool value) {
    if (_prefs == null) return null;
    return _prefs?.setBool(key, value);
  }

  static int getInt(String key, {int defValue = 0}) {
    if (_prefs == null) return defValue;
    return _prefs?.getInt(key) ?? defValue;
  }

  static Future<bool>? setInt(String key, int value) {
    if (_prefs == null) return null;
    return _prefs?.setInt(key, value);
  }

  static double getDouble(String key, {double defValue = 0.0}) {
    if (_prefs == null) return defValue;
    return _prefs?.getDouble(key) ?? defValue;
  }

  static Future<bool>? setDouble(String key, double value) {
    if (_prefs == null) return null;
    return _prefs?.setDouble(key, value);
  }

  static Future<bool>? remove(String key) {
    if (_prefs == null) return null;
    return _prefs?.remove(key);
  }

  static Future<bool>? clear() {
    if (_prefs == null) return null;
    return _prefs?.clear();
  }

  static getBlackList() async {
    String blackInfo = getString('blackList');
    return blackInfo.split(',');
  }

  static addBlackList(String userName) async {
    List<String> blackList = await getBlackList();
    blackList.add(userName);
    setString('blackList', blackList.join(','));
  }

  static removeBlackList(String userName) async {
    List<String> blackList = await getBlackList();
    blackList.remove(userName);
    setString('blackList', blackList.join(','));
  }

  /// 聊天时间处理
  /// [time] 发消息时间
  /// 5分钟以内返回:刚刚 一天内的返回:具体时间 前一天的返回:昨天 其他的返回:日期
  static getChatTime(String time) {
    // print(time);
    try {
      var chatTime = DateTime.parse(time);
      var nowTime = DateTime.now();
      var interval =
          nowTime.millisecondsSinceEpoch - chatTime.millisecondsSinceEpoch;
      var cb =
          '${_fillZero(chatTime.month.toString(), 2)}月${_fillZero(chatTime.day.toString(), 2)}日';
      if (interval < 5 * 60 * 1000) {
        cb = '刚刚';
      } else if (interval < 24 * 60 * 60 * 1000) {
        cb =
            '${_fillZero(chatTime.hour.toString(), 2)}:${_fillZero(chatTime.minute.toString(), 2)}';
      } else if (interval < 48 * 60 * 60 * 1000) {
        cb = '昨天';
      } else {
        cb =
            '${_fillZero(chatTime.month.toString(), 2)}月${_fillZero(chatTime.day.toString(), 2)}日';
      }
      return cb;
    } catch (e) {
      return '';
    }
  }

  /// 根据长度补零
  static _fillZero(String str, int length) {
    if (str.length == length) {
      return str;
    }
    String zero = '';
    for (int i = 0; i < length - str.length; i++) {
      zero += '0';
    }
    return zero + str;
  }

  /// 处理鱼派压缩过的图片大小
  /// [imgUrl] 原图片链接
  /// [width] 处理后的宽度
  /// [height] 处理后的高度
  static filterImageWithSize(
    String imgUrl, {
    int? width,
    int? height,
  }) {
    String url = '';
    RegExp regW = RegExp(r'/w/\d{1,3}');
    RegExp regH = RegExp(r'/w/\d{1,3}');
    url = imgUrl.replaceAll(regW, '/w/$width').replaceAll(regH, '/w/$height');
    return url;
  }

  /// 处理聊天室预览数据
  /// [content] 消息内容
  static Widget getChatPreview(chat, {bool? isSelf = false}) {
    String content = "";
    if (chat is String) {
      content = chat;
    } else {
      content = chat.content;
    }
    dom.Document document = parse(content);
    List<Widget> list = [];
    //不用管它是什么，只管加一个ChatMessageDomElement widget，绘制由ChatMessageDomElement内部自己管理
    document.body?.children.forEach((item) {
      list.add(
        ChatMessageDomElement(content: item, chat: chat, isSelf: isSelf),
      );
    });
    return Column(
      children: list,
    );
  }

  /// 处理会话列表显示消息
  /// [content] 消息内容
  static String getConversationPreview(String content) {
    var document = parse(content);
    List<String> list = [];

    /// 处理文本
    var res = document.querySelectorAll("img");
    var item = res.firstOrNull;
    print(item?.localName);
    if (item == null) {
      /// 处理文本
      document.querySelectorAll("p,h1,h2,h3,h4,h5,h6,h7").forEach((element) {
        if (element.text.isEmpty || element.text == '') return;
        list.add(element.text);
      });
    } else {
      if (item.localName == "img") {
        list.add('[图片]');
      } else if (item.localName == "video") {
        list.add('[视频]');
      } else if (item.localName == 'iframe') {
        if (item.attributes['src']!.startsWith('https://fishpi.yuis.cc')) {
          list.add('[天气卡片]');
        } else if (item.attributes['src']!
            .startsWith('https://music.163.com')) {
          list.add('[音乐]');
        } else {
          list.add('[不支持的消息,请在web端查看]');
        }
      }
    }
    return list.join(' ');
  }

  // 随机字符串函数
  String generateRandomString() {
    final rnd = Random.secure();
    final length = 8 + rnd.nextInt(5); // 生成 8 到 12 位之间的随机长度
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }

  // 随机编号函数
  String generateRandomNumberString() {
    final rnd = Random.secure();
    final prefix = rnd.nextInt(90) + 10; // 生成 10 到 99 之间的前缀
    final suffix = rnd.nextInt(9000) + 1000; // 生成 1000 到 9999 之间的后缀

    return '$prefix$suffix';
  }
}
