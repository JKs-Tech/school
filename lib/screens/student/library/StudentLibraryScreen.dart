import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/library/LibraryBooksListScreen.dart';
import 'package:infixedu/screens/student/library/StudentBook.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentLibraryScreen extends StatefulWidget {
  const StudentLibraryScreen({super.key});

  @override
  _StudentLibraryScreenState createState() => _StudentLibraryScreenState();
}

class _StudentLibraryScreenState extends State<StudentLibraryScreen> {
  List<StudentBook> bookList = [];

  bool isLoading = false;
  String _token = '', _id = '';
  int _studentId = 0;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'studentId': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getLibraryBookIssuedUrl(),
        ),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('response books = ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        bookList.clear();

        if (jsonData is List) {
          for (var data in jsonData) {
            bookList.add(StudentBook.fromJson(data));
          }
        }
      }
    } catch (e) {
      print('student lib screen error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(
        title: 'Library',
        rightWidget: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LibraryBooksListScreen(),
                ),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_open_book.png',
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text("Books", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CupertinoActivityIndicator())
              : bookList.isEmpty
              ? Center(
                child: Container(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      Text('No Data Available'),
                    ],
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ListView.builder(
                  itemCount: bookList.length,
                  itemBuilder: (context, index) {
                    return StudentLibraryBookItem(book: bookList[index]);
                  },
                ),
              ),
    );
  }
}

class StudentLibraryBookItem extends StatelessWidget {
  final StudentBook book;

  const StudentLibraryBookItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic_closed_book.png',
                  width: 20,
                  height: 20,
                ),
                SizedBox(width: 10),
                Text(
                  book.bookName ?? "", // Replace with appropriate data
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/images/ic_calender.png",
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Issue Date: ${book.issueDate}', // Replace with appropriate data
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_open_book.png',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Book No: ${book.bookNo}', // Replace with appropriate data
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_calender.png',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Due Return Date: ${book.dueReturnDate}', // Replace with appropriate data
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/ic_calender.png',
                      width: 20,
                      height: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Return Date: ${book.returnDate}', // Replace with appropriate data
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: book.status == '1' ? Colors.green : Colors.red,
                      ),
                      child: Text(
                        book.status == '1' ? 'Returned' : 'Not Returned',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
