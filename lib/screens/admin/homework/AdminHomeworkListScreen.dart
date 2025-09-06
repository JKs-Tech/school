import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'Homework.dart';
import 'AdminCreateHomeworkScreen.dart';

class AdminHomeworkListScreen extends StatefulWidget {
  const AdminHomeworkListScreen({super.key});

  @override
  _AdminHomeworkListScreenState createState() =>
      _AdminHomeworkListScreenState();
}

class _AdminHomeworkListScreenState extends State<AdminHomeworkListScreen> {
  List<Homework> homeworkList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      homeworkList = await getHomeworkList();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<Homework>> getHomeworkList() async {
    return List.generate(
        20,
        (index) => Homework(
              classs: 'Class ${index + 1}',
              section: 'A-${index + 1}',
              subject: 'Math',
              homeworkDate: '2023-08-${index + 1}',
              submissionDate: '2023-09-${index + 1}',
              attachment: 'math_assignment_${index + 1}.pdf',
              description: '<p>Solve exercises ${index + 1}'
                  ' from the textbook.</p>',
            )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScreenAppBarWidget(title: 'Homework'),
        body: SafeArea(
          child: isLoading
              ? Center(child: CupertinoActivityIndicator())
              : ListView.builder(
                  itemCount: homeworkList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4, // Adjust elevation as needed
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Html(
                          data: homeworkList[index].description,
                          style: {
                            "body": Style(
                                fontSize: FontSize(16),
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          },
                        ),
                        subtitle: Text(
                            '${homeworkList[index].subject}/${homeworkList[index].homeworkDate}'),
                        onTap: () {
                          showHomeworkDetails(homeworkList[index]);
                        },
                      ),
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminCreateHomeworkScreen(
                    homeworkList: homeworkList,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            )));
  }

  void showHomeworkDetails(Homework homework) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Html(
                  data: homework.description,
                  style: {
                    "body": Style(
                        fontSize: FontSize(20),
                        color: Colors.black.withAlpha(153),
                        fontWeight: FontWeight.bold),
                  },
                ),
                SizedBox(height: 10),
                Text('Class: ${homework.classs}-${homework.section}'),
                Text('Subject: ${homework.subject}'),
                Text('Homework Date: ${homework.homeworkDate}'),
                Text('Submission Date: ${homework.submissionDate}'),
                Text('Attachment: ${homework.attachment}'),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          // Implement edit functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Edit')),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          // Implement delete functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Delete')),
                    SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Close')),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
