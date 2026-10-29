enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;
  final String? attachmentUrl;
  final String? type; // 'text', 'voice', 'love_note'

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.attachmentUrl,
    this.type = 'text',
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    MessageStatus parseStatus(String? statusStr) {
      switch (statusStr) {
        case 'read':
          return MessageStatus.read;
        case 'delivered':
          return MessageStatus.delivered;
        default:
          return MessageStatus.sent;
      }
    }

    return MessageModel(
      id: id,
      senderId: map['sender_id'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      status: parseStatus(map['status']),
      attachmentUrl: map['attachment_url'],
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.name,
      'attachment_url': attachmentUrl,
      'type': type,
    };
  }

  MessageModel copyWith({
    MessageStatus? status,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      status: status ?? this.status,
      attachmentUrl: attachmentUrl,
      type: type,
    );
  }
}
