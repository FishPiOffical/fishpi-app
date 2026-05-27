import 'package:fishpi/types/chatroom.dart';
import 'package:fishpi/types/user.dart';
import 'package:fishpi_app/core/chat/chat_room_extension_runtime.dart';
import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('老扩展 JSON 迁移后只启用手动触发', () {
    final extension = ChatRoomExtension.fromJson(
      const {
        'id': 'old',
        'name': '老扩展',
        'template': 'hello',
      },
    );

    expect(extension.triggers, [ChatRoomExtensionTrigger.manual]);
    expect(extension.triggerAction, ChatRoomExtensionTriggerAction.preview);
  });

  test('模板可渲染个人数据、消息数据、图片地址、话题和时间变量', () async {
    final runtime = ChatRoomExtensionRuntime(
      userLoader: () async => UserInfo(
        userName: 'fish',
        nickname: '摸鱼',
        point: 88,
        onlineMinute: 66,
        followingCnt: 3,
        followerCnt: 5,
      ),
      livenessLoader: () async => 12.5,
      topicProvider: () => '今天吃什么',
      nowProvider: () => DateTime(2026, 5, 27, 12, 30),
    );
    const extension = ChatRoomExtension(
      name: '上下文',
      template:
          r'${me.userName}/${me.nickname}/${me.point}/${me.liveness}/${me.onlineMinute}/${me.followingCount}/${me.followerCount}/${message.preview}/${message.imageUrl}/${room.topic}/${now}',
      triggers: [ChatRoomExtensionTrigger.receiveSingleImage],
    );

    final result = await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.receiveSingleImage,
      message: ChatRoomMessage(
        content: '<p><img src="https://example.com/a.png"/></p>',
        userName: 'other',
        time: '12:00',
      ),
    );

    expect(result, isNotNull);
    expect(
      result!.text,
      contains(
        'fish/摸鱼/88/12.50/66/3/5/[图片]/https://example.com/a.png/今天吃什么/2026-05-27 12:30:00',
      ),
    );
  });

  test('发消息时触发器可以读取准备发送的内容用于小尾巴', () async {
    final runtime = ChatRoomExtensionRuntime(
      userLoader: () async => UserInfo(userName: 'fish'),
      livenessLoader: () async => 0,
      topicProvider: () => '',
    );
    const extension = ChatRoomExtension(
      name: '小尾巴',
      template: r'${message.content}\n\n-- 来自摸鱼派',
      triggers: [ChatRoomExtensionTrigger.beforeSend],
    );

    final result = await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.beforeSend,
      message: ChatRoomMessage(content: '今天也要摸鱼'),
      respectCooldown: false,
    );

    expect(result, isNotNull);
    expect(result!.text, '今天也要摸鱼\\n\\n-- 来自摸鱼派');
  });

  test('活跃度缓存 60 秒内不会重复请求', () async {
    var livenessCalls = 0;
    var now = DateTime(2026, 5, 27, 12, 0);
    final runtime = ChatRoomExtensionRuntime(
      userLoader: () async => UserInfo(userName: 'fish'),
      livenessLoader: () async {
        livenessCalls++;
        return 9;
      },
      topicProvider: () => '',
      nowProvider: () => now,
    );
    const extension = ChatRoomExtension(
      name: '活跃度',
      template: r'${me.liveness}',
      triggers: [ChatRoomExtensionTrigger.afterSend],
    );

    await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.afterSend,
    );
    await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.afterSend,
      respectCooldown: false,
    );
    now = now.add(const Duration(seconds: 61));
    await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.afterSend,
      respectCooldown: false,
    );

    expect(livenessCalls, 2);
  });

  test('收到文字和收到单图触发规则正确', () {
    expect(
      ChatRoomExtensionRuntime.triggerForReceivedMessage(
        ChatRoomMessage(content: '<p>你好</p>'),
      ),
      ChatRoomExtensionTrigger.receiveText,
    );
    expect(
      ChatRoomExtensionRuntime.triggerForReceivedMessage(
        ChatRoomMessage(content: '<p><img src="https://x.com/a.png"/></p>'),
      ),
      ChatRoomExtensionTrigger.receiveSingleImage,
    );
    expect(
      ChatRoomExtensionRuntime.triggerForReceivedMessage(
        ChatRoomMessage(content: ''),
      ),
      isNull,
    );
  });

  test('触发冷却和自动发送保护生效', () async {
    var now = DateTime(2026, 5, 27, 12, 0);
    final runtime = ChatRoomExtensionRuntime(
      userLoader: () async => UserInfo(userName: 'fish'),
      livenessLoader: () async => 0,
      topicProvider: () => '',
      nowProvider: () => now,
    );
    const extension = ChatRoomExtension(
      id: 'auto',
      name: '自动回复',
      template: 'ok',
      triggers: [ChatRoomExtensionTrigger.receiveText],
      triggerAction: ChatRoomExtensionTriggerAction.autoSend,
      autoSendEnabled: true,
      cooldownSeconds: 10,
    );

    final first = await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.receiveText,
    );
    final second = await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.receiveText,
    );
    now = now.add(const Duration(seconds: 11));
    final third = await runtime.renderForTrigger(
      extension: extension,
      trigger: ChatRoomExtensionTrigger.receiveText,
    );

    expect(first, isNotNull);
    expect(second, isNull);
    expect(third, isNotNull);
    expect(ChatRoomExtensionRuntime.canAutoSend(extension), isTrue);
    expect(
      ChatRoomExtensionRuntime.canAutoSend(
        extension.copyWith(autoSendEnabled: false),
      ),
      isFalse,
    );
  });
}
