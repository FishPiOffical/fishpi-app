import 'package:dio/dio.dart';
import 'package:fishpi/fishpi.dart';

class CollectionMedal {
  final String id;
  final String name;
  final String description;
  final String type;
  final bool display;
  final int displayOrder;
  final String expireTime;
  final String imageUrl;
  final Metal? rawMetal;

  const CollectionMedal({
    required this.id,
    required this.name,
    required this.description,
    this.type = '',
    this.display = false,
    this.displayOrder = 0,
    this.expireTime = '',
    this.imageUrl = '',
    this.rawMetal,
  });

  factory CollectionMedal.fromApi(
    Map<String, dynamic> data, {
    required String baseUrl,
  }) {
    final id = _firstString(data, [
      'medal_id',
      'medalId',
      'id',
      'oId',
      'data',
      'name',
    ]);
    return CollectionMedal(
      id: id,
      name: _firstString(data, ['medal_name', 'medalName', 'name']),
      description: _firstString(
        data,
        ['medal_description', 'medalDescription', 'description'],
      ),
      type: _firstString(data, ['medal_type', 'medalType', 'type']),
      display: _parseDisplay(data['display'] ?? data['enable']),
      displayOrder: _parseInt(data['display_order'] ?? data['displayOrder']),
      expireTime: _formatExpireTime(data['expire_time'] ?? data['expireTime']),
      imageUrl: id.isEmpty ? '' : '$baseUrl/gen?id=$id',
    );
  }

  factory CollectionMedal.fromMetal(Metal medal) {
    final id = medal.data.isNotEmpty ? medal.data : medal.name;
    return CollectionMedal(
      id: id,
      name: medal.name,
      description: medal.description,
      display: _parseDisplay(medal.enable),
      imageUrl: medal.attr.url,
      rawMetal: medal,
    );
  }

  CollectionMedal copyWith({bool? display, Metal? rawMetal}) {
    return CollectionMedal(
      id: id,
      name: name,
      description: description,
      type: type,
      display: display ?? this.display,
      displayOrder: displayOrder,
      expireTime: expireTime,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : rawMetal?.attr.url ?? '',
      rawMetal: rawMetal ?? this.rawMetal,
    );
  }

  static String _firstString(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static bool _parseDisplay(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase().trim() ?? '';
    return text == 'true' ||
        text == '1' ||
        text == 'yes' ||
        text == 'on' ||
        text == 'enable' ||
        text == 'enabled';
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatExpireTime(dynamic value) {
    if (value == null) return '';
    final text = value.toString();
    if (text.isEmpty || text == '0') return '永久';
    final timestamp = int.tryParse(text);
    if (timestamp == null || timestamp <= 0) return text;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class MedalService {
  MedalService({
    Dio? dio,
    this.baseUrl = 'https://fishpi.cn',
  }) : _dio = dio ?? Dio();

  final Dio _dio;
  final String baseUrl;

  static ResponseResult parseResponse(dynamic data) {
    if (data is! Map) {
      throw '响应数据异常';
    }
    final response = Map<String, dynamic>.from(data);
    final code = response['code'];
    final result = ResponseResult(
      success: code == 0 || code == '0' || code == null,
      msg: response['msg']?.toString() ?? '',
    );
    if (!result.success) {
      throw result.msg.isEmpty ? '操作失败' : result.msg;
    }
    return result;
  }

  Future<List<CollectionMedal>> listMyMedals({
    required String apiKey,
  }) async {
    final response = await _post('/api/medal/my/list', data: {
      'apiKey': apiKey,
    });
    parseResponse(response);
    final data = response is Map ? response['data'] : null;
    final list = data is List
        ? data
        : data is Map && data['list'] is List
            ? data['list'] as List
            : const [];
    return list
        .whereType<Map>()
        .map((item) => CollectionMedal.fromApi(
              Map<String, dynamic>.from(item),
              baseUrl: baseUrl,
            ))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }

  Future<ResponseResult> updateDisplay({
    required String apiKey,
    required String medalId,
    required bool display,
  }) async {
    final response = await _post('/api/medal/my/display', data: {
      'apiKey': apiKey,
      'medalId': medalId,
      'display': display,
    });
    return parseResponse(response);
  }

  Future<dynamic> _post(String path,
      {required Map<String, dynamic> data}) async {
    // 勋章接口按开放 API 约定使用 JSON 请求体，apiKey 放入 body 鉴权。
    final response = await _dio.post(
      '$baseUrl$path',
      data: data,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {'Accept': Headers.jsonContentType},
      ),
    );
    return response.data;
  }
}
