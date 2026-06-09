import 'package:fishpi/src/json_safe.dart' as json_safe;

/// 摸鱼大闯关信息
class MoFishGame {
  String userName;
  String stage;
  int time;

  MoFishGame({
    this.userName = '',
    this.stage = '',
    this.time = 0,
  });

  MoFishGame.from(Map data)
      : userName = json_safe.readString(data['userName']),
        stage = json_safe.readString(data['stage']),
        time = json_safe.readInt(data['time']);

  toJson() => {
        'userName': userName,
        'stage': stage,
        'time': time,
      };

  @override
  String toString() {
    return "MoFishGame{ userName=$userName, stage=$stage, time=$time }";
  }
}

/// 用户 IP 信息
class UserIP {
  String latestLoginIP;
  String userId;

  UserIP({
    this.latestLoginIP = '',
    this.userId = '',
  });

  UserIP.from(Map data)
      : latestLoginIP = json_safe.readString(data['userLatestLoginIp']),
        userId = json_safe.readString(data['userId']);

  toJson() => {
        'userLatestLoginIp': latestLoginIP,
        'userId': userId,
      };

  @override
  String toString() {
    return "UserIP{ userLatestLoginIp=$latestLoginIP, userId=$userId }";
  }
}

/// 用户背包物品类型
enum UserBagType {
  checkin1day,
  checkin2days,
  patchCheckinCard,
  metalTicket,
}

/// 用户背包信息
class UserBag {
  /// 免签卡
  int checkin1day;

  /// 两日免签卡
  int checkin2days;

  /// 补签卡
  int patchCheckinCard;

  /// 摸鱼派一周年纪念勋章领取券
  int metalTicket;

  UserBag({
    this.checkin1day = 0,
    this.checkin2days = 0,
    this.patchCheckinCard = 0,
    this.metalTicket = 0,
  });

  UserBag.from(Map data)
      : checkin1day = json_safe.readInt(data['checkin1day']),
        checkin2days = json_safe.readInt(data['checkin2days']),
        patchCheckinCard = json_safe.readInt(data['patchCheckinCard']),
        metalTicket = json_safe.readInt(data['metalTicket']);

  toJson() => {
        'checkin1day': checkin1day,
        'checkin2days': checkin2days,
        'patchCheckinCard': patchCheckinCard,
        'metalTicket': metalTicket,
      };
}
