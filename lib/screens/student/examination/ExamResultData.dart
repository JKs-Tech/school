class ExamResultData {
  final String? examGroupClassBatchExamId;
  final String? examGroupId;
  final String? exam;
  final String? examGroup;
  final String? description;
  final String? examType;
  final List<SubjectResult>? subjectResult;
  final String? totalMaxMarks;
  final String? totalGetMarks;
  final String? totalExamPoints;
  final String? examQualityPoints;
  final String? examCreditHour;
  final String? examResultStatus;
  final String? isConsolidate;
  final String? percentage;
  final String? division;
  final String? examGrade;

  ExamResultData({
    this.examGroupClassBatchExamId,
    this.examGroupId,
    this.exam,
    this.examGroup,
    this.description,
    this.examType,
    this.subjectResult,
    this.totalMaxMarks,
    this.totalGetMarks,
    this.totalExamPoints,
    this.examQualityPoints,
    this.examCreditHour,
    this.examResultStatus,
    this.isConsolidate,
    this.percentage,
    this.division,
    this.examGrade,
  });

  factory ExamResultData.fromJson(Map<String, dynamic> json) {
    return ExamResultData(
      examGroupClassBatchExamId:
          json['exam_group_class_batch_exam_id']?.toString(),
      examGroupId: json['exam_group_id']?.toString(),
      exam: json['exam']?.toString(),
      examGroup: json['exam_group']?.toString(),
      description: json['description']?.toString(),
      examType: json['exam_type']?.toString(),
      subjectResult:
          (json['subject_result'] as List?)
              ?.map((e) => SubjectResult.fromJson(e))
              .toList(),
      totalMaxMarks: json['total_max_marks']?.toString(),
      totalGetMarks: json['total_get_marks']?.toString(),
      totalExamPoints: json['total_exam_points']?.toString(),
      examQualityPoints: json['exam_quality_points']?.toString(),
      examCreditHour: json['exam_credit_hour']?.toString(),
      examResultStatus: json['exam_result_status']?.toString(),
      isConsolidate: json['is_consolidate']?.toString(),
      percentage: json['percentage']?.toString(),
      division: json['division']?.toString(),
      examGrade: json['exam_grade']?.toString(),
    );
  }
}

class SubjectResult {
  final String? name;
  final String? code;
  final String? examGroupClassBatchExamsId;
  final String? roomNo;
  final String? maxMarks;
  final String? minMarks;
  final String? subjectId;
  final String? attendance;
  final String? getMarks;
  final String? examGroupExamResultsId;
  final String? note;
  final String? duration;
  final String? creditHours;
  final String? examQualityPoints;
  final String? examGradePoint;
  final String? examGrade;

  SubjectResult({
    this.name,
    this.code,
    this.examGroupClassBatchExamsId,
    this.roomNo,
    this.maxMarks,
    this.minMarks,
    this.subjectId,
    this.attendance,
    this.getMarks,
    this.examGroupExamResultsId,
    this.note,
    this.duration,
    this.creditHours,
    this.examQualityPoints,
    this.examGradePoint,
    this.examGrade,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> json) {
    return SubjectResult(
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      examGroupClassBatchExamsId:
          json['exam_group_class_batch_exams_id']?.toString(),
      roomNo: json['room_no']?.toString(),
      maxMarks: json['max_marks']?.toString(),
      minMarks: json['min_marks']?.toString(),
      subjectId: json['subject_id']?.toString(),
      attendance: json['attendence']?.toString(),
      getMarks: json['get_marks']?.toString(),
      examGroupExamResultsId: json['exam_group_exam_results_id']?.toString(),
      note: json['note']?.toString(),
      duration: json['duration']?.toString(),
      creditHours: json['credit_hours']?.toString(),
      examQualityPoints: json['exam_quality_points']?.toString(),
      examGradePoint: json['exam_grade_point']?.toString(),
      examGrade: json['exam_grade']?.toString(),
    );
  }
}
