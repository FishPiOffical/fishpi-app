import 'package:fishpi/fishpi.dart';
import 'package:hive/hive.dart';

class BlackList {
  static late Box msgBox;

  static Future<void> init() async {
    msgBox = await Hive.openBox('blackList');
  }

  static get blackList => getAllUser();

  static getAllUser() {
    List<UserInfo> list = [];
    var blackList = msgBox.values.toList();
    for (var item in blackList) {
      list.add(UserInfo.from(item));
    }
    return list;
  }

  static addUser(UserInfo user) async {
    return await msgBox.put(user.oId, user);
  }

  static removeUser(int index) async {
    return await msgBox.delete(index);
  }

  static dispose() {
    msgBox.close();
  }
}
