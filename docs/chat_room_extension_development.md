# 聊天室扩展开发文档

本文档描述当前 App 内置的聊天室扩展能力。扩展用于生成或改写聊天室消息，适合小尾巴、状态模板、图片说明、轻量自动回复等场景。

## 能力边界

当前 App 扩展是声明式模板扩展，不执行任意脚本。

支持：

- 手动使用扩展，从聊天室输入框更多面板选择扩展并填写参数。
- 在发消息时处理正文，适合给原消息追加小尾巴。
- 在发消息后、收到文字、收到单张图片时生成额外内容。
- 使用模板变量、输入字段、预览确认、填入输入框和自动发送。
- 通过剪贴板 JSON 导入和导出扩展配置。

不支持：

- JavaScript、Dart 或其他脚本执行。
- DOM 操作、CSS 注入、GM API、浏览器扩展 API。
- 任意网络请求、文件访问、读取非白名单用户数据。
- 兼容远端扩展仓库的 JS、主题或浏览器运行时格式。

## 扩展模型

一个扩展配置包含以下字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `name` | 字符串 | 扩展名称，不能为空。 |
| `icon` | 字符串 | 1-2 个字的图标文字，空值默认显示“扩”。 |
| `enabled` | 布尔值 | 是否启用扩展。 |
| `template` | 字符串 | 消息模板，使用 `${变量名}` 占位，不能为空。 |
| `fields` | 数组 | 用户输入字段，最多 12 个。 |
| `triggers` | 数组 | 触发时间，至少选择一个。 |
| `triggerAction` | 字符串 | 触发后动作。 |
| `cooldownSeconds` | 数字 | 事件触发冷却时间，单位秒。 |
| `autoSendEnabled` | 布尔值 | 是否允许自动发送。 |
| `dataScopes` | 数组 | 扩展允许读取的数据范围。 |

字段限制：

- 扩展总数最多 50 个。
- 单个扩展最多 12 个输入字段。
- 模板最多 1000 字。
- 字段 key 不能为空，不能重复，不能包含 `$`、`{`、`}`。
- 旧版无触发器配置的扩展导入后默认只允许手动触发，避免升级后突然自动响应消息。

## 输入字段

`fields` 用于让用户在使用扩展时填写参数。字段 key 会变成模板变量，例如 key 为 `进度`，模板里使用 `${进度}`。

支持的字段类型：

| 类型 | 说明 |
| --- | --- |
| `text` | 短文本。 |
| `multiline` | 多行文本。 |
| `number` | 数字，非空时必须能解析为数字。 |
| `select` | 单选，必须提供至少一个 `options` 选项。 |

字段配置示例：

```json
{
  "key": "进度",
  "label": "摸鱼进度",
  "type": "number",
  "required": true,
  "defaultValue": "60"
}
```

为了避免覆盖内置变量，字段 key 不建议使用 `me.*`、`message.*`、`room.*`、`now` 这些保留名。

## 触发时间

`triggers` 支持以下值：

| 值 | UI 文案 | 说明 |
| --- | --- | --- |
| `manual` | 手动使用 | 用户从更多面板主动选择扩展。 |
| `beforeSend` | 发消息时 | 用户发送前改写正文，适合小尾巴。 |
| `afterSend` | 发消息后 | 用户原消息发送成功后生成额外内容。 |
| `receiveText` | 收到文字 | 收到他人的普通文字消息后触发。 |
| `receiveSingleImage` | 收到图片 | 收到他人的单张图片消息后触发。 |

接收类触发不会响应自己发送的消息，避免扩展自循环。

## 触发后动作

`triggerAction` 支持以下值：

| 值 | UI 文案 | 说明 |
| --- | --- | --- |
| `preview` | 预览确认 | 弹出预览，用户确认后发送或填入输入框。 |
| `insert` | 填入输入框 | 把生成内容填入输入框，用户可继续编辑。 |
| `autoSend` | 自动发送 | 直接发送生成内容，需要额外开启自动发送。 |

自动发送规则：

- `autoSendEnabled` 必须为 `true`。
- `cooldownSeconds` 不能少于 10 秒。
- 自动发送失败不会继续连锁触发自己的自动消息。
- 推荐优先使用“预览确认”，自动发送只用于低风险、低频率场景。

## 可读取数据

`dataScopes` 控制扩展可以读取哪些上下文变量：

| 值 | 说明 |
| --- | --- |
| `me` | 当前登录用户数据。 |
| `message` | 当前触发消息数据。 |
| `room` | 聊天室数据。 |
| `time` | 当前时间。 |

可用变量如下。

我的数据：

- `${me.userName}`：当前用户用户名。
- `${me.nickname}`：当前用户昵称。
- `${me.point}`：当前用户积分。
- `${me.liveness}`：当前用户活跃度，60 秒内会复用缓存。
- `${me.onlineMinute}`：当前用户在线分钟数。
- `${me.followingCount}`：当前用户关注数。
- `${me.followerCount}`：当前用户粉丝数。

消息数据：

- `${message.content}`：原始消息内容。
- `${message.preview}`：消息摘要，图片、红包、音乐等会尽量使用现有预览文本。
- `${message.senderName}`：发送者显示名，优先昵称。
- `${message.senderUserName}`：发送者用户名。
- `${message.imageUrl}`：单张图片地址，仅单图消息有值。
- `${message.time}`：消息时间。

聊天室和时间：

- `${room.topic}`：当前聊天室话题。
- `${now}`：当前本地时间。

未提供或无权限读取的变量会替换为空字符串。

## 导入导出格式

扩展配置通过剪贴板 JSON 导入导出。导出的顶层结构如下：

```json
{
  "version": 2,
  "extensions": [
    {
      "id": "",
      "name": "扩展名称",
      "icon": "扩",
      "enabled": true,
      "template": "消息模板",
      "fields": [],
      "triggers": ["manual"],
      "triggerAction": "preview",
      "cooldownSeconds": 10,
      "autoSendEnabled": false,
      "dataScopes": ["me", "message", "room", "time"],
      "createdAt": 0,
      "updatedAt": 0
    }
  ]
}
```

导入时可以省略 `id`、`createdAt`、`updatedAt`，App 会自动生成。导入非法 JSON、字段校验失败或超过数量上限时，不会覆盖现有扩展。

## 示例：小尾巴

用途：用户发消息时自动在正文后追加昵称、积分、活跃度和时间。

```json
{
  "name": "小尾巴",
  "icon": "尾",
  "enabled": true,
  "template": "${message.content}\n\n-- ${me.nickname} · 积分 ${me.point} · 活跃 ${me.liveness} · ${now}",
  "fields": [],
  "triggers": ["beforeSend"],
  "triggerAction": "insert",
  "cooldownSeconds": 0,
  "autoSendEnabled": false,
  "dataScopes": ["me", "message", "time"]
}
```

说明：`beforeSend` 会改写原消息，适合这类追加内容的扩展。

## 示例：今日状态

用途：手动填写状态、摸鱼进度和备注，生成一条状态消息。

```json
{
  "name": "今日状态",
  "icon": "状",
  "enabled": true,
  "template": "今日状态：${状态}\n摸鱼进度：${进度}%\n当前积分：${me.point} · 活跃度：${me.liveness}\n聊天室话题：${room.topic}\n${备注}",
  "fields": [
    {
      "key": "状态",
      "label": "今天状态",
      "type": "select",
      "required": true,
      "options": ["摸鱼中", "搬砖中", "准备下班", "灵感充电"],
      "defaultValue": "摸鱼中"
    },
    {
      "key": "进度",
      "label": "摸鱼进度",
      "type": "number",
      "required": true,
      "defaultValue": "60"
    },
    {
      "key": "备注",
      "label": "补充说明",
      "type": "multiline",
      "required": false,
      "defaultValue": ""
    }
  ],
  "triggers": ["manual"],
  "triggerAction": "preview",
  "cooldownSeconds": 10,
  "autoSendEnabled": false,
  "dataScopes": ["me", "room"]
}
```

说明：手动扩展会在更多面板中展示，用户可以预览后填入输入框或立即发送。

## 示例：图片说明

用途：收到单张图片后生成说明草稿，确认后可发送或填入输入框。

```json
{
  "name": "自动图片说明",
  "icon": "图",
  "enabled": true,
  "template": "图片说明草稿\n来自：${message.senderName}\n图片地址：${message.imageUrl}\n发送时间：${message.time}\n\n我看到了这张图，可以补一句想法再发送。",
  "fields": [],
  "triggers": ["receiveSingleImage"],
  "triggerAction": "preview",
  "cooldownSeconds": 10,
  "autoSendEnabled": false,
  "dataScopes": ["message"]
}
```

说明：这个扩展只在“单张图片消息”触发，多图、文字加图片或其他富文本不会触发。

## 示例：收到文字后预览回复

用途：收到文字时生成一条回复草稿，但不自动发送，避免打扰聊天室。

```json
{
  "name": "文字回复草稿",
  "icon": "回",
  "enabled": true,
  "template": "回复 ${message.senderName}：\n我看到了：${message.preview}",
  "fields": [],
  "triggers": ["receiveText"],
  "triggerAction": "preview",
  "cooldownSeconds": 15,
  "autoSendEnabled": false,
  "dataScopes": ["message"]
}
```

说明：接收类扩展建议使用预览确认，确认内容合适后再发送。

## 推荐实践

- 需要改写用户原消息时，使用 `beforeSend`。
- 需要额外生成一条消息时，使用 `afterSend` 或接收类触发。
- 涉及自动发送时，保持较长冷却时间，并让模板内容足够明确。
- 模板中尽量使用摘要变量 `${message.preview}`，避免长 HTML 或图片标签撑开输入区。
- 分享扩展时，优先导出 JSON，并在说明中写清楚触发时间和自动发送状态。
