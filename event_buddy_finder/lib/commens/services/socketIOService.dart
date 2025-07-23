import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef EventCallback = void Function(dynamic data);

class SocketIOService {
  static final SocketIOService _instance = SocketIOService._internal();

  factory SocketIOService() => _instance;

  late IO.Socket _socket;

  final _listeners = <String, List<EventCallback>>{};

  bool get isConnected => _socket.connected;

  SocketIOService._internal();

  void init({
    required String uri,
    required String userId,
  }) {
    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.onConnect((_) {
      print('🔌 Socket connected');
    });

    _socket.onDisconnect((_) => print('❌ Socket disconnected'));

    _socket.onReconnect((_) => print('🔄 Socket reconnected'));

    _socket.onConnectError((err) => print('⚠️ Connect error: $err'));

    _socket.onError((err) => print('❌ Socket error: $err'));
  }

  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket.emit(event, data);
    } else {
      print("❗ Socket not connected, couldn't emit: $event");
    }
  }

  void on(String event, EventCallback callback) {
    _socket.on(event, callback);

    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  void off(String event, EventCallback callback) {
    _socket.off(event, callback);
    _listeners[event]?.remove(callback);
  }

  void dispose() {
    _listeners.forEach((event, callbacks) {
      for (var cb in callbacks) {
        _socket.off(event, cb);
      }
    });

    _socket.dispose();
    print("🧹 Socket disposed");
  }
}
