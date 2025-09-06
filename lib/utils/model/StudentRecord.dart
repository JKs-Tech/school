// To parse this JSON data, do
//
//     final studentRecords = studentRecordsFromJson(jsonString);

import 'dart:convert';

StudentRecords studentRecordsFromJson(Map<String, dynamic> json) =>
    StudentRecords.fromJson(json);

String studentRecordsToJson(StudentRecords data) => json.encode(data.toJson());

class StudentRecords {
  StudentRecords({this.records});

  List<Record>? records;

  factory StudentRecords.fromJson(Map<String, dynamic> json) => StudentRecords(
    records: List<Record>.from(json["records"].map((x) => Record.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "records":
        records != null
            ? List<dynamic>.from(records!.map((x) => x.toJson()))
            : [],
  };
}

class Record {
  Record({
    this.id,
    this.studentId,
    this.fullName,
    this.className,
    this.sectionName,
    this.classId,
    this.sectionId,
    this.isDefault,
    this.isPromote,
    this.rollNo,
    this.sessionId,
    this.academicId,
    this.schoolId,
  });

  int? id;
  int? studentId;
  String? fullName;
  String? className;
  String? sectionName;
  int? classId;
  int? sectionId;
  int? isDefault;
  int? isPromote;
  String? rollNo;
  int? sessionId;
  int? academicId;
  int? schoolId;

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    id: json["id"],
    studentId: json["student_id"],
    fullName: json["full_name"],
    className: json["class"],
    sectionName: json["section"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "student_id": studentId,
    "full_name": fullName,
    "class": className,
    "section": sectionName,
    "class_id": classId,
    "section_id": sectionId,
    "is_default": isDefault,
    "is_promote": isPromote,
    "roll_no": rollNo,
    "session_id": sessionId,
    "academic_id": academicId,
    "school_id": schoolId,
  };
}
