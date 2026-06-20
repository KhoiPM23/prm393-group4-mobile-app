import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../models/message_model.dart';

class MockMessageRepository implements MessageRepository {
  @override
  Future<List<MessageEntity>> getMessagesForProperty(String propertyId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MessageModel.mockList();
  }

  @override
  Future<MessageEntity> sendMessage(MessageEntity message) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return message;
  }
}
