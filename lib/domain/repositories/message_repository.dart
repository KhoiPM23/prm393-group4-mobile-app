import '../entities/message_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> getMessagesForProperty(String propertyId);
  Future<MessageEntity> sendMessage(MessageEntity message);
}
