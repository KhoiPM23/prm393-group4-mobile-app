class ChatRoomEntity {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final Map<String, dynamic>? metadata; // E.g. property title, etc.

  const ChatRoomEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
    this.metadata,
  });
}
