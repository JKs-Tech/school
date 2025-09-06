import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'student/MarkStudentAttendanceClassListScreen.dart';
import 'student/ViewStudentAttendanceScreen.dart';
import 'staff/MarkStaffAttendanceScreen.dart';
import 'staff/ViewStaffAttendanceScreen.dart';
import '../../applyLeave/ApplyLeave.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  _AdminAttendanceScreenState createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Attendance'),
      body: SafeArea(
        child: Center(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
            children: [
              AttendanceOptionCard(
                title: 'Mark Student Attendance',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MarkStudentAttendanceClassListScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              AttendanceOptionCard(
                title: 'View Student Attendance',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewStudentAttendanceScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              AttendanceOptionCard(
                title: 'Mark Staff Attendance',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkStaffAttendanceScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              AttendanceOptionCard(
                title: 'View Staff Attendance',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewStaffAttendanceScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplyLeave(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.blue, // Set button background color here
                    foregroundColor: Colors.white, // Set text color here
                  ),
                  child: Text('+Apply For Leave')),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceOptionCard extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const AttendanceOptionCard({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    );
  }
}
