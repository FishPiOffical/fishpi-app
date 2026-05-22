import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class LoginIM {
  static Uri wsUrl = Uri.parse('wss://fishpi.cn/login-channel');
  static late WebSocketChannel channel;

  static initWS({String? domain}) async {
    channel = WebSocketChannel.connect(wsUrl);
    await channel.ready;
    channel.stream.listen((_) {});
  }

  static send(String data) {
    channel.sink.add(data);
  }

  static close() {
    channel.sink.close(status.goingAway);
  }
}
