class ChatMessage {
  final String? id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final bool isHidden;

  ChatMessage({
    this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.isHidden = false, // Default to visible
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString(),
      bookingId: json['bookingId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId']?.toString() ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      type: _parseMessageType(json['type']),
      isHidden: json['isHidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'bookingId': bookingId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
      'isHidden': isHidden,
    };
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  bool isSentBy(String userId) => senderId == userId;

  /// Check if message should be visible based on booking status
  bool isVisibleForBookingStatus(String bookingStatus) {
    // If booking is accepted, all messages are visible
    if (bookingStatus == 'ACCEPTED' || bookingStatus == 'IN_PROGRESS' || bookingStatus == 'COMPLETED') {
      return true;
    }
    // If booking is pending, only show non-hidden messages
    return !isHidden;
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
}
