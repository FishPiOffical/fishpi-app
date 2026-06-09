import 'package:fishpi/types/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FishPi SDK model safe parse', () {
    test('用户信息兼容字符串数字和字符串布尔', () {
      final user = UserInfo.from({
        'oId': 100,
        'userNo': 200,
        'userName': 300,
        'userNickname': 400,
        'userOnlineFlag': 'true',
        'userPoint': '10',
        'userAppRole': '1',
        'followingUserCount': '2',
        'followerCount': '3',
        'onlineMinute': '4.0',
        'allMetalOwned': null,
        'sysMetal': null,
      });

      expect(user.oId, '100');
      expect(user.userNo, '200');
      expect(user.userName, '300');
      expect(user.nickname, '400');
      expect(user.isOnline, isTrue);
      expect(user.point, 10);
      expect(user.appRole, UserAppRole.Artist);
      expect(user.followingCnt, 2);
      expect(user.followerCnt, 3);
      expect(user.onlineMinute, 4);
    });

    test('通知模型兼容字符串计数、布尔和空标签列表', () {
      final count = NoticeCount.from({
        'userNotifyStatus': '1',
        'unreadNotificationCnt': '9',
        'unreadReplyNotificationCnt': '1',
        'unreadPointNotificationCnt': '2',
        'unreadAtNotificationCnt': '3',
        'unreadBroadcastNotificationCnt': '4',
        'unreadSysAnnounceNotificationCnt': '5',
        'unreadNewFollowerNotificationCnt': '6',
        'unreadFollowingNotificationCnt': '7',
        'unreadCommentedNotificationCnt': '8',
      });
      final follow = NoticeFollow.from({
        'oId': 1,
        'dataType': '20',
        'articleTitle': 2,
        'isComment': 'false',
        'articleCommentCount': '12',
        'articlePerfect': '1',
        'articleTagObjs': null,
        'articleType': '5',
        'hasRead': 'true',
      });

      expect(count.notifyStatus, isTrue);
      expect(count.count, 9);
      expect(count.reply, 1);
      expect(count.commented, 8);
      expect(follow.oId, '1');
      expect(follow.dataType, 20);
      expect(follow.title, '2');
      expect(follow.isComment, isFalse);
      expect(follow.commentCnt, 12);
      expect(follow.perfect, isTrue);
      expect(follow.tagObjs, isEmpty);
      expect(follow.type, 5);
      expect(follow.hasRead, isTrue);
    });

    test('通用结果、举报和上传模型兼容混合类型字段', () {
      final result = ResponseResult.from({'code': '0', 'msg': 1});
      final report = Report.from({
        'reportDataId': 2,
        'reportDataType': '3',
        'reportType': '8',
        'reportMemo': 9,
      });
      final upload = UploadResult.from({
        'errFiles': [1, 'bad.png'],
        'succMap': {'a.png': 123},
      });

      expect(result.success, isTrue);
      expect(result.msg, '1');
      expect(report.reportDataId, '2');
      expect(report.reportDataType, ReportDataType.chatroom);
      expect(report.reportType, ReportType.other);
      expect(report.reportMemo, '9');
      expect(upload.errs, ['1', 'bad.png']);
      expect(upload.success.single.filename, 'a.png');
      expect(upload.success.single.url, '123');
    });

    test('聊天室、红包和弹幕模型兼容字符串数字与非字符串字段', () {
      final chat = ChatNotice.from({
        'command': 1,
        'userId': 2,
        'preview': 3,
        'senderAvatar': 4,
        'senderUserName': 5,
      });
      final roomMessage = ChatRoomMessage.from({
        'oId': 1,
        'userOId': '2',
        'userName': 3,
        'userNickname': 4,
        'userAvatarURL': 5,
        'client': 'Web',
        'content': '[music]{"source":123,"title":456}[/music]',
        'time': 6,
      });
      final status = RedPacketStatusMsg.from({
        'oId': 1,
        'count': '2',
        'got': '1.0',
        'whoGive': 3,
        'whoGot': 4,
        'userAvatarURL20': 5,
      });
      final barrager = BarragerMsg.from({
        'userName': 1,
        'barragerContent': 2,
        'barragerColor': 3,
      });

      expect(chat.command, '1');
      expect(chat.userId, '2');
      expect(chat.preview, '3');
      expect(roomMessage.oId, '1');
      expect(roomMessage.userOId, 2);
      expect(roomMessage.userName, '3');
      expect(roomMessage.nickname, '4');
      expect(roomMessage.avatarURL, '5');
      expect(roomMessage.time, '6');
      expect(roomMessage.music?.source, '123');
      expect(roomMessage.music?.title, '456');
      expect(status.oId, '1');
      expect(status.count, 2);
      expect(status.got, 1);
      expect(status.whoGive, '3');
      expect(status.whoGot, '4');
      expect(status.avatarURL20, '5');
      expect(barrager.userName, '1');
      expect(barrager.barragerContent, '2');
      expect(barrager.barragerColor, '3');
    });

    test('聊天室节点、禁言、天气和音乐模型兜底异常结构', () {
      final nodeInfo = ChatRoomNodeInfo.from({
        'data': 1,
        'msg': 2,
        'avaliable': [
          {'node': 1, 'name': 2, 'online': '3'},
          'bad-item',
        ],
      });
      final mute = MuteItem.from({
        'time': '60',
        'userAvatarURL': 1,
        'userName': 2,
        'userNickname': 3,
      });
      final weather = WeatherMsg.from({
        't': 1,
        'st': 2,
        'data': [
          {'date': 3, 'weatherCode': 4, 'min': '5.5', 'max': '6.5'},
        ],
      });
      final music = MusicMsg.from({
        'type': 1,
        'source': 2,
        'coverURL': 3,
        'title': 4,
        'from': 5,
      });

      expect(nodeInfo.recommend.node, '1');
      expect(nodeInfo.recommend.name, '2');
      expect(nodeInfo.recommend.online, 3);
      expect(nodeInfo.avaliable, hasLength(1));
      expect(mute.time, 60);
      expect(mute.avatarURL, '1');
      expect(mute.userName, '2');
      expect(mute.nickname, '3');
      expect(weather.city, '1');
      expect(weather.description, '2');
      expect(weather.data.single.date, '3');
      expect(weather.data.single.code, '4');
      expect(weather.data.single.min, 5.5);
      expect(weather.data.single.max, 6.5);
      expect(music.type, '1');
      expect(music.source, '2');
      expect(music.coverURL, '3');
      expect(music.title, '4');
      expect(music.from, '5');
    });

    test('清风明月和摸鱼办模型兼容空值与字符串数字', () {
      final breezemoon = BreezemoonContent.from({
        'breezemoonAuthorName': 1,
        'oId': null,
        'breezemoonAuthorThumbnailURL48': 2,
        'breezemoonContent': 3,
      });
      final game = MoFishGame.from({
        'userName': 1,
        'stage': 2,
        'time': '30',
      });
      final ip = UserIP.from({
        'userLatestLoginIp': 1,
        'userId': 2,
      });
      final bag = UserBag.from({
        'checkin1day': '1',
        'checkin2days': '2',
        'patchCheckinCard': '3.0',
        'metalTicket': true,
      });

      expect(breezemoon.authorName, '1');
      expect(breezemoon.oId, '');
      expect(breezemoon.thumbnailURL48, '2');
      expect(breezemoon.content, '3');
      expect(game.userName, '1');
      expect(game.stage, '2');
      expect(game.time, 30);
      expect(ip.latestLoginIP, '1');
      expect(ip.userId, '2');
      expect(bag.checkin1day, 1);
      expect(bag.checkin2days, 2);
      expect(bag.patchCheckinCard, 3);
      expect(bag.metalTicket, 1);
    });
  });
}
