import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef EventCallback = void Function(dynamic data);

class SocketIOService {
  // Singleton instance
  static final SocketIOService _instance = SocketIOService._internal();

  factory SocketIOService() => _instance;

  SocketIOService._internal();

  late IO.Socket _socket;
  bool _initialized = false;

  final Map<String, List<EventCallback>> _listeners = {};

  bool get isInitialized => _initialized;

  bool get isConnected => _initialized && _socket.connected;

  /// Initialize the socket connection. Must be called before usage.
  void init({
    required String uri,
    required String userId,
  }) {
    if (_initialized) {
      print('⚠️ SocketIOService already initialized.');
      return;
    }

    _socket = IO.io(
      uri,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath("/socket.io")
          .setQuery({'userId': userId})
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    _socket.onConnect((_) {
      print('🔌 Socket connected');
    });

    _socket.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket.onReconnect((_) {
      print('🔄 Socket reconnected');
    });

    _socket.onConnectError((err) {
      print('⚠️ Connect error: $err');
    });

    _socket.onError((err) {
      print('❌ Socket error: $err');
    });

    _initialized = true;
  }

  /// Emits an event with data if socket is connected.
  void emit(String event, dynamic data) {
    if (!_initialized) {
      print('❗ Socket not initialized. Call init() first.');
      return;
    }
    if (!isConnected) {
      print("❗ Socket not connected, couldn't emit event: $event");
      return;
    }
    _socket.emit(event, data);
  }

  /// Register an event listener callback.
  void on(String event, EventCallback callback) {
    if (!_initialized) {
      print('❗ Socket not initialized. Call init() first.');
      return;
    }
    _socket.on(event, callback);
    _listeners.putIfAbsent(event, () => []).add(callback);
  }

  /// Remove a specific callback for an event.
  void off(String event, EventCallback callback) {
    if (!_initialized) {
      print('❗ Socket not initialized. Call init() first.');
      return;
    }
    _socket.off(event, callback);
    _listeners[event]?.remove(callback);
  }

  /// Dispose all listeners and close the socket connection.
  void dispose() {
    if (!_initialized) {
      print('❗ Socket not initialized or already disposed.');
      return;
    }
    _listeners.forEach((event, callbacks) {
      for (var callback in callbacks) {
        _socket.off(event, callback);
      }
    });
    _listeners.clear();

    _socket.dispose();
    _initialized = false;

    print("🧹 Socket disposed");
  }
}
