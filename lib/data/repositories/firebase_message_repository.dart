import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../models/message_model.dart';

class FirebaseMessageRepository {
  final FirebaseFirestore _firestore;

  FirebaseMessageRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Lấy danh sách phòng chat cho một user
  Stream<List<ChatRoomEntity>> getChatRooms(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          
          // Xử lý an toàn cho timestamp (chấp nhận cả Timestamp, String hoặc null)
          DateTime ts;
          if (data['lastMessageTimestamp'] is Timestamp) {
            ts = (data['lastMessageTimestamp'] as Timestamp).toDate();
          } else if (data['lastMessageTimestamp'] is String) {
            ts = DateTime.tryParse(data['lastMessageTimestamp']) ?? DateTime.now();
          } else {
            ts = DateTime.now();
          }

          return ChatRoomEntity(
            id: doc.id,
            participants: List<String>.from(data['participants'] ?? []),
            lastMessage: data['lastMessage'] ?? '',
            lastMessageTimestamp: ts,
            unreadCount: data['unreadCount_$userId'] ?? 0,
            metadata: data['metadata'] as Map<String, dynamic>?,
          );
        } catch (e) {
          print('Lỗi parse phòng chat: $e');
          // Trả về một entity trống thay vì làm hỏng cả list
          return ChatRoomEntity(
            id: doc.id,
            participants: [],
            lastMessage: 'Lỗi dữ liệu',
            lastMessageTimestamp: DateTime.now(),
          );
        }
      }).where((r) => r.participants.isNotEmpty).toList();
      
      // Sắp xếp thủ công bằng Dart để tránh lỗi "Requires an Index"
      rooms.sort((a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp));
      return rooms;
    });
  }

  // Lấy tin nhắn Realtime trong một phòng
  Stream<List<MessageEntity>> getMessages(String roomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        // .orderBy('timestamp', descending: true) // Bỏ để tránh lỗi Index
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MessageModel.fromJson(data);
      }).toList();
      
      // Sắp xếp thủ công bằng Dart (Giảm dần để phù hợp với reverse: true trong UI)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages;
    });
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String roomId, String senderId, String receiverId, String content) async {
    final messageCollection = _firestore
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages');

    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await messageCollection.add(message);

    // Cập nhật last message trong phòng chat
    await _firestore.collection('chat_rooms').doc(roomId).update({
      'lastMessage': content,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'unreadCount_$receiverId': FieldValue.increment(1),
    });
  }

  // Đánh dấu đã xem
  Future<void> markAsRead(String roomId, String userId) async {
    await _firestore.collection('chat_rooms').doc(roomId).update({
      'unreadCount_$userId': 0,
    });
  }
  
  // Tạo hoặc lấy phòng chat giữa 2 người
  Future<String> getOrCreateChatRoom(
    String user1Id, 
    String user2Id, {
    required String user1Name,
    required String user2Name,
    String? user1Avatar,
    String? user2Avatar,
    Map<String, dynamic>? extraMetadata,
  }) async {
    final participants = [user1Id, user2Id]..sort();
    
    final query = await _firestore
        .collection('chat_rooms')
        .where('participants', isEqualTo: participants)
        .limit(1)
        .get();
        
    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    } else {
      final doc = await _firestore.collection('chat_rooms').add({
        'participants': participants,
        'lastMessage': '',
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
        'metadata': {
          ...?extraMetadata,
          user1Id: {
            'name': user1Name,
            'avatar': user1Avatar ?? '',
          },
          user2Id: {
            'name': user2Name,
            'avatar': user2Avatar ?? '',
          },
        },
      });
      return doc.id;
    }
  }
}
