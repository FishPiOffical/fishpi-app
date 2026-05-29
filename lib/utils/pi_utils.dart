import 'dart:async';
import 'dart:math';

import 'package:fishpi_app/core/chat/chat_message_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/pi_msg_dom.dart';

class PiUtils {
  static const _tokenKey = 'token';
  static const _loginKey = 'isLogin';
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static SharedPreferences? _prefs;
  static String _cachedToken = '';

  static PiUtils? _instance;

  static Future<PiUtils?> getInstance() async {
    if (_instance == null) {
      final instance = PiUtils._();
      await instance._init();
      _instance = instance;
    }

    return _instance;
  }

  PiUtils._();

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    await _migrateLegacyTokenIfNeeded();
  }

  static String getString(String key, {String defValue = ''}) {
    if (key == _tokenKey) return _cachedToken.isEmpty ? defValue : _cachedToken;
    if (_prefs == null) return defValue;
    return _prefs?.getString(key) ?? defValue;
  }

  static Future<bool>? setString(String key, String value) {
    if (key == _tokenKey) {
      unawaited(saveToken(value));
      return Future.value(true);
    }
    if (_prefs == null) return null;
    return _prefs?.setString(key, value);
  }

  static bool getBool(String key, {bool defValue = false}) {
    if (key == _loginKey) return _cachedToken.isNotEmpty;
    if (_prefs == null) return defValue;
    return _prefs?.getBool(key) ?? defValue;
  }

  static Future<bool>? setBool(String key, bool value) {
    if (key == _loginKey) {
      if (!value) unawaited(clearToken());
      return _prefs?.setBool(key, value) ?? Future.value(true);
    }
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
    if (key == _tokenKey) {
      unawaited(clearToken());
      return Future.value(true);
    }
    if (_prefs == null) return null;
    return _prefs?.remove(key);
  }

  static Future<void> clear() async {
    _cachedToken = '';
    await Future.wait([
      _safeSecureDelete(_tokenKey),
      _prefs?.clear() ?? Future.value(false),
    ]);
  }

  static Future<void> saveToken(String token) async {
    _cachedToken = token.trim();
    if (_cachedToken.isEmpty) {
      await clearToken();
      return;
    }
    final secureSaved = await _safeSecureWrite(_tokenKey, _cachedToken);
    await Future.wait([
      secureSaved
          ? (_prefs?.remove(_tokenKey) ?? Future.value(false))
          : (_prefs?.setString(_tokenKey, _cachedToken) ?? Future.value(false)),
      _prefs?.setBool(_loginKey, true) ?? Future.value(false),
    ]);
  }

  static Future<String> getToken() async {
    if (_cachedToken.isNotEmpty) return _cachedToken;
    await _migrateLegacyTokenIfNeeded();
    return _cachedToken;
  }

  static String getCachedToken() => _cachedToken;

  static Future<bool> hasToken() async => (await getToken()).isNotEmpty;

  static Future<void> clearToken() async {
    _cachedToken = '';
    await Future.wait([
      _safeSecureDelete(_tokenKey),
      _prefs?.remove(_tokenKey) ?? Future.value(false),
      _prefs?.setBool(_loginKey, false) ?? Future.value(false),
    ]);
  }

  static Future<void> _migrateLegacyTokenIfNeeded() async {
    final secureToken = await _safeSecureRead(_tokenKey);
    if (secureToken.trim().isNotEmpty) {
      _cachedToken = secureToken.trim();
      await _prefs?.remove(_tokenKey);
      await _prefs?.setBool(_loginKey, true);
      return;
    }

    final legacyToken = _prefs?.getString(_tokenKey)?.trim() ?? '';
    if (legacyToken.isEmpty) {
      _cachedToken = '';
      await _prefs?.setBool(_loginKey, false);
      return;
    }

    _cachedToken = legacyToken;
    final secureSaved = await _safeSecureWrite(_tokenKey, legacyToken);
    await Future.wait([
      secureSaved
          ? (_prefs?.remove(_tokenKey) ?? Future.value(false))
          : Future.value(false),
      _prefs?.setBool(_loginKey, true) ?? Future.value(false),
    ]);
  }

  static Future<String> _safeSecureRead(String key) async {
    try {
      return await _secureStorage.read(key: key) ?? '';
    } catch (_) {
      return '';
    }
  }

  static Future<bool> _safeSecureWrite(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _safeSecureDelete(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return true;
    } catch (_) {
      return false;
    }
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
    RegExp regH = RegExp(r'/h/\d{1,3}');
    url = imgUrl
        .replaceAll(regW, width == null ? '' : '/w/$width')
        .replaceAll(regH, height == null ? '' : '/h/$height');
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
    final parsed = ChatMessageUtils.parseChatContent(content);
    final list = <Widget>[];
    for (var index = 0; index < parsed.elements.length; index++) {
      list.add(
        ChatMessageDomElement(
          content: parsed.elements[index],
          chat: chat,
          isSelf: isSelf,
          nodePath: '$index',
        ),
      );
    }
    if (list.isEmpty && parsed.plainText.isNotEmpty) {
      list.add(Text(parsed.plainText));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  /// 处理会话列表显示消息
  /// [content] 消息内容
  static String getConversationPreview(String content) {
    return ChatMessageUtils.conversationPreview(content);
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

  static Widget roleWidget(String role) {
    String src = '';
    switch (role) {
      case '管理员':
        src = 'assets/images/role_admin.png';
        break;
      case 'OP':
        src = 'assets/images/role_op.png';
        break;
      case '纪律委员':
        src = 'assets/images/role_manage.png';
        break;
      case '超级会员':
        src = 'assets/images/role_svip.png';
        break;
      case '成员':
        src = 'assets/images/role_user.png';
        break;
      case '新手':
        src = 'assets/images/role_new_user.png';
        break;
      default:
        src = 'assets/images/role_new_user.png';
        break;
    }
    return SizedBox(
      height: 24.h,
      child: Image.asset(
        src,
        height: 24.h,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
