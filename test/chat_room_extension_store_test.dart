import 'dart:io';

import 'package:fishpi_app/core/sql/chat_room_extension_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('chat_room_extension_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    await ChatRoomExtensionStore.init();
    await ChatRoomExtensionStore.clear();
  });

  tearDownAll(() async {
    await ChatRoomExtensionStore.dispose();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('扩展模型可以序列化和反序列化', () {
    const extension = ChatRoomExtension(
      id: 'e1',
      name: '摸鱼日报',
      icon: '报',
      template: r'进度：${进度}',
      fields: [
        ChatRoomExtensionField(
          key: '进度',
          label: '摸鱼进度',
          type: ChatRoomExtensionFieldType.number,
          required: true,
        ),
      ],
    );

    final restored = ChatRoomExtension.fromJson(extension.toJson());

    expect(restored.id, 'e1');
    expect(restored.name, '摸鱼日报');
    expect(restored.fields.single.key, '进度');
    expect(restored.fields.single.type, ChatRoomExtensionFieldType.number);
  });

  test('模板会按字段 key 精确替换占位符', () {
    const extension = ChatRoomExtension(
      name: '日报',
      template: r'今天摸鱼进度：${进度}%\n备注：${备注}',
      fields: [
        ChatRoomExtensionField(key: '进度'),
        ChatRoomExtensionField(key: '备注'),
      ],
    );

    expect(
      ChatRoomExtensionStore.render(
        extension,
        const {'进度': '80', '备注': '状态良好'},
      ),
      '今天摸鱼进度：80%\\n备注：状态良好',
    );
  });

  test('扩展和字段校验覆盖空模板、重复 key、必填和数字字段', () {
    expect(
      ChatRoomExtensionStore.validateExtension(
        const ChatRoomExtension(name: '', template: 'hi'),
      ),
      '扩展名称不能为空',
    );
    expect(
      ChatRoomExtensionStore.validateExtension(
        const ChatRoomExtension(name: 'x', template: ''),
      ),
      '消息模板不能为空',
    );
    expect(
      ChatRoomExtensionStore.validateExtension(
        const ChatRoomExtension(
          name: 'x',
          template: r'${a}',
          fields: [
            ChatRoomExtensionField(key: 'a'),
            ChatRoomExtensionField(key: 'a'),
          ],
        ),
      ),
      '字段 key 不能重复',
    );

    const extension = ChatRoomExtension(
      name: 'x',
      template: r'${point}',
      fields: [
        ChatRoomExtensionField(
          key: 'point',
          label: '积分',
          type: ChatRoomExtensionFieldType.number,
          required: true,
        ),
      ],
    );
    expect(
        ChatRoomExtensionStore.validateValues(extension, const {}), '积分不能为空');
    expect(
      ChatRoomExtensionStore.validateValues(
        extension,
        const {'point': 'abc'},
      ),
      '积分必须是数字',
    );
  });

  test('导入非法 JSON 不会覆盖已有扩展，停用扩展不会进入可用列表', () async {
    await ChatRoomExtensionStore.saveExtension(
      const ChatRoomExtension(
        name: '已存在',
        enabled: false,
        template: 'hello',
      ),
    );

    expect(ChatRoomExtensionStore.importJson('{bad json'), throwsA(anything));
    final all = await ChatRoomExtensionStore.getAll();
    final enabled = await ChatRoomExtensionStore.getEnabled();

    expect(all.length, 1);
    expect(all.single.name, '已存在');
    expect(enabled, isEmpty);
  });
}
