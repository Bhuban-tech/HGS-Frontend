import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/chat_message_model.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class ChatService {
  WebSocketChannel? _channel;
  final TokenManager _tokenManager = TokenManager();
  final Dio _dio;
  
  final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  Stream<ChatMessage> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ChatService(this._dio);

  /// Connect to WebSocket
  Future<void> connect() async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Build WebSocket URL
      final wsUrl = ApiConstants.baseUrl.replaceFirst('http', 'ws') + 
                    ApiConstants.chatWebSocket + 
                    '?token=$token';

      if (kDebugMode) {
        print('Connecting to WebSocket: $wsUrl');
      }

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
      );

      _isConnected = true;
      _connectionController.add(true);
      
      if (kDebugMode) {
        print('WebSocket connected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('WebSocket connection error: $e');
      }
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Subscribe to user-specific topic
  Future<void> subscribeToUserTopic(String userId) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    final subscribeMessage = {
      'action': 'subscribe',
      'topic': ApiConstants.chatTopic(userId),
    };

    _channel!.sink.add(jsonEncode(subscribeMessage));
    
    if (kDebugMode) {
      print('Subscribed to topic: ${ApiConstants.chatTopic(userId)}');
    }
  }

  /// Send a chat message
  Future<void> sendMessage({
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    final userData = await _tokenManager.getUserData();
    if (userData == null) {
      throw Exception('User data not found');
    }

    final chatMessage = {
      'bookingId': bookingId,
      'senderId': userData['id'],
      'senderName': userData['userName'],
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'type': 'text',
    };

    _channel!.sink.add(jsonEncode(chatMessage));
    
    if (kDebugMode) {
      print('Message sent: $message');
    }
  }

  /// Get chat history for a booking
  Future<List<ChatMessage>> getChatHistory(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.chatHistory(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      final Map<String, dynamic> json = jsonDecode(data);
      final message = ChatMessage.fromJson(json);
      _messageController.add(message);
      
      if (kDebugMode) {
        print('Message received: ${message.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing message: $e');
      }
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    if (kDebugMode) {
      print('WebSocket disconnected');
    }
    _isConnected = false;
    _connectionController.add(false);
  }

  /// Disconnect from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _connectionController.add(false);
    
    if (kDebugMode) {
      print('WebSocket disconnected manually');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else {
      return 'Network error. Please try again.';
    }
  }
}
