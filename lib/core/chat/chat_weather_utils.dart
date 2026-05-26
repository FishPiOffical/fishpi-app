import 'dart:convert';

import 'package:fishpi/types/chatroom.dart';
import 'package:html/parser.dart' as html_parser;

class ChatWeatherUtils {
  ChatWeatherUtils._();

  static WeatherMsg? weatherFromMessage(ChatRoomMessage message) {
    if (message.weather != null) return message.weather;
    return weatherFromContent(message.content);
  }

  static WeatherMsg? weatherFromContent(String content) {
    final text = content.trim();
    if (text.isEmpty) return null;

    final bracket = _extractWrapped(text, 'weather');
    if (bracket != null) {
      return _weatherFromPayload(bracket, fallbackUnavailable: true);
    }

    final direct = _weatherFromPayload(text);
    if (direct != null) return direct;

    try {
      final document = html_parser.parse(text);
      final weather = document.querySelector('weather');
      if (weather != null) {
        return _weatherFromPayload(weather.text, fallbackUnavailable: true);
      }
    } catch (_) {}

    return null;
  }

  static String previewFor(WeatherMsg weather) {
    final city = weather.city.trim();
    final desc = weather.description.trim();
    if (city.isEmpty && desc.isEmpty) return '[天气]';
    if (city.isEmpty) return '[天气] $desc';
    if (desc.isEmpty) return '[天气] $city';
    return '[天气] $city $desc';
  }

  static WeatherMsg unavailable() {
    return WeatherMsg(city: '天气', description: '天气卡片暂不可用');
  }

  static WeatherMsg? _weatherFromPayload(
    String payload, {
    bool fallbackUnavailable = false,
  }) {
    final text = payload.trim();
    if (text.isEmpty) {
      return fallbackUnavailable ? unavailable() : null;
    }

    try {
      final data = jsonDecode(text);
      if (data is Map) {
        final map = data.cast<String, dynamic>();
        final looksLikeWeather =
            map['msgType'] == ChatRoomMessageType.weather ||
                map.containsKey('t') ||
                map.containsKey('city') ||
                map.containsKey('weatherCode');
        if (!looksLikeWeather) return null;
        return WeatherMsg.from(map);
      }
    } catch (_) {}

    return fallbackUnavailable ? unavailable() : null;
  }

  static String? _extractWrapped(String content, String tag) {
    final match = RegExp(
      '\\[$tag\\]([\\s\\S]*?)\\[/$tag\\]',
      caseSensitive: false,
    ).firstMatch(content);
    return match?.group(1)?.trim();
  }
}
