import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';

class MarkStudentAttendanceClassWiseList extends StatefulWidget {
  final String className;

  const MarkStudentAttendanceClassWiseList({super.key, required this.className});

  @override
  _MarkStudentAttendanceClassWiseListState createState() =>
      _MarkStudentAttendanceClassWiseListState();
}

class _MarkStudentAttendanceClassWiseListState
    extends State<MarkStudentAttendanceClassWiseList> {
  List<StudentAttendance> studentAttendances = [];

  @override
  void initState() {
    super.initState();
    studentAttendances = List.generate(
      20,
      (index) => StudentAttendance(id: index + 1, name: 'Student ${index + 1}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: '${widget.className} Attendance'),
      body: SafeArea(
        child: ListView.builder(
          itemCount: studentAttendances.length,
          itemBuilder: (context, index) {
            return StudentAttendanceCard(
              studentAttendance: studentAttendances[index],
            );
          },
        ),
      ),
    );
  }
}

class StudentAttendanceCard extends StatefulWidget {
  final StudentAttendance studentAttendance;

  const StudentAttendanceCard({super.key, required this.studentAttendance});

  @override
  _StudentAttendanceCardState createState() => _StudentAttendanceCardState();
}

class _StudentAttendanceCardState extends State<StudentAttendanceCard> {
  AttendanceStatus? selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.studentAttendance.id.toString(),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  widget.studentAttendance.name,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Column(
              children: [
                Row(
                  children: [
                    AttendanceStatusRadioTile(
                      status: AttendanceStatus.present,
                      onChanged: (status) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      isSelected: selectedStatus == AttendanceStatus.present,
                    ),
                    AttendanceStatusRadioTile(
                      status: AttendanceStatus.absent,
                      onChanged: (status) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      isSelected: selectedStatus == AttendanceStatus.absent,
                    ),
                  ],
                ),
                Row(
                  children: [
                    AttendanceStatusRadioTile(
                      status: AttendanceStatus.late,
                      onChanged: (status) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      isSelected: selectedStatus == AttendanceStatus.late,
                    ),
                    AttendanceStatusRadioTile(
                      status: AttendanceStatus.leave,
                      onChanged: (status) {
                        setState(() {
                          selectedStatus = status;
                        });
                      },
                      isSelected: selectedStatus == AttendanceStatus.leave,
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceStatusRadioTile extends StatelessWidget {
  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus?> onChanged;
  final bool isSelected;

  const AttendanceStatusRadioTile({super.key, 
    required this.status,
    required this.onChanged,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<AttendanceStatus>(
            value: status,
            groupValue: isSelected ? status : null,
            onChanged: onChanged,
            activeColor: Colors.blue),
        Text(statusToString(status)),
      ],
    );
  }
}

enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
}

class StudentAttendance {
  final int id;
  final String name;

  StudentAttendance({required this.id, required this.name});
}

String statusToString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'Present';
    case AttendanceStatus.absent:
      return 'Absent';
    case AttendanceStatus.late:
      return 'Late';
    case AttendanceStatus.leave:
      return 'Leave';
  }
}
