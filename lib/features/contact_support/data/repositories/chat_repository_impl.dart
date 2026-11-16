import 'package:auto_hub_app/features/contact_support/data/datasources/chat_remote_datasource.dart';
import 'package:auto_hub_app/features/contact_support/data/repositories/mock_chat_repository.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_message.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_room_info.dart';
import 'package:auto_hub_app/features/contact_support/domain/repositories/chat_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._remoteDatasource);

  final ChatRemoteDatasource _remoteDatasource;
  final MockChatRepository _fallback = MockChatRepository();

  @override
  Future<List<ChatMessage>> getMessages(String chatRoomId) async {
    try {
      final list = await _remoteDatasource.getMessages(chatRoomId);
      if (list.isNotEmpty) return list;
      return await _fallback.getMessages(chatRoomId);
    } catch (_) {
      return _fallback.getMessages(chatRoomId);
    }
  }

  @override
  Future<ChatRoomInfo> getRoomInfo(String chatRoomId) async {
    try {
      return await _remoteDatasource.getRoomById(chatRoomId);
    } catch (_) {
      return _fallback.getRoomInfo(chatRoomId);
    }
  }

  @override
  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    try {
      await _remoteDatasource.sendMessage(
        chatRoomId,
        text: message.text,
        attachmentUrl: message.attachmentUrl,
      );
    } catch (_) {
      await _fallback.sendMessage(chatRoomId, message);
    }
  }
}

