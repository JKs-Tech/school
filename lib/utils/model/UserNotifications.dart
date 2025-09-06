class UserNotifications {
  UserNotifications({
    this.id,
    this.title,
    this.date,
    this.message,
    this.visibleStudent,
    this.visibleStaff,
    this.visibleParent,
    this.createdBy,
    this.createdId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.classId,
    this.sectionId,
    this.sessionId,
  });

  dynamic id;
  String? title;
  DateTime? date;
  String? message;
  String? visibleStudent;
  String? visibleStaff;
  String? visibleParent;
  String? createdBy;
  dynamic createdId;
  String? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic classId;
  dynamic sectionId;
  dynamic sessionId;

  factory UserNotifications.fromJson(Map<String, dynamic> json) =>
      UserNotifications(
        id: json["id"],
        title: json["title"],
        date: DateTime.parse(json["date"]),
        message: json["message"],
        visibleStudent: json["visible_student"],
        visibleStaff: json["visible_staff"],
        visibleParent: json["visible_parent"],
        createdBy: json["created_by"],
        createdId: json["created_id"],
        isActive: json["is_active"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt:
            json["updated_at"] != null
                ? DateTime.parse(json["updated_at"])
                : null,
        classId: json["class_id"],
        sectionId: json["section_id"],
        sessionId: json["session_id"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "date": date?.toIso8601String(),
    "message": message,
    "visible_student": visibleStudent,
    "visible_staff": visibleStaff,
    "visible_parent": visibleParent,
    "created_by": createdBy,
    "created_id": createdId,
    "is_active": isActive,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "class_id": classId,
    "section_id": sectionId,
    "session_id": sessionId,
  };
}

class UserNotificationList {
  List<UserNotifications>? userNotifications;

  UserNotificationList({this.userNotifications});

  factory UserNotificationList.fromJson(List<dynamic> json) {
    List<UserNotifications> uploadedContent = [];

    uploadedContent = json.map((i) => UserNotifications.fromJson(i)).toList();

    return UserNotificationList(userNotifications: uploadedContent);
  }
}
