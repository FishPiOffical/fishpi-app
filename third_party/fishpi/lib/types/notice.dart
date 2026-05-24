import 'types.dart';

/// 数据类型
class DataType {
  /// 文章
  static const article = 0;

  /// 评论
  static const comment = 1;

  /// @
  static const at = 2;

  /// 被评论
  static const commented = 3;

  /// 关注者
  static const followingUser = 4;

  /// 积分 - 充值
  static const pointCharge = 5;

  /// 积分 - 转账
  static const pointTransfer = 6;

  /// 积分 - 文章打赏
  static const pointArticleReward = 7;

  /// 积分 - 评论感谢
  static const pointCommentThank = 8;

  /// 同城广播
  static const broadcast = 9;

  /// 积分 - 交易
  static const pointExchange = 10;

  /// 积分 - 滥用扣除
  static const abusePointDeduct = 11;

  /// 积分 - 文章被感谢
  static const pointArticleThank = 12;

  /// 回复
  static const reply = 13;

  /// 使用邀请码
  static const invitecodeUsed = 14;

  /// 系统公告 - 文章
  static const sysAnnounceArticle = 15;

  /// 系统公告 - 新用户
  static const sysAnnounceNewUser = 16;

  /// 新的关注者
  static const newFollower = 17;

  /// 邀请链接
  static const invitationLinkUsed = 18;

  /// 系统通知 - 角色变化
  static const sysAnnounceRoleChanged = 19;

  /// 关注的文章更新
  static const followingArticleUpdate = 20;

  /// 关注的文章评论
  static const followingArticleComment = 21;

  /// 积分 - 文章优选
  static const pointPerfectArticle = 22;

  /// 文章新的被关注者
  static const articleNewFollower = 23;

  /// 文章新的关注者
  static const articleNewWatcher = 24;

  /// 评论点赞
  static const commentVoteUp = 25;

  /// 评论点踩
  static const commentVoteDown = 26;

  /// 文章被点赞
  static const articleVoteUp = 27;

  /// 文章被点踩
  static const articleVoteDown = 28;

  /// 积分 - 评论被接受
  static const pointCommentAccept = 33;

  /// 积分 - 举报处理
  static const pointReportHandled = 36;

  /// 聊天室 @
  static const chatRoomAt = 38;

  /// 专属红包提醒
  static const redPacket = 39;
}

/// 通知类型
class NoticeType {
  /// 积分
  static const point = 'point';

  /// 评论
  static const commented = 'commented';

  /// 回复
  static const reply = 'reply';

  /// 提及我的
  static const at = 'at';

  /// 我关注的
  static const following = 'following';

  /// 同城
  static const broadcast = 'broadcast';

  /// 系统
  static const system = 'sys-announce';
}

/// 通知数
class NoticeCount {
  /// 用户是否启用 Web 通知
  bool notifyStatus;

  /// 未读通知数
  int count;

  /// 未读回复通知数
  int reply;

  /// 未读积分通知数
  int point;

  /// 未读 @ 通知数
  int at;

  /// 未读同城通知数
  int broadcast;

  /// 未读系统通知数
  int sysAnnounce;

  /// 未读关注者通知数
  int newFollower;

  /// 未读关注通知数
  int following;

  /// 未读评论通知数
  int commented;

  NoticeCount({
    required this.notifyStatus,
    required this.count,
    required this.reply,
    required this.point,
    required this.at,
    required this.broadcast,
    required this.sysAnnounce,
    required this.newFollower,
    required this.following,
    required this.commented,
  });

  NoticeCount.from(Map<String, dynamic> data)
      : notifyStatus = data['userNotifyStatus'] != 0,
        count = data['unreadNotificationCnt'] ?? 0,
        reply = data['unreadReplyNotificationCnt'] ?? 0,
        point = data['unreadPointNotificationCnt'] ?? 0,
        at = data['unreadAtNotificationCnt'] ?? 0,
        broadcast = data['unreadBroadcastNotificationCnt'] ?? 0,
        sysAnnounce = data['unreadSysAnnounceNotificationCnt'] ?? 0,
        newFollower = data['unreadNewFollowerNotificationCnt'] ?? 0,
        following = data['unreadFollowingNotificationCnt'] ?? 0,
        commented = data['unreadCommentedNotificationCnt'] ?? 0;

  toJson() => {
        'userNotifyStatus': notifyStatus,
        'unreadNotificationCnt': count,
        'unreadReplyNotificationCnt': reply,
        'unreadPointNotificationCnt': point,
        'unreadAtNotificationCnt': at,
        'unreadBroadcastNotificationCnt': broadcast,
        'unreadSysAnnounceNotificationCnt': sysAnnounce,
        'unreadNewFollowerNotificationCnt': newFollower,
        'unreadFollowingNotificationCnt': following,
        'unreadCommentedNotificationCnt': commented,
      };

  @override
  toString() =>
      "NoticeCount{userNotifyStatus=$notifyStatus, unreadNotificationCnt=$count, unreadReplyNotificationCnt=$reply, unreadPointNotificationCnt=$point, unreadAtNotificationCnt=$at, unreadBroadcastNotificationCnt=$broadcast, unreadSysAnnounceNotificationCnt=$sysAnnounce, unreadNewFollowerNotificationCnt=$newFollower, unreadFollowingNotificationCnt=$following, unreadCommentedNotificationCnt=$commented}";
}

/// 积分通知
class NoticePoint {
  /// 通知 id
  String oId;

  /// 数据 id
  String dataId;

  /// 用户 id
  String userId;

  /// 数据类型
  int dataType;

  /// 通知描述
  String description;

  /// 是否已读
  bool hasRead;

  /// 创建日期
  String createTime;

  NoticePoint({
    this.oId = '',
    this.dataId = '',
    this.userId = '',
    this.dataType = 0, // Assuming DataType.DEFAULT as default value
    this.description = '',
    this.hasRead = false,
    this.createTime = '',
  });

  NoticePoint.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        dataId = data['dataId'] ?? '',
        userId = data['userId'] ?? '',
        dataType = data['dataType'] ??
            0, // Assuming DataType is an enum and 0 is the default value
        description = data['description'] ?? '',
        hasRead = data['hasRead'] ?? false,
        createTime = data['createTime'] ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'dataId': dataId,
        'userId': userId,
        'dataType': dataType,
        'description': description,
        'hasRead': hasRead,
        'createTime': createTime,
      };

  @override
  String toString() {
    return 'NoticePoint{oId: $oId, dataId: $dataId, userId: $userId, dataType: $dataType, description: $description, hasRead: $hasRead, createTime: $createTime}';
  }
}

/// 评论/回帖通知
class NoticeComment {
  /// 通知 id
  String oId;

  /// 文章标题
  String title;

  /// 文章作者
  String author;

  /// 作者头像
  String thumbnailURL;

  /// 文章类型
  ArticleType type;

  /// 是否精选
  bool perfect;

  /// 评论内容
  String content;

  /// 评论地址
  String sharpURL;

  /// 是否已读
  bool hasRead;

  /// 评论时间
  String createTime;

  NoticeComment({
    this.oId = '',
    this.title = '',
    this.author = '',
    this.thumbnailURL = '',
    this.type = ArticleType.Normal,
    this.perfect = false,
    this.content = '',
    this.sharpURL = '',
    this.hasRead = false,
    this.createTime = '',
  });

  NoticeComment.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        title = data['commentArticleTitle'] ?? '',
        author = data['commentAuthorName'] ?? '',
        thumbnailURL = data['commentAuthorThumbnailURL'] ?? '',
        type = ArticleType.values[data['commentArticleType'] ?? 0],
        perfect = (data['commentArticlePerfect'] ?? 0) == 1,
        content = data['commentContent'] ?? '',
        sharpURL = data['commentSharpURL'] ?? '',
        hasRead = data['hasRead'] ?? false,
        createTime = data['commentCreateTime'] ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'commentArticleTitle': title,
        'commentAuthorName': author,
        'commentAuthorThumbnailURL': thumbnailURL,
        'commentArticleType': type,
        'commentArticlePerfect': perfect,
        'commentContent': content,
        'commentSharpURL': sharpURL,
        'hasRead': hasRead,
        'commentCreateTime': createTime,
      };

  @override
  String toString() {
    return 'NoticeComment{oId: $oId, commentArticleTitle: $title, commentAuthorName: $author, commentAuthorThumbnailURL: $thumbnailURL, commentArticleType: $type, commentArticlePerfect: $perfect, commentContent: $content, commentSharpURL: $sharpURL, hasRead: $hasRead, commentCreateTime: $createTime}';
  }
}

/// 提到我通知
class NoticeAt {
  /// 通知 id
  String oId;

  /// 数据类型
  int dataType;

  /// 用户名
  String userName;

  /// 用户头像
  String avatarURL;

  /// 通知内容
  String content;

  /// 是否已读
  bool hasRead;

  /// 创建时间
  String createTime;

  NoticeAt({
    this.oId = '',
    this.dataType = 0,
    this.userName = '',
    this.avatarURL = '',
    this.content = '',
    this.hasRead = false,
    this.createTime = '',
  });

  NoticeAt.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        dataType = data['dataType'] ?? 0,
        userName = data['userName'] ?? '',
        avatarURL = data['userAvatarURL'] ?? '',
        content = data['content'] ?? '',
        hasRead = data['hasRead'] ?? false,
        createTime = data['createTime'] ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'dataType': dataType,
        'userName': userName,
        'userAvatarURL': avatarURL,
        'content': content,
        'hasRead': hasRead,
        'createTime': createTime,
      };

  @override
  String toString() {
    return 'NoticeAt{oId: $oId, dataType: $dataType, userName: $userName, userAvatarURL: $avatarURL, content: $content, hasRead: $hasRead, createTime: $createTime}';
  }
}

/// 关注通知
class NoticeFollow {
  /// 通知 Id
  String oId;

  /// 文章地址
  String url;

  /// 数据类型
  int dataType;

  /// 文章标题
  String title;

  /// 作者
  String author;

  /// 通知内容
  String content;

  /// 是否评论
  bool isComment;

  /// 作者头像
  String thumbnailURL;

  /// 文章评论数
  int commentCnt;

  /// 是否精选
  bool perfect;

  /// 文章标签列表
  List<ArticleTag> tagObjs;

  /// 文章标签
  String tags;

  /// 文章类型
  int type;

  /// 是否已读
  bool hasRead;

  /// 通知创建时间
  String createTime;

  NoticeFollow({
    this.oId = '',
    this.url = '',
    this.dataType = 0,
    this.title = '',
    this.author = '',
    this.content = '',
    this.isComment = false,
    this.thumbnailURL = '',
    this.commentCnt = 0,
    this.perfect = false,
    this.tagObjs = const [],
    this.tags = '',
    this.type = 0,
    this.hasRead = false,
    this.createTime = '',
  });

  NoticeFollow.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        url = data['url'] ?? '',
        dataType = data['dataType'] ?? 0,
        title = data['articleTitle'] ?? '',
        author = data['authorName'] ?? '',
        content = data['content'] ?? '',
        isComment = data['isComment'] ?? false,
        thumbnailURL = data['thumbnailURL'] ?? '',
        commentCnt = data['articleCommentCount'] ?? 0,
        perfect = (data['articlePerfect'] ?? 0) == 1,
        tagObjs = List.from(data['articleTagObjs'] ?? [])
            .map((i) => ArticleTag.from(i))
            .toList(),
        tags = data['articleTags'] ?? '',
        type = data['articleType'] ?? 0,
        hasRead = data['hasRead'] ?? false,
        createTime = data['createTime'] ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'url': url,
        'dataType': dataType,
        'articleTitle': title,
        'authorName': author,
        'content': content,
        'isComment': isComment,
        'thumbnailURL': thumbnailURL,
        'articleCommentCount': commentCnt,
        'articlePerfect': perfect ? 1 : 0,
        'articleTagObjs': tagObjs.map((i) => i.toJson()).toList(),
        'articleTags': tags,
        'articleType': type,
        'hasRead': hasRead,
        'createTime': createTime,
      };

  @override
  String toString() =>
      'NoticeFollow{oId: $oId, url: $url, dataType: $dataType, articleTitle: $title, authorName: $author, content: $content, isComment: $isComment, thumbnailURL: $thumbnailURL, articleCommentCount: $commentCnt, articlePerfect: $perfect, articleTagObjs: $tagObjs, articleTags: $tags, articleType: $type, hasRead: $hasRead, createTime: $createTime}';
}

/// 系统通知数据
class NoticeSystem {
  /// 消息的 oId
  String oId;

  /// 用户 Id
  String userId;

  /// 数据 Id
  String dataId;

  /// 数据类型
  int dataType;

  /// 消息描述
  String description;

  /// 是否已读
  bool hasRead;

  /// 创建日期
  String createTime;

  NoticeSystem({
    this.oId = '',
    this.userId = '',
    this.dataId = '',
    this.dataType = 0,
    this.description = '',
    this.hasRead = false,
    this.createTime = '',
  });

  NoticeSystem.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        userId = data['userId'] ?? '',
        dataId = data['dataId'] ?? '',
        dataType = data['dataType'] ?? 0,
        description = data['description'] ?? '',
        hasRead = data['hasRead'] ?? false,
        createTime = data['createTime'] ?? '';

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'userId': userId,
        'dataId': dataId,
        'dataType': dataType,
        'description': description,
        'hasRead': hasRead,
        'createTime': createTime,
      };

  @override
  String toString() {
    return 'NoticeSystem{oId: $oId, userId: $userId, dataId: $dataId, dataType: $dataType, description: $description, hasRead: $hasRead, createTime: $createTime}';
  }
}

/// 通知消息类型
class NoticeMsgType {
  /// 刷新通知数，需调用 Notice.count 获取明细
  static const refresh = 'refreshNotification';

  /// 全局公告
  static const warnBroadcast = 'warnBroadcast';

  static List<String> get values => [refresh, warnBroadcast];
}

/// 通知消息
class NoticeMsg {
  /// 通知类型
  String command;

  /// 通知接收者用户Id
  String userId;

  /// 全局公告内容，仅 `warnBroadcast` 有信息
  String? content;

  /// 全局公告发布者，仅 `warnBroadcast` 有信息
  String? who;

  NoticeMsg({
    this.command = NoticeMsgType.refresh,
    this.userId = '',
    this.content,
    this.who,
  });

  NoticeMsg.from(Map<String, dynamic> data)
      : command = data['command'] ?? NoticeMsgType.refresh,
        userId = data['userId'] ?? '',
        content = data['warnBroadcastText'],
        who = data['who'];

  Map<String, dynamic> toJson() => {
        'command': command,
        'userId': userId,
        'warnBroadcastText': content,
        'who': who,
      };

  @override
  String toString() {
    return 'NoticeMsg{command: $command, userId: $userId, warnBroadcastText: $content, who: $who}';
  }
}

/// NoticePoint | NoticeComment | NoticeAt | NoticeFollow | NoticeSystem 列表，根据 NoticeType 变化
typedef NoticeList = List<dynamic>;

/// 通知监听
typedef NoticeListener = void Function(NoticeMsg msg);
