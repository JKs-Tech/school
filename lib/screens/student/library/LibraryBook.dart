import 'package:infixedu/utils/Utils.dart';

class LibraryBook {
  final String? id;
  final String? bookTitle;
  final String? author;
  final String? subject;
  final String? publish;
  final String? rackNo;
  final String? qty;
  final String? perUnitCost;
  final String? postDate;

  LibraryBook({
    this.id,
    this.bookTitle,
    this.author,
    this.subject,
    this.publish,
    this.rackNo,
    this.qty,
    this.perUnitCost,
    this.postDate,
  });

  factory LibraryBook.fromJson(Map<String, dynamic> json) {
    return LibraryBook(
      id: json['id'],
      bookTitle: json['book_title'],
      author: json['author'],
      subject: json['subject'],
      publish: json['publish'],
      rackNo: json['rack_no'],
      qty: json['qty'],
      perUnitCost: json['perunitcost'],
      postDate: json['postdate'] == '0000-00-00'
          ? ''
          : Utils.parseDate(
              'yyyy-MM-dd',
              'dd/MM/yyyy',
              json['postdate'],
            ),
    );
  }
}
