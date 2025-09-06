class Homework {
  final String? classs;
  final String? section;
  final String? subject;
  final String? homeworkDate;
  final String? submissionDate;
  final String? attachment;
  final String? description;

  Homework({
    this.classs,
    this.section,
    this.subject,
    this.homeworkDate,
    this.submissionDate,
    this.attachment,
    this.description,
  });
  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      classs: json['classs'] ?? '',
      section: json['section'] ?? '',
      subject: json['subject'] ?? '',
      homeworkDate: json['homeworkDate'] ?? '',
      submissionDate: json['submissionDate'] ?? '',
      attachment: json['attachment'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
