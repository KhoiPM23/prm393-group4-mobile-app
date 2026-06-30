import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';
import '../datasources/mock_data.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.timestamp,
    required super.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp'] as String);
    } else {
      timestamp = DateTime.now();
    }

    return MessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: timestamp,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  static List<MessageModel> mockList() {
    return MockData.getMockMessages().map((e) => MessageModel.fromJson(e)).toList();
  }
}
