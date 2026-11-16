import 'package:flutter/material.dart';

class ChatRoomInfo {
  const ChatRoomInfo({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.isOnline,
    this.chatRoomId,
    this.unreadCount = 0,
    this.lastMessage,
  });

  factory ChatRoomInfo.fromJson(Map<String, dynamic> json) {
    return ChatRoomInfo(
      chatRoomId: json['chatRoomId'] as String?,
      name: json['name'] as String? ?? 'AutoHub Support',
      initials: json['initials'] as String? ?? 'AS',
      avatarColor: const Color(0xFF0DA0CE),
      isOnline: json['isOnline'] as bool? ?? true,
      unreadCount: json['unreadCount'] as int? ?? 0,
      lastMessage: json['lastMessage'] as String?,
    );
  }

  final String? chatRoomId;
  final String name;
  final String initials;
  final Color avatarColor;
  final bool isOnline;
  final int unreadCount;
  final String? lastMessage;
}
