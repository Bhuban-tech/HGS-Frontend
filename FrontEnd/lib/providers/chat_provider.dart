import 'package:flutter/foundation.dart';
import 'package:HamroGharSewa/models/chat_message_model.dart';
import 'package:HamroGharSewa/services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService;
  
  final Map<String, List<ChatMessage>> _chatHistory = {};
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._chatService) {
    _chatService.messageStream.listen(_handleNewMessage);
    _chatService.connectionStream.listen(_handleConnectionChange);
  }

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ChatMessage> getChatMessages(String bookingId) {
    return _chatHistory[bookingId] ?? [];
  }

  /// Connect to WebSocket
  Future<void> connect() async {
    try {
      await _chatService.connect();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Subscribe to user topic
  Future<void> subscribeToUserTopic(String userId) async {
    try {
      await _chatService.subscribeToUserTopic(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Send a message
  Future<bool> sendMessage({
    required String bookingId,
    required String receiverId,
    required String message,
  }) async {
    try {
      await _chatService.sendMessage(
        bookingId: bookingId,
        receiverId: receiverId,
        message: message,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load chat history
  Future<void> loadChatHistory(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final messages = await _chatService.getChatHistory(bookingId);
      _chatHistory[bookingId] = messages;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle new incoming messages
  void _handleNewMessage(ChatMessage message) {
    final bookingId = message.bookingId;
    
    if (_chatHistory.containsKey(bookingId)) {
      _chatHistory[bookingId]!.add(message);
    } else {
      _chatHistory[bookingId] = [message];
    }
    
    notifyListeners();
  }

  /// Handle connection status changes
  void _handleConnectionChange(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  /// Disconnect
  void disconnect() {
    _chatService.disconnect();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
