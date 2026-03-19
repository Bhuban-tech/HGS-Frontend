
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/chat_message_model.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String? bookingId;
  final String? userId;

  const ChatPage({
    super.key, 
    required this.name,
    this.bookingId,
    this.userId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    
    print('🚀 [CHAT] ChatPage initialized');
    print('📝 [CHAT] Name: ${widget.name}');
    print('📋 [CHAT] Booking ID: ${widget.bookingId}');
    print('👤 [CHAT] User ID: ${widget.userId}');
    
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('⏳ [CHAT] Starting WebSocket connection...');
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
    
      final tokenManager = TokenManager();
      final userData = await tokenManager.getUserData();
      setState(() {
        _currentUserId = userData?['id'];
        _currentUserEmail = userData?['email'];
      });
      
      print('👤 [CHAT] Current User ID: $_currentUserId');
      print('📧 [CHAT] Current User Email: $_currentUserEmail');
      print('🎭 [CHAT] Current User Role: ${userData?['role']}');
      
      // Connect to WebSocket if not connected
      if (!chatProvider.isConnected) {
        print('🔌 [CHAT] WebSocket not connected, connecting now...');
        await chatProvider.connect();
        print('✅ [CHAT] WebSocket connection attempt completed');
      } else {
        print('✅ [CHAT] WebSocket already connected');
      }
      
      // Subscribe to user's personal queue
      if (_currentUserId != null) {
        print('📡 [CHAT] Subscribing to user topic: $_currentUserId');
        await chatProvider.subscribeToUserTopic(_currentUserId!);
      }
      
      // Subscribe to booking topic to see all messages
      if (widget.bookingId != null) {
        print('📡 [CHAT] Subscribing to booking topic: ${widget.bookingId}');
        await chatProvider.subscribeToBookingTopic(widget.bookingId!);
      }
      
      // Load chat history for this booking
      if (widget.bookingId != null) {
        print('📥 [CHAT] Loading chat history for booking: ${widget.bookingId}');
        await chatProvider.loadChatHistory(widget.bookingId!);
        print('✅ [CHAT] Chat history loaded');
        _scrollToBottom();
      } else {
        print('⚠️ [CHAT] No booking ID, skipping history load');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    final content = _controller.text.trim();
    final provider = Provider.of<ChatProvider>(context, listen: false);

    print('📤 Attempting to send message: $content');
    print('📋 Booking ID: ${widget.bookingId}');
    print('👤 Receiver ID: ${widget.userId}');

    if (widget.bookingId != null) {
      final success = await provider.sendMessage(
        bookingId: widget.bookingId!,
        receiverId: widget.userId ?? 'other',
        message: content,
      );
      
      print('✅ Message send success: $success');
      
      if (success) {
        _controller.clear();
        _scrollToBottom();
      } else {
        print('❌ Message send failed: ${provider.error}');
        // Show error if message failed to send
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to send message'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      print('⚠️ No booking ID provided');
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
              child: Text(
                _currentUserEmail != null && _currentUserEmail!.isNotEmpty 
                    ? _currentUserEmail![0].toUpperCase() 
                    : '?',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getChatMessages(widget.bookingId ?? 'demo_chat');
                
                print('💬 [CHAT] Total messages in chat: ${messages.length}');
                print('🔌 [CHAT] WebSocket connected: ${chatProvider.isConnected}');
                print('⏳ [CHAT] Loading: ${chatProvider.isLoading}');
                if (chatProvider.error != null) {
                  print('❌ [CHAT] Error: ${chatProvider.error}');
                }
                
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryBlue),
                  );
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start the conversation',
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when messages change
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == _currentUserId || 
                                 msg.senderId == 'me' || 
                                 msg.senderId == 'current_user';
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.success : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                msg.message,
                style: TextStyle(
                  color: isMe ? Colors.white : AppColors.textDark,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a').format(msg.timestamp),
              style: TextStyle(fontSize: 10, color: AppColors.textLight.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

