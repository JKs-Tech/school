import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/library/LibraryBook.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class LibraryBooksListScreen extends StatefulWidget {
  const LibraryBooksListScreen({super.key});

  @override
  _LibraryBooksListScreenState createState() => _LibraryBooksListScreenState();
}

class _LibraryBooksListScreenState extends State<LibraryBooksListScreen> {
  List<LibraryBook> libraryBookList = [];
  bool isLoading = false;
  String _token = '', _id = '', currency = '';

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _token = await Utils.getStringValue('token');
    _id = await Utils.getStringValue('id');
    currency = await Utils.getStringValue('currency');
    getDataFromApi();
  }

  Future<void> getDataFromApi() async {
    setState(() {
      isLoading = true;
    });

    try {
      var request = http.Request(
        'GET',
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getLibraryBooksUrl()),
      );
      request.body = json.encode({
        'schoolId': await Utils.getStringValue('schoolId'),
      });
      request.headers.addAll(Utils.setHeaderNew(_token, _id));
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final result = jsonDecode(await response.stream.bytesToString());
        List<dynamic> dataArray = result['data'];
        libraryBookList =
            dataArray.map((data) => LibraryBook.fromJson(data)).toList();
      } else {
        showErrorSnackBar('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorSnackBar(String message) {
    print('lib books list error = $message');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Library'),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : libraryBookList.isEmpty
                ? Center(
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
                )
                : ListView.builder(
                  itemCount: libraryBookList.length,
                  itemBuilder: (context, index) {
                    return StudentLibraryBookAdapterItem(
                      libraryBook: libraryBookList[index],
                      currency: currency,
                    );
                  },
                ),
      ),
    );
  }
}

class StudentLibraryBookAdapterItem extends StatelessWidget {
  final LibraryBook libraryBook;
  final String currency;

  const StudentLibraryBookAdapterItem({
    super.key,
    required this.libraryBook,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/ic_closed_book.png',
                  width: 24,
                  height: 24,
                  color: Colors.black,
                ),
                SizedBox(width: 8),
                Text(
                  libraryBook.bookTitle ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Author: ${libraryBook.author}'),
              subtitle: Text('Publisher: ${libraryBook.publish}'),
            ),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            ListTile(
              title: Text('Subject: ${libraryBook.subject}'),
              subtitle: Text('Created On: ${libraryBook.postDate}'),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rack No: ${libraryBook.rackNo}'),
                    Text('Quantity: ${libraryBook.qty}'),
                  ],
                ),
                Text(
                  'Price: $currency${libraryBook.perUnitCost}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
