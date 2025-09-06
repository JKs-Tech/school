import 'package:flutter/material.dart';
import 'MarkStudentAttendanceClassWiseList.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';

class MarkStudentAttendanceClassListScreen extends StatefulWidget {
  const MarkStudentAttendanceClassListScreen({super.key});

  @override
  _MarkStudentAttendanceClassListScreenState createState() => _MarkStudentAttendanceClassListScreenState();
}

class _MarkStudentAttendanceClassListScreenState extends State<MarkStudentAttendanceClassListScreen> {
  final List<String> classes = [
    'Class 6th A',
    'Class 6th B',
    'Class 7th A',
    'Class 7th B',
    'Class 8th A',
    'Class 8th B',
    // Add more classes as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Classes'),
      body: SafeArea(
        child: ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkStudentAttendanceClassWiseList(className: classes[index]),
                    ),
                  );
                },
                child: Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      classes[index],
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
