// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:fishpi/src/utils.dart';
import 'package:fishpi/src/json_safe.dart' as json_safe;

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
      : title = json_safe.readString(data['articleTitle']),
        content = json_safe.readString(data['articleContent']),
        tags = json_safe.readString(data['articleTags']),
        commentable = json_safe.readBool(data['articleCommentable']),
        notifyFollowers = json_safe.readBool(data['articleNotifyFollowers']),
        type = json_safe.readInt(data['articleType']),
        showInList = json_safe.readInt(data['articleShowInList']),
        rewardContent = data['articleRewardContent']?.toString(),
        rewardPoint = data['articleRewardPoint']?.toString(),
        anonymous = json_safe.readBoolOrNull(data['articleAnonymous']),
        offerPoint = data.containsKey('articleQnAOfferPoint')
            ? json_safe.readInt(data['articleQnAOfferPoint'])
            : null;

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
      : oId = json_safe.readString(data['oId']),
        title = json_safe.readString(data['tagTitle']),
        description = json_safe.readString(data['tagDescription']),
        iconPath = json_safe.readString(data['tagIconPath']),
        uri = json_safe.readString(data['tagURI']),
        diyCSS = json_safe.readString(data['tagCSS']),
        badCnt = json_safe.readInt(data['tagBadCnt']),
        commentCnt = json_safe.readInt(data['tagCommentCount']),
        followerCnt = json_safe.readInt(data['tagFollowerCount']),
        goodCnt = json_safe.readInt(data['tagGoodCnt']),
        referenceCnt = json_safe.readInt(data['tagReferenceCount']),
        linkCnt = json_safe.readInt(data['tagLinkCount']),
        seoDesc = json_safe.readString(data['tagSeoDesc']),
        seoKeywords = json_safe.readString(data['tagSeoKeywords']),
        seoTitle = json_safe.readString(data['tagSeoTitle']),
        tagAd = json_safe.readString(data['tagAd']),
        showSideAd = json_safe.readInt(data['tagShowSideAd']),
        status = json_safe.readInt(data['tagStatus']),
        randomDouble = json_safe.readDouble(data['tagRandomDouble']);

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

ArticleStatus _readArticleStatus(dynamic value) {
  return json_safe.readEnum(
    ArticleStatus.values,
    value,
    fallback: ArticleStatus.Normal,
  );
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
      : isOnline = json_safe.readBool(data['userOnlineFlag']),
        onlineMinute = json_safe.readInt(data['onlineMinute']),
        pointStatus = json_safe.readInt(data['userPointStatus']) == 0,
        followerStatus = json_safe.readInt(data['userFollowerStatus']) == 0,
        guideStep = json_safe.readInt(data['userGuideStep']),
        onlineStatus = json_safe.readInt(data['userOnlineStatus']) == 0,
        currentCheckinStreakStart =
            json_safe.readInt(data['userCurrentCheckinStreakStart']),
        isAutoBlur = json_safe.readInt(data['chatRoomPictureStatus']) == 1,
        tags = json_safe.readString(data['userTags']),
        commentStatus = json_safe.readInt(data['userCommentStatus']) == 0,
        timezone = json_safe.readString(data['userTimezone']),
        homePage = json_safe.readString(data['userURL']),
        isEnableForwardPage =
            json_safe.readInt(data['userForwardPageStatus']) == 1,
        userUAStatus = json_safe.readInt(data['userUAStatus']) == 0,
        userIndexRedirectURL =
            json_safe.readString(data['userIndexRedirectURL']),
        latestArticleTime = json_safe.readInt(data['userLatestArticleTime']),
        tagCount = json_safe.readInt(data['userTagCount']),
        nickname = json_safe.readString(data['userNickname']),
        listViewMode = json_safe.readInt(data['userListViewMode']),
        longestCheckinStreak =
            json_safe.readInt(data['userLongestCheckinStreak']),
        avatarType =
            json_safe.readString(data['userAvatarType'], fallback: '0'),
        subMailSendTime = json_safe.readInt(data['userSubMailSendTime']),
        updateTime = json_safe.readInt(data['userUpdateTime']),
        subMailStatus = json_safe.readInt(data['userSubMailStatus']) == 0,
        isJoinPointRank = json_safe.readInt(data['userJoinPointRank']) == 0,
        latestLoginTime = json_safe.readInt(data['userLatestLoginTime']),
        userAppRole = json_safe.readInt(data['userAppRole']),
        userAvatarViewMode = json_safe.readInt(data['userAvatarViewMode']),
        userStatus = json_safe.readInt(data['userStatus']),
        longestCheckinStreakEnd =
            json_safe.readInt(data['userLongestCheckinStreakEnd']),
        watchingArticleStatus =
            json_safe.readInt(data['userWatchingArticleStatus']) == 0,
        latestCmtTime = json_safe.readInt(data['userLatestCmtTime']),
        province = json_safe.readString(data['userProvince']),
        currentCheckinStreak =
            json_safe.readInt(data['userCurrentCheckinStreak']),
        userNo = json_safe.readInt(data['userNo']),
        avatarURL = json_safe.readString(data['userAvatarURL']),
        followingTagStatus =
            json_safe.readInt(data['userFollowingTagStatus']) == 0,
        userLanguage = json_safe.readString(data['userLanguage']),
        isJoinUsedPointRank =
            json_safe.readInt(data['userJoinUsedPointRank']) == 0,
        currentCheckinStreakEnd =
            json_safe.readInt(data['userCurrentCheckinStreakEnd']),
        followingArticleStatus =
            json_safe.readInt(data['userFollowingArticleStatus']) == 0,
        keyboardShortcutsStatus =
            json_safe.readInt(data['userKeyboardShortcutsStatus']) == 0,
        replyWatchArticleStatus =
            json_safe.readInt(data['userReplyWatchArticleStatus']) == 0,
        commentViewMode = json_safe.readInt(data['userCommentViewMode']),
        breezemoonStatus = json_safe.readInt(data['userBreezemoonStatus']) == 0,
        userCheckinTime = json_safe.readInt(data['userCheckinTime']),
        usedPoint = json_safe.readInt(data['userUsedPoint']),
        articleStatus = json_safe.readInt(data['userArticleStatus']) == 0,
        userPoint = json_safe.readInt(data['userPoint']),
        commentCount = json_safe.readInt(data['userCommentCount']),
        userIntro = json_safe.readString(data['userIntro']),
        userMobileSkin = json_safe.readString(data['userMobileSkin']),
        listPageSize = json_safe.readInt(data['userListPageSize']),
        oId = json_safe.readString(data['oId']),
        userName = json_safe.readString(data['userName']),
        geoStatus = json_safe.readInt(data['userGeoStatus']) == 0,
        longestCheckinStreakStart =
            json_safe.readInt(data['userLongestCheckinStreakStart']),
        userSkin = json_safe.readString(data['userSkin']),
        notifyStatus = json_safe.readInt(data['userNotifyStatus']) == 0,
        followingUserStatus =
            json_safe.readInt(data['userFollowingUserStatus']) == 0,
        articleCount = json_safe.readInt(data['userArticleCount']),
        userRole = json_safe.readString(data['userRole']),
        sysMetal = json_safe
            .readList(data['sysMetal'])
            .whereType<Map>()
            .map((e) => analyzeMetalAttr(Map<String, dynamic>.from(e)))
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
      : isNice = json_safe.readBool(data['commentNice']),
        createTimeStr = json_safe.readString(data['commentCreateTimeStr']),
        authorId = json_safe.readString(data['commentAuthorId']),
        score = (data['commentScore'] ?? 0).toString(),
        createTime = json_safe.readString(data['commentCreateTime']),
        authorURL = json_safe.readString(data['commentAuthorURL']),
        vote = _readVoteStatus(data['commentVote']),
        revisionCount = json_safe.readInt(data['commentRevisionCount']),
        timeAgo = json_safe.readString(data['timeAgo']),
        replyId = json_safe.readString(data['commentOriginalCommentId']),
        sysMetal = json_safe
            .readList(data['sysMetal'])
            .whereType<Map>()
            .map((e) => analyzeMetalAttr(Map<String, dynamic>.from(e)))
            .toList(),
        goodCnt = json_safe.readInt(data['commentGoodCnt']),
        visible = json_safe.readInt(data['commentVisible']) == 0,
        articleId = json_safe.readString(data['commentOnArticleId']),
        rewardedCnt = json_safe.readInt(data['rewardedCnt']),
        sharpURL = json_safe.readString(data['commentSharpURL']),
        isAnonymous = json_safe.readInt(data['commentAnonymous']) == 1,
        replyCnt = json_safe.readInt(data['commentReplyCnt']),
        oId = json_safe.readString(data['oId']),
        content = json_safe.readString(data['commentContent']),
        status = _readArticleStatus(data['commentStatus']),
        author = json_safe.readString(data['commentAuthorName']),
        thankCnt = json_safe.readInt(data['commentThankCnt']),
        badCnt = json_safe.readInt(data['commentBadCnt']),
        rewarded = json_safe.readBool(data['rewarded']),
        thumbnailURL = json_safe.readString(data['commentAuthorThumbnailURL']),
        audioURL = json_safe.readString(data['commentAudioURL']),
        offered = json_safe.readInt(data['commentQnAOffered']),
        commenter = CommentAuthor.from(json_safe.readMap(data['commenter']));

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
      : count = json_safe.readInt(data['paginationPageCount']),
        pageNums = json_safe
            .readList(data['paginationPageNums'])
            .map(json_safe.readInt)
            .toList();

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

ArticleType _readArticleType(dynamic value) {
  return json_safe.readEnum(
    ArticleType.values,
    value,
    fallback: ArticleType.Normal,
  );
}

VoteStatus _readVoteStatus(dynamic value) {
  return json_safe.readEnum(
    VoteStatus.values,
    value,
    fallback: VoteStatus.normal,
    offset: 1,
  );
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
      : showInList = json_safe.readInt(data['articleShowInList']) == 1,
        createTime = json_safe.readString(data['articleCreateTime']),
        authorId = json_safe.readString(data['articleAuthorId']),
        badCnt = json_safe.readInt(data['articleBadCnt']),
        latestCmtTime = json_safe.readString(data['articleLatestCmtTime']),
        goodCnt = json_safe.readInt(data['articleGoodCnt']),
        offerPoint = json_safe.readInt(data['articleQnAOfferPoint']),
        thumbnailURL = json_safe.readString(data['articleThumbnailURL']),
        stickRemains = json_safe.readInt(data['articleStickRemains']),
        timeAgo = json_safe.readString(data['timeAgo']),
        updateTimeStr = json_safe.readString(data['articleUpdateTimeStr']),
        authorName = json_safe.readString(data['articleAuthorName']),
        type = _readArticleType(data['articleType']),
        offered = json_safe.readBool(data['offered']),
        createTimeStr = json_safe.readString(data['articleCreateTimeStr']),
        viewCnt = json_safe.readInt(data['articleViewCount']),
        thumbnailURL20 =
            json_safe.readString(data['articleAuthorThumbnailURL20']),
        watchCnt = json_safe.readInt(data['articleWatchCnt']),
        previewContent = json_safe.readString(data['articlePreviewContent']),
        titleEmoj = json_safe.readString(data['articleTitleEmoj']),
        titleEmojUnicode =
            json_safe.readString(data['articleTitleEmojUnicode']),
        title = json_safe.readString(data['articleTitle']),
        thumbnailURL48 =
            json_safe.readString(data['articleAuthorThumbnailURL48']),
        commentCnt = json_safe.readInt(data['articleCommentCount']),
        collectCnt = json_safe.readInt(data['articleCollectCnt']),
        latestCmterName = json_safe.readString(data['articleLatestCmterName']),
        tags = json_safe.readString(data['articleTags']),
        oId = json_safe.readString(data['oId']),
        cmtTimeAgo = json_safe.readString(data['cmtTimeAgo']),
        stick = json_safe.readInt(data['articleStick']),
        tagObjs = json_safe
            .readList(data['articleTagObjs'])
            .whereType<Map>()
            .map((e) => ArticleTag.from(Map<String, dynamic>.from(e)))
            .toList(),
        latestCmtTimeStr =
            json_safe.readString(data['articleLatestCmtTimeStr']),
        anonymous = json_safe.readInt(data['articleAnonymous']) == 1,
        thankCnt = json_safe.readInt(data['articleThankCnt']),
        updateTime = json_safe.readString(data['articleUpdateTime']),
        status = _readArticleStatus(data['articleStatus']),
        heat = json_safe.readInt(data['articleHeat']),
        perfect = json_safe.readInt(data['articlePerfect']) == 1,
        thumbnailURL210 =
            json_safe.readString(data['articleAuthorThumbnailURL210']),
        permalink = json_safe.readString(data['articlePermalink']),
        author = ArticleAuthor.from(json_safe.readMap(data['articleAuthor'])),
        thankedCnt = json_safe.readInt(data['thankedCnt']),
        anonymousView = json_safe.readInt(data['articleAnonymousView']),
        viewCntFormat =
            json_safe.readString(data['articleViewCntDisplayFormat']),
        commentable = json_safe.readBool(data['articleCommentable']),
        rewarded = json_safe.readBool(data['rewarded']),
        rewardedCnt = json_safe.readInt(data['rewardedCnt']),
        rewardPoint = json_safe.readInt(data['articleRewardPoint']),
        isFollowing = json_safe.readBool(data['isFollowing']),
        isWatching = json_safe.readBool(data['isWatching']),
        isMyArticle = json_safe.readBool(data['isMyArticle']),
        thanked = json_safe.readBool(data['thanked']),
        editorType = json_safe.readInt(data['articleEditorType']),
        audioURL = json_safe.readString(data['articleAudioURL']),
        table = json_safe.readString(data['articleToC']),
        content = json_safe.readString(data['articleContent']),
        source = json_safe.readString(data['articleOriginalContent']),
        img1URL = json_safe.readString(data['articleImg1URL']),
        vote = _readVoteStatus(data['articleVote']),
        randomDouble = json_safe.readDouble(data['articleRandomDouble']),
        authorIntro = json_safe.readString(data['articleAuthorIntro']),
        city = json_safe.readString(data['articleCity']),
        IP = json_safe.readString(data['articleIP']),
        authorURL = json_safe.readString(data['articleAuthorURL']),
        pushOrder = json_safe.readInt(data['articlePushOrder']),
        rewardContent = json_safe.readString(data['articleRewardContent']),
        redditScore = (data['redditScore'] ?? 0).toString(),
        pagination = data['pagination'] != null
            ? Pagination.from(json_safe.readMap(data['pagination']))
            : null,
        commentViewable = json_safe.readBool(data['discussionViewable']),
        revisionCount = json_safe.readInt(data['articleRevisionCount']),
        comments = json_safe
            .readList(data['articleComments'])
            .whereType<Map>()
            .map((e) => ArticleComment.from(Map<String, dynamic>.from(e)))
            .toList(),
        niceComments = json_safe
            .readList(data['articleNiceComments'])
            .whereType<Map>()
            .map((e) => ArticleComment.from(Map<String, dynamic>.from(e)))
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
    list = json_safe
        .readList(data['articles'])
        .whereType<Map>()
        .map((v) => ArticleDetail.from(Map<String, dynamic>.from(v)))
        .toList();
    pagination = data['pagination'] is Map
        ? Pagination.from(json_safe.readMap(data['pagination']))
        : Pagination();
    tag = data['tag'] is Map
        ? ArticleTag.from(json_safe.readMap(data['tag']))
        : null;
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
      : articleId = json_safe.readString(json['articleId']),
        isAnonymous = json_safe.readBool(json['commentAnonymous']),
        isVisible = json_safe.readBool(json['commentVisible']),
        content = json_safe.readString(json['commentContent']),
        replyId = json_safe.readString(json['commentOriginalCommentId']);

  // 将对象转换为 JSON 数据
  Map<String, dynamic> toJson() => {
        'articleId': articleId,
        'commentAnonymous': isAnonymous,
        'commentVisible': isVisible,
        'commentContent': content,
        'commentOriginalCommentId': replyId,
      };
}
