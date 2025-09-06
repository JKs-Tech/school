import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

String getAttendanceType(String type) {
  String attendanceValue = "-";
  if (type == "Present") {
    attendanceValue = "P";
  } else if (type == "Absent") {
    attendanceValue = "A";
  } else if (type == "Half Day") {
    attendanceValue = "F";
  } else if (type == "Late") {
    attendanceValue = "L";
  } else if (type == "Holiday") {
    attendanceValue = "H";
  }
  return attendanceValue;
}

class AttendanceCalenderData {
  final String date;
  final String type;

  AttendanceCalenderData({required this.date, required this.type});

  factory AttendanceCalenderData.fromJson(Map<String, dynamic> json) {
    return AttendanceCalenderData(date: json['date'], type: json['type']);
  }
}

class AttendanceSubjectWiseData {
  final String subject;
  final String time;
  final String roomNo;
  final String type;
  final String remark;

  AttendanceSubjectWiseData({
    required this.subject,
    required this.time,
    required this.roomNo,
    required this.type,
    required this.remark,
  });

  factory AttendanceSubjectWiseData.fromJson(Map<String, dynamic> json) {
    return AttendanceSubjectWiseData(
      subject: '${json['name']}(${json['code']})',
      time: json['time_from'] + "-" + json['time_to'],
      roomNo: json['room_no'],
      type: getAttendanceType(json['type']),
      remark: json['remark'],
    );
  }
}

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreenState createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  List<AttendanceCalenderData> calenderDataList = [];
  List<AttendanceSubjectWiseData> subjectWiseDataList = [];
  String _token = '', _id = '', attendanceType = '';
  int _studentId = 0;
  bool isLoading = false;
  EventList<Event> _markedDateMap = EventList<Event>(events: {});
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await _loadTokenAndId();
    _currentDate = DateTime.now();
    Map<String, dynamic> params = {
      'student_id': _studentId.toString(),
      "year": _currentDate.year.toString(),
      "month": _currentDate.month.toString(),
      "date": DateFormat('yyyy-MM-dd').format(_currentDate),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    fetchData(params);
  }

  Future<void> _loadTokenAndId() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
  }

  Future<void> fetchData(Map<String, dynamic> params) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getAttendenceRecordsUrl(),
        ),
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      print('response = ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        await processData(jsonData);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> processData(Map<String, dynamic> jsonData) async {
    print('jsonData = $jsonData');
    final List<dynamic> dataList = jsonData['data'];
    attendanceType = jsonData['attendence_type'];
    print('dataList = $dataList');
    print('attendanceType = $attendanceType');
    if ('0' == attendanceType) {
      calenderDataList =
          dataList.map((data) {
            return AttendanceCalenderData.fromJson(data);
          }).toList();
      await _createEventList();
    } else {
      subjectWiseDataList =
          dataList.map((data) {
            return AttendanceSubjectWiseData.fromJson(data);
          }).toList();
    }
    print('subjectWiseDataList = $subjectWiseDataList');
    print('calenderDataList = $calenderDataList');
  }

  Future<void> _createEventList() async {
    print('calenderDataList = $calenderDataList');
    print('_markedDateMap = $_markedDateMap');
    _markedDateMap = EventList<Event>(events: {});
    for (AttendanceCalenderData event in calenderDataList) {
      final DateTime eventDate = DateTime.parse(event.date);
      final String eventType = event.type;

      Color eventColor = _getAttendanceColor(eventType);
      _markedDateMap.addAll(eventDate, [
        Event(
          date: eventDate,
          title: eventType,
          dot: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.0),
            color: eventColor,
            height: 5.0,
            width: 5.0,
          ),
        ),
      ]);
    }
    print('_markedDateMap = $_markedDateMap');
  }

  Future<void> _handleCalendarChange(DateTime date) async {
    if (date.month == DateTime.now().month) {
      _currentDate = DateTime.now();
    } else {
      _currentDate = date;
    }
    Map<String, dynamic> params = {
      'student_id': _studentId.toString(),
      "year": date.year.toString(),
      "month": date.month.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    fetchData(params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Attendance'),
      body: SafeArea(
        child:
            attendanceType == null
                ? Center(child: CupertinoActivityIndicator())
                : attendanceType == '0'
                ? calenderView()
                : subjectWiseView(),
      ),
    );
  }

  Widget _buildAttendanceCircle(String attendance) {
    Color circleColor = _getAttendanceColor(attendance);
    return Row(
      children: [
        Container(
          width: 15.0,
          height: 15.0,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
        ),
        SizedBox(width: 8.0),
        Text(
          attendance,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget colourInstructionLayout() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildAttendanceCircle('Present'),
                  SizedBox(height: 8.0),
                  _buildAttendanceCircle('Half Day'),
                ],
              ),
              Column(
                children: [
                  _buildAttendanceCircle('Absent'),
                  SizedBox(height: 8.0),
                  _buildAttendanceCircle('Holiday'),
                ],
              ),
              Column(
                children: [
                  _buildAttendanceCircle('Late'),
                  SizedBox(height: 8.0),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget calenderView() {
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Stack(
        children: [
          ListView(
            shrinkWrap: true,
            children: <Widget>[
              SizedBox(
                height: Get.height * 0.5,
                child: CalendarCarousel<Event>(
                  weekDayPadding: EdgeInsets.zero,
                  onDayPressed: (DateTime date, List<Event> events) {
                    setState(() {
                      _currentDate = date;
                    });
                  },
                  onCalendarChanged: _handleCalendarChange,
                  weekendTextStyle: Theme.of(context).textTheme.titleLarge,
                  thisMonthDayBorderColor: Colors.grey,
                  daysTextStyle: Theme.of(context).textTheme.headlineMedium,
                  showOnlyCurrentMonthDate: false,
                  headerTextStyle: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: ScreenUtil().setSp(15.0)),
                  weekdayTextStyle: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(
                    fontSize: ScreenUtil().setSp(15.0),
                    fontWeight: FontWeight.w500,
                  ),
                  weekFormat: false,
                  markedDatesMap: _markedDateMap,
                  selectedDateTime: _currentDate,
                  todayButtonColor: Colors.transparent,
                  todayBorderColor: Colors.transparent,
                  todayTextStyle: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: Colors.black),
                ),
              ),
              colourInstructionLayout(),
            ],
          ),
        ],
      ),
    );
  }

  Widget subjectWiseView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: subjectWiseDataList.length,
            itemBuilder: (context, index) {
              return StudentSubjectAttendanceCard(
                attendanceSubjectWiseData: subjectWiseDataList[index],
              );
            },
          ),
        ),
        colourInstructionLayout(),
      ],
    );
  }
}

class StudentSubjectAttendanceCard extends StatelessWidget {
  final AttendanceSubjectWiseData attendanceSubjectWiseData;

  const StudentSubjectAttendanceCard({
    super.key,
    required this.attendanceSubjectWiseData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attendanceSubjectWiseData.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  attendanceSubjectWiseData.time,
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  attendanceSubjectWiseData.roomNo,
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  attendanceSubjectWiseData.type,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getAttendanceColor(attendanceSubjectWiseData.type),
                  ),
                ),
                Visibility(
                  visible: attendanceSubjectWiseData.remark.isNotEmpty,
                  child: Text(
                    attendanceSubjectWiseData.remark,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic,
                    ),
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

Color _getAttendanceColor(String attendance) {
  if (attendance == 'P' || attendance == 'Present') {
    return Colors.green;
  } else if (attendance == 'A' || attendance == 'Absent') {
    return Colors.red;
  } else if (attendance == 'F' || attendance == 'Half Day') {
    return Colors.orange;
  } else if (attendance == 'L' || attendance == 'Late') {
    return Colors.brown;
  } else if (attendance == 'H' || attendance == 'Holiday') {
    return Colors.grey;
  } else {
    return Colors.black;
  }
}
