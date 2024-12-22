import 'package:fishpi/fishpi.dart';
import 'package:hive/hive.dart';

class BlackList {
  static late Box msgBox;

  static Future<void> init() async {
    msgBox = await Hive.openBox('blackList');
  }

  static get blackList => getAllUser();

  static getAllUser() async {
    List<BlackUser> list = [];
    var lists = await msgBox.values.toList();
    for (var item in lists) {
      list.add(BlackUser.fromJson(item));
    }
    return list;
  }

  static getOneUser(String oId) async {
    return await msgBox.get(oId);
  }

  static addUser(BlackUser user) async {
    return await msgBox.put(user.oId, user.toJson());
  }

  static removeUser(String oId) async {
    return await msgBox.delete(oId);
  }

  static clear() async {
    return await msgBox.clear();
  }

  static dispose() {
    msgBox.close();
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
