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

  List<ChatMessage> getChatMessages(String bookingId, {String? bookingStatus}) {
    final allMessages = _chatHistory[bookingId] ?? [];
    
    // If no booking status provided, return all messages
    if (bookingStatus == null) {
      return allMessages;
    }
    
    // Filter messages based on booking status
    return allMessages.where((msg) => msg.isVisibleForBookingStatus(bookingStatus)).toList();
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

  /// Subscribe to booking topic
  Future<void> subscribeToBookingTopic(String bookingId) async {
    try {
      await _chatService.subscribeToBookingTopic(bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Send a message (will be hidden if booking not accepted)
  Future<bool> sendMessage({
    required String bookingId,
    required String receiverId,
    required String message,
    String? bookingStatus, // Pass booking status
  }) async {
    if (message.trim().isEmpty) {
      _error = 'Message cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      // Get current user data for sender info
      final userData = await _chatService.getUserData();
      
      // Create a temporary message to show immediately (optimistic update)
      final tempMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookingId: bookingId,
        senderId: userData?['id'] ?? 'me',
        senderName: userData?['userName'] ?? 'You',
        receiverId: receiverId,
        message: message.trim(),
        timestamp: DateTime.now(),
      );
      
      // Add message to local state immediately
      if (_chatHistory.containsKey(bookingId)) {
        _chatHistory[bookingId]!.add(tempMessage);
      } else {
        _chatHistory[bookingId] = [tempMessage];
      }
      notifyListeners();
      
      // Send via WebSocket
      await _chatService.sendMessage(
        bookingId: bookingId,
        receiverId: receiverId,
        message: message.trim(),
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
      if (kDebugMode) {
        print('📥 [CHAT PROVIDER] Loading chat history for booking: $bookingId');
      }
      
      final messages = await _chatService.getChatHistory(bookingId);
      
      // Filter out backend artifact messages
      final filtered = messages.where((m) => 
        m.message.trim().toLowerCase() != 'chat history'
      ).toList();
      
      // Merge with existing messages instead of replacing
      if (_chatHistory.containsKey(bookingId)) {
        final existingMessages = _chatHistory[bookingId]!;
        
        // Create a map of existing message IDs for quick lookup
        final existingIds = existingMessages.map((m) => m.id).toSet();
        
        // Add new messages from backend that don't exist locally
        for (var message in filtered) {
          if (!existingIds.contains(message.id)) {
            existingMessages.add(message);
          }
        }
        
        // Sort by timestamp
        existingMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        _chatHistory[bookingId] = existingMessages;
      } else {
        _chatHistory[bookingId] = filtered;
      }
      
      if (kDebugMode) {
        print('✅ [CHAT PROVIDER] Total messages after merge: ${_chatHistory[bookingId]?.length ?? 0}');
        for (var msg in _chatHistory[bookingId] ?? []) {
          print('   💬 ${msg.senderName}: ${msg.message}');
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [CHAT PROVIDER] Error loading chat history: $e');
      }
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

  /// Reveal all hidden messages for a booking (called when booking is accepted)
  Future<void> revealMessagesForBooking(String bookingId) async {
    if (_chatHistory.containsKey(bookingId)) {
      // Trigger a reload to get updated message visibility from backend
      await loadChatHistory(bookingId);
    }
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
