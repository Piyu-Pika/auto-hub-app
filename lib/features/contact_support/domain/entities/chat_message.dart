class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.time,
    required this.isSender,
    this.isSent = true,
    this.id,
    this.attachmentUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sentAtStr = json['sentAt'] as String?;
    var timeFormatted = 'Just now';
    if (sentAtStr != null) {
      final dt = DateTime.tryParse(sentAtStr);
      if (dt != null) {
        final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = dt.hour >= 12 ? 'PM' : 'AM';
        timeFormatted = '$hour:$minute $period';
      }
    }

    return ChatMessage(
      id: json['id'] as String?,
      text: json['text'] as String? ?? '',
      time: timeFormatted,
      isSender: json['isSender'] as bool? ?? false,
      isSent: (json['status'] as String? ?? 'sent') != 'sending',
      attachmentUrl: json['attachmentUrl'] as String?,
    );
  }

  final String text;
  final String time;
  final bool isSender;
  final bool isSent;
  final String? id;
  final String? attachmentUrl;
}
