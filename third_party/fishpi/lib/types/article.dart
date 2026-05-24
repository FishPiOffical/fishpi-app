// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:fishpi/src/utils.dart';

import 'types.dart';

/// 发帖信息
class ArticlePost {
  /// 帖子标题
  String title;

  /// 帖子内容
  String content;

  /// 帖子标签
  String tags;

  /// 是否允许评论
  bool commentable;

  /// 是否通知帖子关注者
  bool notifyFollowers;

  /// 帖子类型，ArticleType
  int type;

  /// 是否在列表展示
  int showInList;

  /// 打赏内容
  String? rewardContent;

  /// 打赏积分
  String? rewardPoint;

  /// 是否匿名
  bool? anonymous;

  /// 提问悬赏积分
  int? offerPoint;

  ArticlePost({
    this.title = '',
    this.content = '',
    this.tags = '',
    this.commentable = false,
    this.notifyFollowers = false,
    this.type = 0,
    this.showInList = 0,
    this.rewardContent,
    this.rewardPoint,
    this.anonymous,
    this.offerPoint,
  });

  ArticlePost.from(Map<String, dynamic> data)
      : title = data['articleTitle'] ?? '',
        content = data['articleContent'] ?? '',
        tags = data['articleTags'] ?? '',
        commentable = data['articleCommentable'] ?? false,
        notifyFollowers = data['articleNotifyFollowers'] ?? false,
        type = data['articleType'] ?? 0,
        showInList = data['articleShowInList'] ?? 0,
        rewardContent = data['articleRewardContent'],
        rewardPoint = data['articleRewardPoint'],
        anonymous = data['articleAnonymous'],
        offerPoint = data['articleQnAOfferPoint'];

  Map<String, dynamic> toJson() => {
        'articleTitle': title,
        'articleContent': content,
        'articleTags': tags,
        'articleCommentable': commentable,
        'articleNotifyFollowers': notifyFollowers,
        'articleType': type,
        'articleShowInList': showInList,
        'articleRewardContent': rewardContent,
        'articleRewardPoint': rewardPoint,
        'articleAnonymous': anonymous,
        'articleQnAOfferPoint': offerPoint,
      };

  @override
  String toString() {
    return 'ArticlePost{articleTitle: $title, articleContent: $content, articleTags: $tags, articleCommentable: $commentable, articleNotifyFollowers: $notifyFollowers, articleType: $type, articleShowInList: $showInList, articleRewardContent: $rewardContent, articleRewardPoint: $rewardPoint, articleAnonymous: $anonymous, articleQnAOfferPoint: $offerPoint}';
  }
}

/// 文章标签
class ArticleTag {
  /// 标签 id
  String oId;

  /// 标签名
  String title;

  /// 标签描述
  String description;

  /// icon 地址
  String iconPath;

  /// 标签地址
  String uri;

  /// 标签自定义 CSS
  String diyCSS;

  /// 反对数
  int badCnt;

  /// 标签回帖计数
  int commentCnt;

  /// 关注数
  int followerCnt;

  /// 点赞数
  int goodCnt;

  /// 引用计数
  int referenceCnt;

  /// 标签相关链接计数
  int linkCnt;

  /// 标签 SEO 描述
  String seoDesc;

  /// 标签关键字
  String seoKeywords;

  /// 标签 SEO 标题
  String seoTitle;

  /// 标签广告内容
  String tagAd;

  /// 是否展示广告
  int showSideAd;

  /// 标签状态
  int status;

  /// 标签随机数
  double randomDouble;

  ArticleTag({
    this.oId = '',
    this.title = '',
    this.description = '',
    this.iconPath = '',
    this.uri = '',
    this.diyCSS = '',
    this.badCnt = 0,
    this.commentCnt = 0,
    this.followerCnt = 0,
    this.goodCnt = 0,
    this.referenceCnt = 0,
    this.linkCnt = 0,
    this.seoDesc = '',
    this.seoKeywords = '',
    this.seoTitle = '',
    this.tagAd = '',
    this.showSideAd = 0,
    this.status = 0,
    this.randomDouble = 0.0,
  });

  ArticleTag.from(Map<String, dynamic> data)
      : oId = data['oId'] ?? '',
        title = data['tagTitle'] ?? '',
        description = data['tagDescription'] ?? '',
        iconPath = data['tagIconPath'] ?? '',
        uri = data['tagURI'] ?? '',
        diyCSS = data['tagCSS'] ?? '',
        badCnt = data['tagBadCnt'] ?? 0,
        commentCnt = data['tagCommentCount'] ?? 0,
        followerCnt = data['tagFollowerCount'] ?? 0,
        goodCnt = data['tagGoodCnt'] ?? 0,
        referenceCnt = data['tagReferenceCount'] ?? 0,
        linkCnt = data['tagLinkCount'] ?? 0,
        seoDesc = data['tagSeoDesc'] ?? '',
        seoKeywords = data['tagSeoKeywords'] ?? '',
        seoTitle = data['tagSeoTitle'] ?? '',
        tagAd = data['tagAd'] ?? '',
        showSideAd = data['tagShowSideAd'] ?? 0,
        status = data['tagStatus'] ?? 0,
        randomDouble = data['tagRandomDouble'] ?? 0.0;

  Map<String, dynamic> toJson() => {
        'oId': oId,
        'tagTitle': title,
        'tagDescription': description,
        'tagIconPath': iconPath,
        'tagURI': uri,
        'tagCSS': diyCSS,
        'tagBadCnt': badCnt,
        'tagCommentCount': commentCnt,
        'tagFollowerCount': followerCnt,
        'tagGoodCnt': goodCnt,
        'tagReferenceCount': referenceCnt,
        'tagLinkCount': linkCnt,
        'tagSeoDesc': seoDesc,
        'tagSeoKeywords': seoKeywords,
        'tagSeoTitle': seoTitle,
        'tagAd': tagAd,
        'tagShowSideAd': showSideAd,
        'tagStatus': status,
        'tagRandomDouble': randomDouble,
      };

  @override
  String toString() =>
      'ArticleTag{oId: $oId, tagTitle: $title, tagDescription: $description, tagIconPath: $iconPath, tagURI: $uri, tagCSS: $diyCSS, tagBadCnt: $badCnt, tagCommentCount: $commentCnt, tagFollowerCount: $followerCnt, tagGoodCnt: $goodCnt, tagReferenceCount: $referenceCnt, tagLinkCount: $linkCnt, tagSeoDesc: $seoDesc, tagSeoKeywords: $seoKeywords, tagSeoTitle: $seoTitle, tagAd: $tagAd, tagShowSideAd: $showSideAd, tagStatus: $status, tagRandomDouble: $randomDouble}';
}

/// 投票状态，点赞与否
enum VoteStatus {
  /// 未投票
  normal,

  /// 点赞
  up,

  /// 点踩
  down,
}

/// 文章状态
enum ArticleStatus {
  /// 正常
  Normal,

  /// 封禁
  Ban,

  /// 锁定
  Lock,
}

/// 文章作者
class ArticleAuthor {
  /// 用户是否在线
  bool isOnline;

  /// 用户在线时长
  int onlineMinute;

  /// 是否公开积分列表
  bool pointStatus;

  /// 是否公开关注者列表
  bool followerStatus;

  /// 用户完成新手指引步数
  int guideStep;

  /// 是否公开在线状态
  bool onlineStatus;

  /// 当前连续签到起始日
  int currentCheckinStreakStart;

  /// 是否聊天室图片自动模糊
  bool isAutoBlur;

  /// 用户标签
  String tags;

  /// 是否公开回帖列表
  bool commentStatus;

  /// 用户时区
  String timezone;

  /// 用户个人主页
  String homePage;

  /// 是否启用站外链接跳转页面
  bool isEnableForwardPage;

  /// 是否公开 UA 信息
  bool userUAStatus;

  /// 自定义首页跳转地址
  String userIndexRedirectURL;

  /// 最近发帖时间
  int latestArticleTime;

  /// 标签计数
  int tagCount;

  /// 昵称
  String nickname;

  /// 回帖浏览模式
  int listViewMode;

  /// 最长连续签到
  int longestCheckinStreak;

  /// 用户头像类型
  String avatarType;

  /// 用户确认邮件发送时间
  int subMailSendTime;

  /// 用户最后更新时间
  int updateTime;

  /// userSubMailStatus
  bool subMailStatus;

  /// 是否加入积分排行
  bool isJoinPointRank;

  /// 用户最后登录时间
  int latestLoginTime;

  /// 应用角色
  int userAppRole;

  /// 头像查看模式
  int userAvatarViewMode;

  /// 用户状态
  int userStatus;

  /// 用户上次最长连续签到日期
  int longestCheckinStreakEnd;

  /// 是否公开关注帖子列表
  bool watchingArticleStatus;

  /// 上次回帖时间
  int latestCmtTime;

  /// 用户省份
  String province;

  /// 用户当前连续签到计数
  int currentCheckinStreak;

  /// 用户编号
  int userNo;

  /// 用户头像
  String avatarURL;

  /// 是否公开关注标签列表
  bool followingTagStatus;

  /// 用户语言
  String userLanguage;

  /// 是否加入消费排行
  bool isJoinUsedPointRank;

  /// 上次签到日期
  int currentCheckinStreakEnd;

  /// 是否公开收藏帖子列表
  bool followingArticleStatus;

  /// 是否启用键盘快捷键
  bool keyboardShortcutsStatus;

  /// 是否回帖后自动关注帖子
  bool replyWatchArticleStatus;

  /// 回帖浏览模式
  int commentViewMode;

  /// 是否公开清风明月列表
  bool breezemoonStatus;

  /// 用户上次签到时间
  int userCheckinTime;

  /// 用户消费积分
  int usedPoint;

  /// 是否公开发帖列表
  bool articleStatus;

  /// 用户积分
  int userPoint;

  /// 用户回帖数
  int commentCount;

  /// 用户个性签名
  String userIntro;

  /// 移动端主题
  String userMobileSkin;

  /// 分页每页条目
  int listPageSize;

  /// 文章 Id
  String oId;

  /// 用户名
  String userName;

  /// 是否公开 IP 地理信息
  bool geoStatus;

  /// 最长连续签到起始日
  int longestCheckinStreakStart;

  /// 用户主题
  String userSkin;

  /// 是否启用 Web 通知
  bool notifyStatus;

  /// 公开关注用户列表
  bool followingUserStatus;

  /// 文章数
  int articleCount;

  /// 用户角色
  String userRole;

  /// 徽章
  MetalList sysMetal;

  String get name => nickname.isEmpty ? userName : nickname;

  String get allName => nickname.isEmpty ? userName : '$nickname($userName)';

  ArticleAuthor({
    this.isOnline = false,
    this.onlineMinute = 0,
    this.pointStatus = true,
    this.followerStatus = true,
    this.guideStep = 0,
    this.onlineStatus = true,
    this.currentCheckinStreakStart = 0,
    this.isAutoBlur = false,
    this.tags = '',
    this.commentStatus = true,
    this.timezone = '',
    this.homePage = '',
    this.isEnableForwardPage = false,
    this.userUAStatus = true,
    this.userIndexRedirectURL = '',
    this.latestArticleTime = 0,
    this.tagCount = 0,
    this.nickname = '',
    this.listViewMode = 0,
    this.longestCheckinStreak = 0,
    this.avatarType = '0',
    this.subMailSendTime = 0,
    this.updateTime = 0,
    this.subMailStatus = true,
    this.isJoinPointRank = true,
    this.latestLoginTime = 0,
    this.userAppRole = 0,
    this.userAvatarViewMode = 0,
    this.userStatus = 0,
    this.longestCheckinStreakEnd = 0,
    this.watchingArticleStatus = true,
    this.latestCmtTime = 0,
    this.province = '',
    this.currentCheckinStreak = 0,
    this.userNo = 0,
    this.avatarURL = '',
    this.followingTagStatus = true,
    this.userLanguage = '',
    this.isJoinUsedPointRank = true,
    this.currentCheckinStreakEnd = 0,
    this.followingArticleStatus = true,
    this.keyboardShortcutsStatus = true,
    this.replyWatchArticleStatus = true,
    this.commentViewMode = 0,
    this.breezemoonStatus = true,
    this.userCheckinTime = 0,
    this.usedPoint = 0,
    this.articleStatus = true,
    this.userPoint = 0,
    this.commentCount = 0,
    this.userIntro = '',
    this.userMobileSkin = '',
    this.listPageSize = 0,
    this.oId = '',
    this.userName = '',
    this.geoStatus = true,
    this.longestCheckinStreakStart = 0,
    this.userSkin = '',
    this.notifyStatus = true,
    this.followingUserStatus = true,
    this.articleCount = 0,
    this.userRole = '',
    this.sysMetal = const [],
  });

  ArticleAuthor.from(Map<String, dynamic> data)
      : isOnline = data['userOnlineFlag'] ?? false,
        onlineMinute = data['onlineMinute'] ?? 0,
        pointStatus = (data['userPointStatus'] ?? 0) == 0,
        followerStatus = (data['userFollowerStatus'] ?? 0) == 0,
        guideStep = data['userGuideStep'] ?? 0,
        onlineStatus = (data['userOnlineStatus'] ?? 0) == 0,
        currentCheckinStreakStart = data['userCurrentCheckinStreakStart'] ?? 0,
        isAutoBlur = (data['chatRoomPictureStatus'] ?? 0) == 1,
        tags = data['userTags'] ?? '',
        commentStatus = (data['userCommentStatus'] ?? 0) == 0,
        timezone = data['userTimezone'] ?? '',
        homePage = data['userURL'] ?? '',
        isEnableForwardPage = (data['userForwardPageStatus'] ?? 0) == 1,
        userUAStatus = (data['userUAStatus'] ?? 0) == 0,
        userIndexRedirectURL = data['userIndexRedirectURL'] ?? '',
        latestArticleTime = data['userLatestArticleTime'] ?? 0,
        tagCount = data['userTagCount'] ?? 0,
        nickname = data['userNickname'] ?? '',
        listViewMode = data['userListViewMode'] ?? 0,
        longestCheckinStreak = data['userLongestCheckinStreak'] ?? 0,
        avatarType = (data['userAvatarType'] ?? '0').toString(),
        subMailSendTime = data['userSubMailSendTime'] ?? 0,
        updateTime = data['userUpdateTime'] ?? 0,
        subMailStatus = (data['userSubMailStatus'] ?? 0) == 0,
        isJoinPointRank = (data['userJoinPointRank'] ?? 0) == 0,
        latestLoginTime = data['userLatestLoginTime'] ?? 0,
        userAppRole = data['userAppRole'] ?? 0,
        userAvatarViewMode = data['userAvatarViewMode'] ?? 0,
        userStatus = data['userStatus'] ?? 0,
        longestCheckinStreakEnd = data['userLongestCheckinStreakEnd'] ?? 0,
        watchingArticleStatus = (data['userWatchingArticleStatus'] ?? 0) == 0,
        latestCmtTime = data['userLatestCmtTime'] ?? 0,
        province = data['userProvince'] ?? '',
        currentCheckinStreak = data['userCurrentCheckinStreak'] ?? 0,
        userNo = data['userNo'] ?? 0,
        avatarURL = data['userAvatarURL'] ?? '',
        followingTagStatus = (data['userFollowingTagStatus'] ?? 0) == 0,
        userLanguage = data['userLanguage'] ?? '',
        isJoinUsedPointRank = (data['userJoinUsedPointRank'] ?? 0) == 0,
        currentCheckinStreakEnd = data['userCurrentCheckinStreakEnd'] ?? 0,
        followingArticleStatus = (data['userFollowingArticleStatus'] ?? 0) == 0,
        keyboardShortcutsStatus =
            (data['userKeyboardShortcutsStatus'] ?? 0) == 0,
        replyWatchArticleStatus =
            (data['userReplyWatchArticleStatus'] ?? 0) == 0,
        commentViewMode = data['userCommentViewMode'] ?? 0,
        breezemoonStatus = (data['userBreezemoonStatus'] ?? 0) == 0,
        userCheckinTime = data['userCheckinTime'] ?? 0,
        usedPoint = data['userUsedPoint'] ?? 0,
        articleStatus = (data['userArticleStatus'] ?? 0) == 0,
        userPoint = data['userPoint'] ?? 0,
        commentCount = data['userCommentCount'] ?? 0,
        userIntro = data['userIntro'] ?? '',
        userMobileSkin = data['userMobileSkin'] ?? '',
        listPageSize = data['userListPageSize'] ?? 0,
        oId = data['oId'] ?? '',
        userName = data['userName'] ?? '',
        geoStatus = (data['userGeoStatus'] ?? 0) == 0,
        longestCheckinStreakStart = data['userLongestCheckinStreakStart'] ?? 0,
        userSkin = data['userSkin'] ?? '',
        notifyStatus = (data['userNotifyStatus'] ?? 0) == 0,
        followingUserStatus = (data['userFollowingUserStatus'] ?? 0) == 0,
        articleCount = data['userArticleCount'] ?? 0,
        userRole = data['userRole'] ?? '',
        sysMetal = List.from(data['sysMetal'] ?? [])
            .map((e) => analyzeMetalAttr(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'userOnlineFlag': isOnline,
        'onlineMinute': onlineMinute,
        'userPointStatus': pointStatus ? 0 : 1,
        'userFollowerStatus': followerStatus ? 0 : 1,
        'userGuideStep': guideStep,
        'userOnlineStatus': onlineStatus ? 0 : 1,
        'userCurrentCheckinStreakStart': currentCheckinStreakStart,
        'chatRoomPictureStatus': isAutoBlur,
        'userTags': tags,
        'userCommentStatus': commentStatus ? 0 : 1,
        'userTimezone': timezone,
        'userURL': homePage,
        'userForwardPageStatus': isEnableForwardPage,
        'userUAStatus': userUAStatus ? 0 : 1,
        'userIndexRedirectURL': userIndexRedirectURL,
        'userLatestArticleTime': latestArticleTime,
        'userTagCount': tagCount,
        'userNickname': nickname,
        'userListViewMode': listViewMode,
        'userLongestCheckinStreak': longestCheckinStreak,
        'userAvatarType': avatarType,
        'userSubMailSendTime': subMailSendTime,
        'userUpdateTime': updateTime,
        'userSubMailStatus': subMailStatus ? 0 : 1,
        'userJoinPointRank': isJoinPointRank ? 0 : 1,
        'userLatestLoginTime': latestLoginTime,
        'userAppRole': userAppRole,
        'userAvatarViewMode': userAvatarViewMode,
        'userStatus': userStatus,
        'userLongestCheckinStreakEnd': longestCheckinStreakEnd,
        'userWatchingArticleStatus': watchingArticleStatus ? 0 : 1,
        'userLatestCmtTime': latestCmtTime,
        'userProvince': province,
        'userCurrentCheckinStreak': currentCheckinStreak,
        'userNo': userNo,
        'userAvatarURL': avatarURL,
        'userFollowingTagStatus': followingTagStatus ? 0 : 1,
        'userLanguage': userLanguage,
        'userJoinUsedPointRank': isJoinUsedPointRank ? 0 : 1,
        'userCurrentCheckinStreakEnd': currentCheckinStreakEnd,
        'userFollowingArticleStatus': followingArticleStatus ? 0 : 1,
        'userKeyboardShortcutsStatus': keyboardShortcutsStatus ? 0 : 1,
        'userReplyWatchArticleStatus': replyWatchArticleStatus ? 0 : 1,
        'userCommentViewMode': commentViewMode,
        'userBreezemoonStatus': breezemoonStatus ? 0 : 1,
        'userCheckinTime': userCheckinTime,
        'userUsedPoint': usedPoint,
        'userArticleStatus': articleStatus ? 0 : 1,
        'userPoint': userPoint,
        'userCommentCount': commentCount,
        'userIntro': userIntro,
        'userMobileSkin': userMobileSkin,
        'userListPageSize': listPageSize,
        'oId': oId,
        'userName': userName,
        'userGeoStatus': geoStatus ? 0 : 1,
        'userLongestCheckinStreakStart': longestCheckinStreakStart,
        'userSkin': userSkin,
        'userNotifyStatus': notifyStatus ? 0 : 1,
        'userFollowingUserStatus': followingUserStatus ? 0 : 1,
        'userArticleCount': articleCount,
        'userRole': userRole,
        'sysMetal': sysMetal.map((e) => e.toJson()).toList(),
      };
}

/// 评论作者
typedef CommentAuthor = ArticleAuthor;

/// 文章评论
class ArticleComment {
  /// 是否优评
  bool isNice;

  /// 评论创建时间字符串
  String createTimeStr;

  /// 评论作者 id
  String authorId;

  /// 评论分数
  String score;

  /// 评论创建时间
  String createTime;

  /// 评论作者头像
  String authorURL;

  /// 评论状态
  VoteStatus vote;

  /// 评论引用数
  int revisionCount;

  /// 评论经过时间
  String timeAgo;

  /// 回复评论 id
  String replyId;

  /// 徽章
  List<Metal> sysMetal;

  /// 点赞数
  int goodCnt;

  /// 评论是否可见
  bool visible;

  /// 文章 id
  String articleId;

  /// 评论感谢数
  int rewardedCnt;

  /// 评论地址
  String sharpURL;

  /// 是否匿名
  bool isAnonymous;

  /// 评论回复数
  int replyCnt;

  /// 评论 id
  String oId;

  /// 评论内容
  String content;

  /// 评论状态
  ArticleStatus status;

  /// 评论作者
  CommentAuthor commenter = CommentAuthor();

  /// 评论作者用户名
  String author;

  /// 评论感谢数
  int thankCnt;

  /// 评论点踩数
  int badCnt;

  /// 是否已感谢
  bool rewarded;

  /// 评论作者头像
  String thumbnailURL;

  /// 评论音频地址
  String audioURL;

  /// 评论是否采纳，1 表示采纳
  int offered;

  ArticleComment(
      {this.isNice = false,
      this.createTimeStr = '',
      this.authorId = '',
      this.score = '',
      this.createTime = '',
      this.authorURL = '',
      this.vote = VoteStatus.normal,
      this.revisionCount = 0,
      this.timeAgo = '',
      this.replyId = '',
      this.sysMetal = const [],
      this.goodCnt = 0,
      this.visible = true,
      this.articleId = '',
      this.rewardedCnt = 0,
      this.sharpURL = '',
      this.isAnonymous = false,
      this.replyCnt = 0,
      this.oId = '',
      this.content = '',
      this.status = ArticleStatus.Normal,
      this.author = '',
      this.thankCnt = 0,
      this.badCnt = 0,
      this.rewarded = false,
      this.thumbnailURL = '',
      this.audioURL = '',
      this.offered = 0,
      commenter}) {
    this.commenter = commenter ?? CommentAuthor();
  }

  ArticleComment.from(Map<String, dynamic> data)
      : isNice = data['commentNice'] ?? false,
        createTimeStr = data['commentCreateTimeStr'] ?? '',
        authorId = data['commentAuthorId'] ?? '',
        score = (data['commentScore'] ?? 0).toString(),
        createTime = data['commentCreateTime'] ?? '',
        authorURL = data['commentAuthorURL'] ?? '',
        vote = VoteStatus.values[(data['commentVote'] ?? 0) + 1],
        revisionCount = data['commentRevisionCount'] ?? 0,
        timeAgo = data['timeAgo'] ?? '',
        replyId = data['commentOriginalCommentId'] ?? '',
        sysMetal = List.from(data['sysMetal'])
            .map((e) => analyzeMetalAttr(e))
            .toList(),
        goodCnt = data['commentGoodCnt'] ?? 0,
        visible = (data['commentVisible'] ?? 0) == 0,
        articleId = data['commentOnArticleId'] ?? '',
        rewardedCnt = data['rewardedCnt'] ?? 0,
        sharpURL = data['commentSharpURL'] ?? '',
        isAnonymous = (data['commentAnonymous'] ?? 0) == 1,
        replyCnt = data['commentReplyCnt'] ?? 0,
        oId = data['oId'] ?? '',
        content = data['commentContent'] ?? '',
        status = ArticleStatus.values[data['commentStatus'] ?? 0],
        author = data['commentAuthorName'] ?? '',
        thankCnt = data['commentThankCnt'] ?? 0,
        badCnt = data['commentBadCnt'] ?? 0,
        rewarded = data['rewarded'] ?? false,
        thumbnailURL = data['commentAuthorThumbnailURL'] ?? '',
        audioURL = data['commentAudioURL'] ?? '',
        offered = data['commentQnAOffered'] ?? 0,
        commenter = CommentAuthor.from(data['commenter'] ?? {});

  Map<String, dynamic> toJson() => {
        'commentNice': isNice,
        'commentCreateTimeStr': createTimeStr,
        'commentAuthorId': authorId,
        'commentScore': score,
        'commentCreateTime': createTime,
        'commentAuthorURL': authorURL,
        'commentVote': vote.index,
        'commentRevisionCount': revisionCount,
        'timeAgo': timeAgo,
        'commentOriginalCommentId': replyId,
        'sysMetal': sysMetal.map((e) => e.toJson()).toList(),
        'commentGoodCnt': goodCnt,
        'commentVisible': visible ? 0 : 1,
        'commentOnArticleId': articleId,
        'rewardedCnt': rewardedCnt,
        'commentSharpURL': sharpURL,
        'commentAnonymous': isAnonymous,
        'commentReplyCnt': replyCnt,
        'oId': oId,
        'commentContent': content,
        'commentStatus': status.index,
        'commentAuthorName': author,
        'commentThankCnt': thankCnt,
        'commentBadCnt': badCnt,
        'rewarded': rewarded,
        'commentAuthorThumbnailURL': thumbnailURL,
        'commentAudioURL': audioURL,
        'commentQnAOffered': offered,
        'commenter': commenter.toJson(),
      };
}

/// 分页信息
class Pagination {
  /// 总分页数
  int count;

  /// 建议分页页码
  List<int> pageNums;

  Pagination({
    this.count = 0,
    this.pageNums = const [],
  });

  Pagination.from(Map<String, dynamic> data)
      : count = data['paginationPageCount'] ?? 0,
        pageNums = List.from(data['paginationPageNums'] ?? []);

  Map<String, dynamic> toJson() => {
        'paginationPageCount': count,
        'paginationPageNums': pageNums,
      };
}

/// 帖子类型
enum ArticleType {
  Normal,
  Private,
  Broadcast,
  Thought,
  Unknown,
  Question,
}

/// 文章详情
class ArticleDetail {
  /// 是否在列表展示
  bool showInList;

  /// 文章创建时间
  String createTime;

  /// 发布者Id
  String authorId;

  /// 反对数
  int badCnt;

  /// 文章最后评论时间
  String latestCmtTime;

  /// 赞同数
  int goodCnt;

  /// 悬赏积分
  int offerPoint;

  /// 文章缩略图
  String thumbnailURL;

  /// 置顶序号
  int stickRemains;

  /// 发布时间简写
  String timeAgo;

  /// 文章更新时间
  String updateTimeStr;

  /// 作者用户名
  String authorName;

  /// 文章类型
  ArticleType type;

  /// 是否悬赏
  bool offered;

  /// 文章创建时间字符串
  String createTimeStr;

  /// 文章浏览数
  int viewCnt;

  /// 作者头像缩略图
  String thumbnailURL20;

  /// 关注数
  int watchCnt;

  /// 文章预览内容
  String previewContent;

  /// 文章标题
  String titleEmoj;

  /// 文章标题（Unicode 的 Emoji）
  String titleEmojUnicode;

  /// 文章标题
  String title;

  /// 作者头像缩略图
  String thumbnailURL48;

  /// 文章评论数
  int commentCnt;

  /// 收藏数
  int collectCnt;

  /// 文章最后评论者
  String latestCmterName;

  /// 文章标签
  String tags;

  /// 文章 id
  String oId;

  /// 最后评论时间简写
  String cmtTimeAgo;

  /// 是否置顶
  int stick;

  /// 文章标签信息
  List<ArticleTag> tagObjs;

  /// 文章最后评论时间
  String latestCmtTimeStr;

  /// 是否匿名
  bool anonymous;

  /// 文章感谢数
  int thankCnt;

  /// 文章更新时间
  String updateTime;

  /// 文章状态
  ArticleStatus status;

  /// 文章点击数
  int heat;

  /// 文章是否优选
  bool perfect;

  /// 作者头像缩略图
  String thumbnailURL210;

  /// 文章固定链接
  String permalink;

  /// 作者用户信息
  ArticleAuthor author = ArticleAuthor();

  /// 文章感谢数
  int thankedCnt;

  /// 文章匿名浏览量
  int anonymousView;

  /// 文章浏览量简写
  String viewCntFormat;

  /// 文章是否启用评论
  bool commentable;

  /// 是否已打赏
  bool rewarded;

  /// 打赏人数
  int rewardedCnt;

  /// 文章打赏积分
  int rewardPoint;

  /// 是否已收藏
  bool isFollowing;

  /// 是否已关注
  bool isWatching;

  /// 是否是我的文章
  bool isMyArticle;

  /// 是否已感谢
  bool thanked;

  /// 编辑器类型
  int editorType;

  /// 文章音频地址
  String audioURL;

  /// 文章目录 HTML
  String table;

  /// 文章内容 HTML
  String content;

  /// 文章内容 Markdown
  String source;

  /// 文章缩略图
  String img1URL;

  /// 文章点赞状态
  VoteStatus vote;

  /// 文章随机数
  double randomDouble;

  /// 作者签名
  String authorIntro;

  /// 发布城市
  String city;

  /// 发布者 IP
  String IP;

  /// 作者首页地址
  String authorURL;

  /// 推送 Email 推送顺序
  int pushOrder;

  /// 打赏内容
  String rewardContent;

  /// reddit分数
  String redditScore;

  /// 评论分页信息
  Pagination? pagination;

  /// 评论是否可见
  bool commentViewable;

  /// 文章修改次数
  int revisionCount;

  /// 文章的评论
  List<ArticleComment> comments;

  /// 文章最佳评论
  List<ArticleComment> niceComments;

  ArticleDetail({
    this.showInList = false,
    this.createTime = '',
    this.authorId = '',
    this.badCnt = 0,
    this.latestCmtTime = '',
    this.goodCnt = 0,
    this.offerPoint = 0,
    this.thumbnailURL = '',
    this.stickRemains = 0,
    this.timeAgo = '',
    this.updateTimeStr = '',
    this.authorName = '',
    this.type = ArticleType.Normal,
    this.offered = false,
    this.createTimeStr = '',
    this.viewCnt = 0,
    this.thumbnailURL20 = '',
    this.watchCnt = 0,
    this.previewContent = '',
    this.titleEmoj = '',
    this.titleEmojUnicode = '',
    this.title = '',
    this.thumbnailURL48 = '',
    this.commentCnt = 0,
    this.collectCnt = 0,
    this.latestCmterName = '',
    this.tags = '',
    this.oId = '',
    this.cmtTimeAgo = '',
    this.stick = 0,
    this.tagObjs = const [],
    this.latestCmtTimeStr = '',
    this.anonymous = false,
    this.thankCnt = 0,
    this.updateTime = '',
    this.status = ArticleStatus.Normal,
    this.heat = 0,
    this.perfect = false,
    this.thumbnailURL210 = '',
    this.permalink = '',
    articleAuthor,
    this.thankedCnt = 0,
    this.anonymousView = 0,
    this.viewCntFormat = '',
    this.commentable = false,
    this.rewarded = false,
    this.rewardedCnt = 0,
    this.rewardPoint = 0,
    this.isFollowing = false,
    this.isWatching = false,
    this.isMyArticle = false,
    this.thanked = false,
    this.editorType = 0,
    this.audioURL = '',
    this.table = '',
    this.content = '',
    this.source = '',
    this.img1URL = '',
    this.vote = VoteStatus.normal,
    this.randomDouble = 0.0,
    this.authorIntro = '',
    this.city = '',
    this.IP = '',
    this.authorURL = '',
    this.pushOrder = 0,
    this.rewardContent = '',
    this.redditScore = '',
    this.pagination,
    this.commentViewable = false,
    this.revisionCount = 0,
    this.comments = const [],
    this.niceComments = const [],
  }) {
    author = articleAuthor ?? ArticleAuthor();
  }

  ArticleDetail.from(Map<String, dynamic> data)
      : showInList = (data['articleShowInList'] ?? 0) == 1,
        createTime = data['articleCreateTime'] ?? '',
        authorId = data['articleAuthorId'] ?? '',
        badCnt = data['articleBadCnt'] ?? 0,
        latestCmtTime = data['articleLatestCmtTime'] ?? '',
        goodCnt = data['articleGoodCnt'] ?? 0,
        offerPoint = data['articleQnAOfferPoint'] ?? 0,
        thumbnailURL = data['articleThumbnailURL'] ?? '',
        stickRemains = data['articleStickRemains'] ?? 0,
        timeAgo = data['timeAgo'] ?? '',
        updateTimeStr = data['articleUpdateTimeStr'] ?? '',
        authorName = data['articleAuthorName'] ?? '',
        type = ArticleType.values[data['articleType'] ?? 0],
        offered = data['offered'] ?? false,
        createTimeStr = data['articleCreateTimeStr'] ?? '',
        viewCnt = data['articleViewCount'] ?? 0,
        thumbnailURL20 = data['articleAuthorThumbnailURL20'] ?? '',
        watchCnt = data['articleWatchCnt'] ?? 0,
        previewContent = data['articlePreviewContent'] ?? '',
        titleEmoj = data['articleTitleEmoj'] ?? '',
        titleEmojUnicode = data['articleTitleEmojUnicode'] ?? '',
        title = data['articleTitle'] ?? '',
        thumbnailURL48 = data['articleAuthorThumbnailURL48'] ?? '',
        commentCnt = data['articleCommentCount'] ?? 0,
        collectCnt = data['articleCollectCnt'] ?? 0,
        latestCmterName = data['articleLatestCmterName'] ?? '',
        tags = data['articleTags'] ?? '',
        oId = data['oId'] ?? '',
        cmtTimeAgo = data['cmtTimeAgo'] ?? '',
        stick = data['articleStick'] ?? 0,
        tagObjs = List.from(data['articleTagObjs'] ?? [])
            .map((e) => ArticleTag.from(e))
            .toList(),
        latestCmtTimeStr = data['articleLatestCmtTimeStr'] ?? '',
        anonymous = (data['articleAnonymous'] ?? 0) == 1,
        thankCnt = data['articleThankCnt'] ?? 0,
        updateTime = data['articleUpdateTime'] ?? '',
        status = ArticleStatus.values[data['articleStatus'] ?? 0],
        heat = data['articleHeat'] ?? 0,
        perfect = (data['articlePerfect'] ?? 0) == 1,
        thumbnailURL210 = data['articleAuthorThumbnailURL210'] ?? '',
        permalink = data['articlePermalink'] ?? '',
        author = ArticleAuthor.from(data['articleAuthor'] ?? {}),
        thankedCnt = data['thankedCnt'] ?? 0,
        anonymousView = data['articleAnonymousView'] ?? 0,
        viewCntFormat = data['articleViewCntDisplayFormat'] ?? '',
        commentable = data['articleCommentable'] ?? false,
        rewarded = data['rewarded'] ?? false,
        rewardedCnt = data['rewardedCnt'] ?? 0,
        rewardPoint = data['articleRewardPoint'] ?? 0,
        isFollowing = data['isFollowing'] ?? false,
        isWatching = data['isWatching'] ?? false,
        isMyArticle = data['isMyArticle'] ?? false,
        thanked = data['thanked'] ?? false,
        editorType = data['articleEditorType'] ?? 0,
        audioURL = data['articleAudioURL'] ?? '',
        table = data['articleToC'] ?? '',
        content = data['articleContent'] ?? '',
        source = data['articleOriginalContent'] ?? '',
        img1URL = data['articleImg1URL'] ?? '',
        vote = VoteStatus.values[(data['articleVote'] ?? 0) + 1],
        randomDouble = data['articleRandomDouble'] ?? 0.0,
        authorIntro = data['articleAuthorIntro'] ?? '',
        city = data['articleCity'] ?? '',
        IP = data['articleIP'] ?? '',
        authorURL = data['articleAuthorURL'] ?? '',
        pushOrder = data['articlePushOrder'] ?? 0,
        rewardContent = data['articleRewardContent'] ?? '',
        redditScore = (data['redditScore'] ?? 0).toString(),
        pagination = data['pagination'] != null
            ? Pagination.from(data['pagination'])
            : null,
        commentViewable = data['discussionViewable'] ?? false,
        revisionCount = data['articleRevisionCount'] ?? 0,
        comments = List.from(data['articleComments'] ?? [])
            .map((e) => ArticleComment.from(e))
            .toList(),
        niceComments = List.from(data['articleNiceComments'] ?? [])
            .map((e) => ArticleComment.from(e))
            .toList();

  Map<String, dynamic> toJson() => {
        'articleShowInList': showInList,
        'articleCreateTime': createTime,
        'articleAuthorId': authorId,
        'articleBadCnt': badCnt,
        'articleLatestCmtTime': latestCmtTime,
        'articleGoodCnt': goodCnt,
        'articleQnAOfferPoint': offerPoint,
        'articleThumbnailURL': thumbnailURL,
        'articleStickRemains': stickRemains,
        'timeAgo': timeAgo,
        'articleUpdateTimeStr': updateTimeStr,
        'articleAuthorName': authorName,
        'articleType': type.index,
        'offered': offered,
        'articleCreateTimeStr': createTimeStr,
        'articleViewCount': viewCnt,
        'articleAuthorThumbnailURL20': thumbnailURL20,
        'articleWatchCnt': watchCnt,
        'articlePreviewContent': previewContent,
        'articleTitleEmoj': titleEmoj,
        'articleTitleEmojUnicode': titleEmojUnicode,
        'articleTitle': title,
        'articleAuthorThumbnailURL48': thumbnailURL48,
        'articleCommentCount': commentCnt,
        'articleCollectCnt': collectCnt,
        'articleLatestCmterName': latestCmterName,
        'articleTags': tags,
        'oId': oId,
        'cmtTimeAgo': cmtTimeAgo,
        'articleStick': stick,
        'articleTagObjs': tagObjs.map((e) => e.toJson()).toList(),
        'articleLatestCmtTimeStr': latestCmtTimeStr,
        'articleAnonymous': anonymous,
        'articleThankCnt': thankCnt,
        'articleUpdateTime': updateTime,
        'articleStatus': status.index,
        'articleHeat': heat,
        'articlePerfect': perfect,
        'articleAuthorThumbnailURL210': thumbnailURL210,
        'articlePermalink': permalink,
        'articleAuthor': author.toJson(),
        'thankedCnt': thankedCnt,
        'articleAnonymousView': anonymousView,
        'articleViewCntDisplayFormat': viewCntFormat,
        'articleCommentable': commentable,
        'rewarded': rewarded,
        'rewardedCnt': rewardedCnt,
        'articleRewardPoint': rewardPoint,
        'isFollowing': isFollowing,
        'isWatching': isWatching,
        'isMyArticle': isMyArticle,
        'thanked': thanked,
        'articleEditorType': editorType,
        'articleAudioURL': audioURL,
        'articleToC': table,
        'articleContent': content,
        'articleOriginalContent': source,
        'articleImg1URL': img1URL,
        'articleVote': vote.index,
        'articleRandomDouble': randomDouble,
        'articleAuthorIntro': authorIntro,
        'articleCity': city,
        'articleIP': IP,
        'articleAuthorURL': authorURL,
        'articlePushOrder': pushOrder,
        'articleRewardContent': rewardContent,
        'redditScore': redditScore,
        'pagination': pagination?.toJson(),
        'discussionViewable': commentViewable,
        'articleRevisionCount': revisionCount,
        'articleComments': comments.map((e) => e.toJson()).toList(),
        'articleNiceComments': niceComments.map((e) => e.toJson()).toList(),
      };
}

/// 文章列表
class ArticleList {
  List<ArticleDetail> list = []; // 文章列表
  Pagination pagination = Pagination(); // 分页信息
  ArticleTag? tag; // 标签信息，仅查询标签下文章列表有效

  ArticleList({articles, pagination, tag}) {
    list = articles ?? [];
    this.pagination = pagination ?? Pagination();
    this.tag = tag ?? ArticleTag();
  }

  // 从 JSON 数据构造对象
  ArticleList.from(Map<String, dynamic> data) {
    if (data['articles'] != null) {
      list = [];
      data['articles'].forEach((v) {
        list.add(ArticleDetail.from(v));
      });
    }
    pagination = data['pagination'] != null
        ? Pagination.from(data['pagination'])
        : Pagination();
    tag = data['tag'] != null ? ArticleTag.from(data['tag']) : null;
  }

  // 将对象转换为 JSON 数据
  Map<String, dynamic> toJson() => {
        'articles': list.map((e) => e.toJson()).toList(),
        'pagination': pagination.toJson(),
        'tag': tag?.toJson(),
      };
}

/// 帖子列表查询类型
class ArticleListType {
  /// 最近
  static const String Recent = 'recent';

  /// 热门
  static const String Hot = 'hot';

  /// 点赞
  static const String Good = 'good';

  /// 最近回复
  static const String Reply = 'reply';

  /// 优选，需包含标签
  static const String Perfect = 'perfect';

  static String toCode(String type) {
    switch (type) {
      case Recent:
        return '';
      case Hot:
        return '/hot';
      case Good:
        return '/good';
      case Reply:
        return '/reply';
      case Perfect:
        return '/perfect';
      default:
        return '';
    }
  }

  static List<String> get values => [Recent, Hot, Good, Reply, Perfect];
}

/// 评论发布
class CommentPost {
  /// 文章 Id
  String articleId;

  /// 是否匿名评论
  bool isAnonymous;

  /// 评论是否楼主可见
  bool isVisible;

  /// 评论内容
  String content;

  /// 回复评论 Id
  String replyId;

  CommentPost({
    this.articleId = '',
    this.isAnonymous = false,
    this.isVisible = false,
    this.content = '',
    this.replyId = '',
  });

  // 从 JSON 数据构造对象
  CommentPost.from(Map<String, dynamic> json)
      : articleId = json['articleId'],
        isAnonymous = json['commentAnonymous'],
        isVisible = json['commentVisible'],
        content = json['commentContent'],
        replyId = json['commentOriginalCommentId'];

  // 将对象转换为 JSON 数据
  Map<String, dynamic> toJson() => {
        'articleId': articleId,
        'commentAnonymous': isAnonymous,
        'commentVisible': isVisible,
        'commentContent': content,
        'commentOriginalCommentId': replyId,
      };
}
