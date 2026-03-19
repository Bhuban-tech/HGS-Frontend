import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/chat_message_model.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

/// Minimal STOMP-over-WebSocket implementation.
/// Spring Boot uses SockJS/STOMP — this speaks the raw STOMP wire protocol.
class ChatService {
  WebSocketChannel? _channel;
  final TokenManager _tokenManager = TokenManager();
  final Dio _dio;

  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  int _subscriptionCounter = 0;
  final Set<String> _subscribedDestinations = {};

  ChatService(this._dio);

  Future<Map<String, String>?> getUserData() async {
    return await _tokenManager.getUserData();
  }

  // ─── STOMP frame builder ───────────────────────────────────────────────────

  /// Build a raw STOMP frame string.
  String _buildFrame(String command, Map<String, String> headers,
      [String? body]) {
    final sb = StringBuffer();
    sb.write('$command\n');
    headers.forEach((k, v) => sb.write('$k:$v\n'));
    sb.write('\n');
    if (body != null) sb.write(body);
    sb.write('\x00'); // NULL terminator
    return sb.toString();
  }

  /// Parse a raw STOMP frame into command + headers + body.
  Map<String, dynamic> _parseFrame(String raw) {
    final nullIdx = raw.indexOf('\x00');
    final content = nullIdx >= 0 ? raw.substring(0, nullIdx) : raw;
    final lines = content.split('\n');

    final command = lines.isNotEmpty ? lines[0].trim() : '';
    final headers = <String, String>{};
    int bodyStart = lines.length;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty) {
        bodyStart = i + 1;
        break;
      }
      final colon = line.indexOf(':');
      if (colon > 0) {
        headers[line.substring(0, colon).trim()] =
            line.substring(colon + 1).trim();
      }
    }

    final body = bodyStart < lines.length
        ? lines.sublist(bodyStart).join('\n').trim()
        : '';

    return {'command': command, 'headers': headers, 'body': body};
  }

  // ─── Connect ──────────────────────────────────────────────────────────────

  Future<void> connect() async {
    final token = await _tokenManager.getAccessToken();
    if (token == null) throw Exception('No authentication token found');

    // Spring Boot STOMP endpoint — use /websocket suffix for raw WS (no SockJS)
    final wsUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws') +
        ApiConstants.chatWebSocket +
        '/websocket';

    if (kDebugMode) print('🔌 Connecting STOMP to: $wsUrl');

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    final completer = Completer<void>();

    _channel!.stream.listen(
      (data) {
        final frame = _parseFrame(data.toString());
        final command = frame['command'] as String;

        if (kDebugMode) print('📨 STOMP frame: $command');

        switch (command) {
          case 'CONNECTED':
            _isConnected = true;
            _connectionController.add(true);
            if (!completer.isCompleted) completer.complete();
            if (kDebugMode) print('✅ STOMP connected');
            break;
          case 'MESSAGE':
            _handleStompMessage(frame);
            break;
          case 'ERROR':
            if (kDebugMode) print('❌ STOMP ERROR: ${frame['body']}');
            if (!completer.isCompleted) {
              completer.completeError(Exception(frame['body']));
            }
            break;
          default:
            break;
        }
      },
      onError: (e) {
        if (kDebugMode) print('❌ WebSocket error: $e');
        _isConnected = false;
        _connectionController.add(false);
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (kDebugMode) print('🔌 WebSocket closed');
        _isConnected = false;
        _subscribedDestinations.clear();
        _connectionController.add(false);
      },
    );

    // Send STOMP CONNECT frame with JWT
    final connectFrame = _buildFrame('CONNECT', {
      'accept-version': '1.1,1.2',
      'heart-beat': '0,0',
      'Authorization': 'Bearer $token',
    });
    _channel!.sink.add(connectFrame);

    // Wait up to 10s for CONNECTED frame
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('STOMP connection timed out'),
    );
  }

  // ─── Subscribe ────────────────────────────────────────────────────────────

  Future<void> subscribeToUserTopic(String userId) async {
    _ensureConnected();
    final dest = '/user/queue/messages';
    if (_subscribedDestinations.contains(dest)) return;
    _subscribe(dest);
  }

  Future<void> subscribeToBookingTopic(String bookingId) async {
    _ensureConnected();
    final dest = '/topic/booking/$bookingId';
    if (_subscribedDestinations.contains(dest)) return;
    _subscribe(dest);
  }

  void _subscribe(String destination) {
    final id = 'sub-${_subscriptionCounter++}';
    final frame = _buildFrame('SUBSCRIBE', {
      'id': id,
      'destination': destination,
      'ack': 'auto',
    });
    _channel!.sink.add(frame);
    _subscribedDestinations.add(destination);
    if (kDebugMode) print('✅ Subscribed to: $destination (id=$id)');
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<void> sendMessage({
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    _ensureConnected();

    final body = jsonEncode({
      'requestId': bookingId,
      'message': message,
      'receiverId': receiverId,
    });

    final frame = _buildFrame(
      'SEND',
      {
        'destination': '/app/chat.send',
        'content-type': 'application/json',
        'content-length': utf8.encode(body).length.toString(),
      },
      body,
    );

    _channel!.sink.add(frame);
    if (kDebugMode) print('📤 Sent: $message');
  }

  // ─── REST history ─────────────────────────────────────────────────────────

  Future<List<ChatMessage>> getChatHistory(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (kDebugMode) print('📥 Loading chat history for: $bookingId');

      final response = await _dio.get(
        ApiConstants.chatHistory(bookingId),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (kDebugMode) print('📦 History response: ${response.data}');

      List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map) {
        data = [response.data];
      } else {
        return [];
      }

      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Chat history error: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }
      throw _handleDioError(e);
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  void _handleStompMessage(Map<String, dynamic> frame) {
    try {
      final body = frame['body'] as String;
      if (body.isEmpty) return;
      if (kDebugMode) print('💬 Message body: $body');

      final json = jsonDecode(body) as Map<String, dynamic>;
      final message = ChatMessage.fromJson(json);
      _messageController.add(message);
    } catch (e) {
      if (kDebugMode) print('❌ Error parsing message: $e');
    }
  }

  void _ensureConnected() {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }
  }

  void disconnect() {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(_buildFrame('DISCONNECT', {}));
      } catch (_) {}
    }
    _channel?.sink.close();
    _isConnected = false;
    _subscribedDestinations.clear();
    _connectionController.add(false);
    if (kDebugMode) print('🔌 Disconnected');
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) return data['message'];
      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    }
    return 'Network error. Please try again.';
  }
}
