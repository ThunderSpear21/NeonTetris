import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _socketResponse =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _socketResponse.stream;

  void connect(String url) {
    if (_channel != null && _channel!.closeCode == null) {
      //print('WebSocket is already connected.');
      return;
    }

    //print('Connecting to WebSocket...');
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel!.stream.listen(
      (message) {
        //print('✅ WebSocketService received raw message: $message');
        final decodedMessage = jsonDecode(message) as Map<String, dynamic>;
        _socketResponse.add(decodedMessage);
      },
      onDone: () {
      },
      onError: (error) {
      },
    );
  }


 void disconnect() {
    if (_channel != null) {
      print('Disconnecting from WebSocket...');
      _channel!.sink.close();
      _channel = null;
    }
  }

  void sendMessage(String event, Map<String, dynamic> payload) {
    if (_channel == null || _channel!.closeCode != null) {
      print('Cannot send message, WebSocket is not connected.');
      return;
    }
    final message = jsonEncode({'event': event, 'payload': payload});
    _channel!.sink.add(message);
  }
}
