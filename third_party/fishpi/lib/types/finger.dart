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
      : userName = data['userName'] ?? '',
        stage = data['stage'] ?? '',
        time = data['time'] ?? 0;

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
      : latestLoginIP = data['userLatestLoginIp'] ?? '',
        userId = data['userId'] ?? '';

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
      : checkin1day = data['checkin1day'] ?? 0,
        checkin2days = data['checkin2days'] ?? 0,
        patchCheckinCard = data['patchCheckinCard'] ?? 0,
        metalTicket = data['metalTicket'] ?? 0;

  toJson() => {
        'checkin1day': checkin1day,
        'checkin2days': checkin2days,
        'patchCheckinCard': patchCheckinCard,
        'metalTicket': metalTicket,
      };
}
