import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  Timer? _heartbeatTimer;

  void connect(
    String userId,
    String username, {
    String? email,
    String? avatar,
    String? accountId,
    String? userType,
  }) {
    _socket = IO.io('https://demo.staging.saveingold.app', <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': true,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to socket server');

      // Register user as online
      _socket!.emit('user:register', {
        'userId': userId,
        'username': username,
        'email': email,
        'accountId': accountId,
        'avatar': avatar,
        'userType': userType
      });
    });
    _socket!.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    _socket!.on('error', (data) {
      print('Socket error: $data');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  bool get isConnected => _socket?.connected ?? false;
}
