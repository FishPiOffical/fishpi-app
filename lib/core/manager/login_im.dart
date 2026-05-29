import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class LoginIM {
  static Uri wsUrl = Uri.parse('wss://fishpi.cn/login-channel');
  static WebSocketChannel? _channel;

  static initWS({String? domain}) async {
    close();
    final channel = WebSocketChannel.connect(wsUrl);
    _channel = channel;
    try {
      await channel.ready;
      channel.stream.listen((_) {});
    } catch (_) {
      close();
      rethrow;
    }
  }

  static send(String data) {
    _channel?.sink.add(data);
  }

  static close() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }
}
