import 'package:infixedu/utils/Utils.dart';

class StudentBook {
  final String? bookName;
  final String? authorName;
  final String? bookNo;
  final String? issueDate;
  final String? returnDate;
  final String? status;
  final String? dueReturnDate;

  StudentBook({
    this.bookName,
    this.authorName,
    this.bookNo,
    this.issueDate,
    this.returnDate,
    this.status,
    this.dueReturnDate,
  });

  factory StudentBook.fromJson(Map<String, dynamic> json) {
    return StudentBook(
      bookName: json['book_title'],
      authorName: json['author'],
      bookNo: json['book_no'],
      issueDate: json['issue_date'] != null ? Utils.parseDate("yyyy-MM-dd", "dd/MM/yyyy", json['issue_date']) : null,
      returnDate: json['return_date'] != null ? Utils.parseDate("yyyy-MM-dd", "dd/MM/yyyy", json['return_date']) : null,
      dueReturnDate: json['due_return_date'] != null ? Utils.parseDate("yyyy-MM-dd", "dd/MM/yyyy", json['due_return_date']) : null,
      status: json['is_returned'],
    );
  }
}
