class HomeworkResponse {
  List<Homeworklist>? homeworklist;
  String? classId;
  String? sectionId;
  String? subjectId;
  String? documentUrl;
  String? homeworkFile;

  HomeworkResponse({
    this.homeworklist,
    this.classId,
    this.sectionId,
    this.subjectId,
    this.documentUrl,
    this.homeworkFile,
  });

  HomeworkResponse.fromJson(Map<String, dynamic> json) {
    if (json['homeworklist'] != null) {
      homeworklist = <Homeworklist>[];
      json['homeworklist'].forEach((v) {
        homeworklist!.add(Homeworklist.fromJson(v));
      });
    }
    classId = json['class_id'];
    sectionId = json['section_id'];
    subjectId = json['subject_id'];
    documentUrl = json['document_url'];
    homeworkFile = json['homework_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (homeworklist != null) {
      data['homeworklist'] = homeworklist!.map((v) => v.toJson()).toList();
    }
    data['class_id'] = classId;
    data['section_id'] = sectionId;
    data['subject_id'] = subjectId;
    data['document_url'] = documentUrl;
    data['homework_file'] = homeworkFile;
    return data;
  }
}

class Homeworklist {
  String? id;
  String? classId;
  String? sectionId;
  String? sessionId;
  String? homeworkDate;
  String? submitDate;
  String? staffId;
  String? subjectGroupSubjectId;
  String? subjectId;
  String? description;
  String? createDate;
  String? evaluationDate;
  String? document;
  String? createdBy;
  String? evaluatedBy;
  String? name;
  String? section;

  String? staffCreated;
  String? staffEvaluated;
  String? homeworkEvaluationId;
  String? homeworkUploadedFile;
  String? homeworkDesc;
  String? homeworkFile;

  Homeworklist({
    this.id,
    this.classId,
    this.sectionId,
    this.sessionId,
    this.homeworkDate,
    this.submitDate,
    this.staffId,
    this.subjectGroupSubjectId,
    this.subjectId,
    this.description,
    this.createDate,
    this.evaluationDate,
    this.document,
    this.createdBy,
    this.evaluatedBy,
    this.name,
    this.section,
    this.staffCreated,
    this.staffEvaluated,
    this.homeworkEvaluationId,
    this.homeworkUploadedFile,
    this.homeworkDesc,
    this.homeworkFile,
  });

  Homeworklist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    classId = json['class_id'];
    sectionId = json['section_id'];
    sessionId = json['session_id'];
    homeworkDate = json['homework_date'];
    submitDate = json['submit_date'];
    staffId = json['staff_id'];
    subjectGroupSubjectId = json['subject_group_subject_id'];
    subjectId = json['subject_id'];
    description = json['description'];
    createDate = json['create_date'];
    evaluationDate = json['evaluation_date'];
    document = json['document'];
    createdBy = json['created_by'];
    evaluatedBy = json['evaluated_by'];
    name = json['name'];
    section = json['section'];

    staffCreated = json['staff_created'];
    staffEvaluated = json['staff_evaluated'];
    homeworkEvaluationId = json['homework_evaluation_id'];
    homeworkUploadedFile = json['homework_uploaded_file'];
    homeworkDesc = json['homework_desc'];
    homeworkFile = json['homework_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['class_id'] = classId;
    data['section_id'] = sectionId;
    data['session_id'] = sessionId;
    data['homework_date'] = homeworkDate;
    data['submit_date'] = submitDate;
    data['staff_id'] = staffId;
    data['subject_group_subject_id'] = subjectGroupSubjectId;
    data['subject_id'] = subjectId;
    data['description'] = description;
    data['create_date'] = createDate;
    data['evaluation_date'] = evaluationDate;
    data['document'] = document;
    data['created_by'] = createdBy;
    data['evaluated_by'] = evaluatedBy;
    data['name'] = name;
    data['section'] = section;

    data['staff_created'] = staffCreated;
    data['staff_evaluated'] = staffEvaluated;
    data['homework_evaluation_id'] = homeworkEvaluationId;
    data['homework_uploaded_file'] = homeworkUploadedFile;
    data['homework_desc'] = homeworkDesc;
    data['homework_file'] = homeworkFile;
    return data;
  }
}
