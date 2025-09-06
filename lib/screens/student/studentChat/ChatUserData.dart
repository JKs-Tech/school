class ChatUserData {
  String? staffId;
  String? staffName;
  String? staffSurname;
  String? lastMsg;
  int? lastMsgCreatedAt;
  int? unreadCount;
  String? chatConnectionId;

  ChatUserData({
    this.staffId,
    this.staffName,
    this.staffSurname,
    this.lastMsg,
    this.lastMsgCreatedAt,
    this.unreadCount,
    this.chatConnectionId,
  });

  factory ChatUserData.fromJson(Map<String, dynamic> json) {
    return ChatUserData(
      staffId: json['staff_id'],
      staffName: json['staff_name'],
      staffSurname: json['staff_surname'],
      lastMsg: json['last_msg'] ?? '',
      lastMsgCreatedAt: json['last_msg_created_at'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      chatConnectionId: json['chat_connection_id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'staff_name': staffName,
      'staff_surname': staffSurname,
      'last_msg': lastMsg ?? '',
      'last_msg_created_at': lastMsgCreatedAt ?? 0,
      'unread_count': unreadCount ?? 0,
      'chat_connection_id': chatConnectionId ?? '',
    };
  }
}
