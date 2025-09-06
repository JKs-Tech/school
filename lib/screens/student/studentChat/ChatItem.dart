class ChatItem {
  String? chatId;
  String? receiver;
  String? sender;
  String? msg;
  String? imageMsg;
  String? name;
  String? type;
  bool? isSent;
  String? image;
  String? time;
  int? duration;
  int? createdAt;

  ChatItem({
    this.chatId,
    this.receiver,
    this.sender,
    this.msg,
    this.imageMsg,
    this.name,
    this.type,
    this.isSent,
    this.image,
    this.time,
    this.duration,
    this.createdAt,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      chatId: json['chatId']?.toString(),
      receiver: json['receiver']?.toString(),
      sender: json['sender']?.toString(),
      msg: json['msg']?.toString(),
      imageMsg: json['imageMsg']?.toString(),
      name: json['name']?.toString(),
      type: json['type']?.toString(),
      isSent: json['isSent'] as bool?,
      image: json['image']?.toString(),
      time: json['time']?.toString(),
      duration: json['duration'] as int?,
      createdAt: json['createdAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'receiver': receiver,
      'sender': sender,
      'msg': msg,
      'imageMsg': imageMsg,
      'name': name,
      'type': type,
      'isSent': isSent,
      'image': image,
      'time': time,
      'duration': duration,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'ChatItem{chatId: $chatId, sender: $sender, receiver: $receiver, msg: $msg, type: $type, isSent: $isSent, time: $time, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatItem && other.chatId == chatId;
  }

  @override
  int get hashCode => chatId.hashCode;
}
