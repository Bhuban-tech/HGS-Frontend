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

  /// Get user data from token manager
  Future<Map<String, String>?> getUserData() async {
    return await _tokenManager.getUserData();
  }

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

  /// Subscribe to user-specific topics for receiving messages
  Future<void> subscribeToUserTopic(String userId) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    // Subscribe to user's personal queue to receive messages
    final subscribeMessage = {
      'action': 'subscribe',
      'destination': '/user/$userId/queue/messages',
    };

    _channel!.sink.add(jsonEncode(subscribeMessage));
    
    if (kDebugMode) {
      print('✅ Subscribed to: /user/$userId/queue/messages');
    }
  }

  /// Subscribe to booking topic to see all messages in the booking
  Future<void> subscribeToBookingTopic(String bookingId) async {
    if (!_isConnected || _channel == null) {
      throw Exception('WebSocket not connected');
    }

    final subscribeMessage = {
      'action': 'SUBSCRIBE',
      'destination': '/topic/booking/$bookingId',
      'id': 'sub-$bookingId',
    };

    _channel!.sink.add(jsonEncode(subscribeMessage));
    
    if (kDebugMode) {
      print('✅ Subscribed to booking topic: /topic/booking/$bookingId');
      print('📡 All devices subscribed to this topic will receive messages');
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
      
      if (kDebugMode) {
        print('📥 [CHAT SERVICE] Fetching chat history for booking: $bookingId');
      }
      
      final response = await _dio.get(
        ApiConstants.chatHistory(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('📦 [CHAT SERVICE] Response data type: ${response.data.runtimeType}');
        print('📦 [CHAT SERVICE] Response data: ${response.data}');
      }

      // Handle both list and single object responses
      List<dynamic> data;
      if (response.data is List) {
        data = response.data;
      } else if (response.data is Map) {
        // Backend returned a single object, wrap it in a list
        data = [response.data];
      } else {
        if (kDebugMode) {
          print('⚠️ [CHAT SERVICE] Unexpected response format, returning empty list');
        }
        return [];
      }
      
      if (kDebugMode) {
        print('✅ [CHAT SERVICE] Loaded ${data.length} messages');
      }
      
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [CHAT SERVICE] DioException: ${e.message}');
        print('❌ [CHAT SERVICE] Response: ${e.response?.data}');
      }
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CHAT SERVICE] Error loading chat history: $e');
      }
      rethrow;
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic data) {
    try {
      if (kDebugMode) {
        print('📨 [WebSocket] Raw message received: $data');
      }
      
      final Map<String, dynamic> json = jsonDecode(data);
      
      if (kDebugMode) {
        print('📨 [WebSocket] Parsed message: $json');
      }
      
      final message = ChatMessage.fromJson(json);
      _messageController.add(message);
      
      if (kDebugMode) {
        print('✅ [WebSocket] Message delivered to stream: ${message.senderName} -> ${message.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [WebSocket] Error parsing message: $e');
        print('❌ [WebSocket] Raw data was: $data');
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
