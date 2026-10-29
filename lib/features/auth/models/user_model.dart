class UserModel {
  final String uid;
  final String name;
  final String nickname;
  final String email;
  final String avatarUrl;
  final String partnerId;
  final bool isOnline;
  final DateTime lastSeen;
  final bool isTyping;

  const UserModel({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.email,
    required this.avatarUrl,
    required this.partnerId,
    this.isOnline = false,
    required this.lastSeen,
    this.isTyping = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      name: map['name'] ?? '',
      nickname: map['nickname'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      partnerId: map['partner_id'] ?? '',
      isOnline: map['is_online'] ?? false,
      lastSeen: map['last_seen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_seen'])
          : DateTime.now(),
      isTyping: map['is_typing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'nickname': nickname,
      'email': email,
      'avatar_url': avatarUrl,
      'partner_id': partnerId,
      'is_online': isOnline,
      'last_seen': lastSeen.millisecondsSinceEpoch,
      'is_typing': isTyping,
    };
  }

  UserModel copyWith({
    bool? isOnline,
    DateTime? lastSeen,
    bool? isTyping,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      nickname: nickname,
      email: email,
      avatarUrl: avatarUrl,
      partnerId: partnerId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
