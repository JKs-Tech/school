import 'package:infixedu/utils/Utils.dart';

class Assignment {
  final String? id;
  final String? title;
  final String? date;
  final String? note;
  final String? file;

  Assignment({this.id, this.title, this.date, this.note, this.file});

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json["id"]?.toString(),
      title: json["title"]?.toString().trim(),
      date:
          json["date"] != null
              ? Utils.parseDate("yyyy-MM-dd", "dd/MM/yyyy", json["date"])
              : null,
      note: json["note"]?.toString().trim(),
      file: json["file"]?.toString(),
    );
  }

  // Helper methods for UI purposes
  String get displayTitle =>
      title?.isNotEmpty == true ? title! : 'Untitled Document';

  String get displayDate => date?.isNotEmpty == true ? date! : '';

  String get displayNote => note?.isNotEmpty == true ? note! : '';

  bool get hasFile => file?.isNotEmpty == true;

  bool get hasNote => note?.isNotEmpty == true;

  // Method to get file extension
  String get fileExtension {
    if (!hasFile) return '';
    final fileName = file!.split('/').last;
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  // Method to check if file is PDF
  bool get isPDF => fileExtension == 'pdf';

  // Method to check if file is image
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  // Method to check if file is document
  bool get isDocument {
    const docExtensions = ['doc', 'docx', 'txt', 'rtf'];
    return docExtensions.contains(fileExtension);
  }

  // Method to check if file is Excel
  bool get isExcel {
    const excelExtensions = ['xls', 'xlsx'];
    return excelExtensions.contains(fileExtension);
  }

  @override
  String toString() {
    return 'Assignment{id: $id, title: $title, date: $date, note: $note, file: $file}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assignment && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
