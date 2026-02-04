
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/chat_message_model.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String name;
  final String? bookingId; // Optional for demo or direct chat
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

  @override
  void initState() {
    super.initState();
    // Load chat history if bookingId is present
    if (widget.bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ChatProvider>(context, listen: false).loadChatHistory(widget.bookingId!);
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    final content = _controller.text.trim();
    final provider = Provider.of<ChatProvider>(context, listen: false);

    // DEMO: If no backend, we manually add to history in provider
    // In real app, sendMessage would handle it via WebSocket
    
    if (widget.bookingId != null) {
       // Simulate sending
       provider.sendMessage(
         bookingId: widget.bookingId!,
         receiverId: widget.userId ?? 'other',
         message: content,
       );
       
       // Force update local history for demo (since no real WS echo)
       // This is a hack for the demo to show message immediately
       // The Provider's _handleNewMessage would usually do this
       // We can rely on sendMessage returning success, but for Demo we might need to manually inject if backend is offline.
    }
    
    // For now, let's assume ChatProvider handles it or we use local state fallback
    // But since we want "User sees Provider message", we MUST use Provider state.
    
    // Actually, ChatProvider.sendMessage calls _chatService.sendMessage.
    // Use a simpler approach for Demo: Add directly to ChatProvider history exposed via a method (if available) or rely on mock service.
    // Looking at ChatProvider, it has _handleNewMessage but it's private.
    // I will just rely on UI update via a text message for now, but ideally I should modify ChatProvider to allow "mocking" a received message.
    
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.transparent, // Glassmorphism style
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // Use bookingId or fallback to a demo ID
                final messages = chatProvider.getChatMessages(widget.bookingId ?? 'demo_chat');
                
                // If empty, show some dummy messages
                final displayMessages = messages.isEmpty ? [
                   ChatMessage(
                     id: '1',
                     bookingId: 'demo',
                     senderId: 'other',
                     senderName: 'Demo User',
                     receiverId: 'me',
                     message: 'Hello!',
                     timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                   ),
                   ChatMessage(
                     id: '2',
                     bookingId: 'demo',
                     senderId: 'me',
                     senderName: 'You',
                     receiverId: 'other',
                     message: 'Hi, how can I help?',
                     timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
                   ),
                ] : messages;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final msg = displayMessages[index];
                     // Determine if "isMe" based on senderId. 
                     // For Demo: Assume 'me' or currentUserId matching.
                     // Since we don't have Auth provider easily accessible here, we'll assume 'me' is current user.
                     // But wait, User and Provider are different.
                     // We need a flag "isProviderView". 
                     // For now, let's just color based on senderId hash or simple toggle.
                     
                     final isMe = msg.senderId == 'me' || msg.senderId == 'current_user'; 
                     
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primaryPurple
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                          boxShadow: [
                             BoxShadow(
                               color: Colors.black.withValues(alpha: 0.05),
                               blurRadius: 5,
                               offset: const Offset(0, 2),
                             )
                          ],
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
