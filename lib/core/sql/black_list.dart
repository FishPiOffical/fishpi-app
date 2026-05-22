import 'package:hive/hive.dart';

class BlackList {
  static Box? msgBox;

  static Future<void> init() async {
    await _box();
  }

  static get blackList => getAllUser();

  static getAllUser() async {
    List<BlackUser> list = [];
    var lists = (await _box()).values.toList();
    for (var item in lists) {
      list.add(BlackUser.fromJson(item));
    }
    return list;
  }

  static getOneUser(String oId) async {
    return await (await _box()).get(oId);
  }

  static addUser(BlackUser user) async {
    return await (await _box()).put(user.oId, user.toJson());
  }

  static removeUser(String oId) async {
    return await (await _box()).delete(oId);
  }

  static clear() async {
    return await (await _box()).clear();
  }

  static Future<void> dispose() async {
    final box = msgBox;
    if (box != null && box.isOpen) {
      await box.close();
    }
    msgBox = null;
  }

  static Future<Box> _box() async {
    final box = msgBox;
    if (box != null && box.isOpen) return box;
    msgBox = await Hive.openBox('blackList');
    return msgBox!;
  }
}

class BlackUser {
  String? oId;
  String? userName;
  String? avatarURL;

  BlackUser({this.oId, this.userName, this.avatarURL});

  BlackUser.fromJson(Map<String, dynamic> json) {
    oId = json['oId'];
    userName = json['userName'];
    avatarURL = json['avatarURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['oId'] = oId;
    data['userName'] = userName;
    data['avatarURL'] = avatarURL;
    return data;
  }
}
