import 'package:auto_hub_app/core/errors/exceptions.dart';
import 'package:auto_hub_app/core/network/api_endpoints.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_message.dart';
import 'package:auto_hub_app/features/contact_support/domain/entities/chat_room_info.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract interface class ChatRemoteDatasource {
  Future<List<ChatRoomInfo>> getRooms({String type = 'all'});
  Future<ChatRoomInfo> getRoomById(String roomId);
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 30, String? before});
  Future<ChatMessage> sendMessage(String roomId, {required String text, String? attachmentUrl});
  Future<void> markRoomAsRead(String roomId);
  Future<int> getUnreadCount();
}

@LazySingleton(as: ChatRemoteDatasource)
class ChatRemoteDatasourceImpl implements ChatRemoteDatasource {
  ChatRemoteDatasourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<ChatRoomInfo>> getRooms({String type = 'all'}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatRooms,
        queryParameters: {'type': type},
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => ChatRoomInfo.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <ChatRoomInfo>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load conversations.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ChatRoomInfo> getRoomById(String roomId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatRoomById(roomId),
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return ChatRoomInfo.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      throw const ServerException(message: 'Chat room not found.');
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load chat room info.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 30,
    String? before,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatMessages(roomId),
        queryParameters: {
          'limit': limit,
          if (before != null) 'before': before,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is List) {
        return (envelope['data'] as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return <ChatMessage>[];
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to load messages.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<ChatMessage> sendMessage(
    String roomId, {
    required String text,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.chatMessages(roomId),
        data: {
          'text': text,
          if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
        },
      );

      final envelope = response.data;
      if (envelope != null && envelope['data'] is Map<String, dynamic>) {
        return ChatMessage.fromJson(envelope['data'] as Map<String, dynamic>);
      }
      return ChatMessage(text: text, time: 'Just now', isSender: true);
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
      throw ServerException(
        message: e.message ?? 'Failed to send message.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> markRoomAsRead(String roomId) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.chatRead(roomId),
      );
    } on DioException catch (e) {
      if (e.error is ServerException) throw e.error!;
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiEndpoints.chatUnreadCount,
      );

      final data = response.data?['data'] as Map<String, dynamic>?;
      return data?['total'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

