import 'package:auto_hub_app/features/contact_support/data/datasources/chat_remote_datasource.dart';
import 'package:auto_hub_app/features/messages/domain/models/message_model.dart';
import 'package:auto_hub_app/injection.dart';
import 'package:flutter/material.dart';

class MessagesRepository {
  factory MessagesRepository([ChatRemoteDatasource? datasource]) {
    if (datasource != null) {
      _instance = MessagesRepository._internal(datasource);
    }
    return _instance;
  }

  MessagesRepository._internal(this._datasource);

  static MessagesRepository _instance = MessagesRepository._internal(
    getIt<ChatRemoteDatasource>(),
  );

  final ChatRemoteDatasource _datasource;

  List<LiveChatConversation> _conversations = [];
  final Map<String, List<ChatMessage>> _messages = {};

  Future<List<LiveChatConversation>> fetchConversations({String type = 'all'}) async {
    try {
      final rooms = await _datasource.getRooms(type: type);
      _conversations = rooms.map((r) {
        return LiveChatConversation(
          name: r.name,
          lastMessage: r.lastMessage ?? '',
          time: 'Recent',
          initials: r.initials,
          avatarColor: r.avatarColor,
          chatRoomId: r.chatRoomId ?? '',
          isOnline: r.isOnline,
          unreadCount: r.unreadCount,
        );
      }).toList();
      return _conversations;
    } catch (_) {
      return _conversations;
    }
  }

  List<LiveChatConversation> getConversations() => _conversations.toList();

  Future<LiveChatConversation?> fetchConversationById(String roomId) async {
    try {
      final r = await _datasource.getRoomById(roomId);
      final convo = LiveChatConversation(
        name: r.name,
        lastMessage: r.lastMessage ?? '',
        time: 'Recent',
        initials: r.initials,
        avatarColor: r.avatarColor,
        chatRoomId: r.chatRoomId ?? roomId,
        isOnline: r.isOnline,
        unreadCount: r.unreadCount,
      );
      final idx = _conversations.indexWhere((c) => c.chatRoomId == roomId);
      if (idx != -1) {
        _conversations[idx] = convo;
      } else {
        _conversations.add(convo);
      }
      return convo;
    } catch (_) {
      return getConversationById(roomId);
    }
  }

  LiveChatConversation? getConversationById(String roomId) {
    try {
      return _conversations.firstWhere((c) => c.chatRoomId == roomId);
    } catch (_) {
      return null;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String roomId, {int limit = 50}) async {
    try {
      final remoteMsgs = await _datasource.getMessages(roomId, limit: limit);
      final mapped = remoteMsgs.map((m) {
        return ChatMessage(
          text: m.text,
          time: m.time,
          isSender: m.isSender,
          isSent: m.isSent,
        );
      }).toList();
      _messages[roomId] = mapped;
      return mapped;
    } catch (_) {
      return _messages[roomId] ?? [];
    }
  }

  List<ChatMessage> getMessages(String roomId) {
    return _messages[roomId]?.toList() ?? [];
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    if (!_messages.containsKey(roomId)) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.insert(0, message);

    try {
      final sent = await _datasource.sendMessage(roomId, text: message.text);
      final sentMessage = ChatMessage(
        text: sent.text,
        time: sent.time,
        isSender: sent.isSender,
        isSent: true,
      );
      if (_messages[roomId]!.isNotEmpty) {
        _messages[roomId]![0] = sentMessage;
      }
    } catch (_) {
      if (_messages[roomId]!.isNotEmpty) {
        _messages[roomId]![0] = ChatMessage(
          text: message.text,
          time: message.time,
          isSender: true,
          isSent: false,
        );
      }
    }
  }

  Future<void> markRoomAsRead(String roomId) async {
    try {
      await _datasource.markRoomAsRead(roomId);
      final idx = _conversations.indexWhere((c) => c.chatRoomId == roomId);
      if (idx != -1) {
        final old = _conversations[idx];
        _conversations[idx] = LiveChatConversation(
          name: old.name,
          lastMessage: old.lastMessage,
          time: old.time,
          initials: old.initials,
          avatarColor: old.avatarColor,
          isOnline: old.isOnline,
          unreadCount: 0,
          chatRoomId: old.chatRoomId,
        );
      }
    } catch (_) {}
  }

  void markAllAsRead() {
    _conversations = _conversations.map((convo) {
      return LiveChatConversation(
        name: convo.name,
        lastMessage: convo.lastMessage,
        time: convo.time,
        initials: convo.initials,
        avatarColor: convo.avatarColor,
        isOnline: convo.isOnline,
        unreadCount: 0,
        chatRoomId: convo.chatRoomId,
      );
    }).toList();
  }

  void clearChat(String roomId) {
    _messages[roomId] = [];
  }

  void deleteConversation(String roomId) {
    _conversations.removeWhere((c) => c.chatRoomId == roomId);
    _messages.remove(roomId);
  }

  void deleteAllConversations() {
    _conversations = [];
    _messages.clear();
  }
}
