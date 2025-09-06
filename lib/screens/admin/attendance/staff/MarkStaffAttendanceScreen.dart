import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';

class MarkStaffAttendanceScreen extends StatefulWidget {
  const MarkStaffAttendanceScreen({super.key});

  @override
  _MarkStaffAttendanceScreenState createState() =>
      _MarkStaffAttendanceScreenState();
}

class _MarkStaffAttendanceScreenState extends State<MarkStaffAttendanceScreen> {
  List<StaffAttendance> staffAttendances = [];

  @override
  void initState() {
    super.initState();
    staffAttendances = List.generate(
      20,
      (index) => StaffAttendance(id: index + 1, name: 'Staff ${index + 1}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Mark Staff Attendance'),
      body: SafeArea(
        child: ListView.builder(
          itemCount: staffAttendances.length,
          itemBuilder: (context, index) {
            return StaffAttendanceCard(
              staffAttendance: staffAttendances[index],
            );
          },
        ),
      ),
    );
  }
}

class StaffAttendanceCard extends StatefulWidget {
  final StaffAttendance staffAttendance;

  const StaffAttendanceCard({super.key, required this.staffAttendance});

  @override
  _StaffAttendanceCardState createState() => _StaffAttendanceCardState();
}

class _StaffAttendanceCardState extends State<StaffAttendanceCard> {
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
                  widget.staffAttendance.id.toString(),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  widget.staffAttendance.name,
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

class StaffAttendance {
  final int id;
  final String name;

  StaffAttendance({required this.id, required this.name});
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
