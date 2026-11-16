import 'package:auto_hub_app/features/contact_support/data/datasources/chat_remote_datasource.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_message.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_room_info.dart';
import 'package:auto_hub_app/features/contact_support/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDatasource);

  final ChatRemoteDatasource _remoteDatasource;

  @override
  Future<List<ChatMessage>> getMessages(String chatRoomId) async {
    return _remoteDatasource.getMessages(chatRoomId);
  }

  @override
  Future<ChatRoomInfo> getRoomInfo(String chatRoomId) async {
    return _remoteDatasource.getRoomById(chatRoomId);
  }

  @override
  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    await _remoteDatasource.sendMessage(
      chatRoomId,
      text: message.text,
      attachmentUrl: message.attachmentUrl,
    );
  }
}
