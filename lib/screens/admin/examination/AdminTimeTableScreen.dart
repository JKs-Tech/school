import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';

class AdminTimeTableScreen extends StatefulWidget {
  const AdminTimeTableScreen({super.key});

  @override
  _AdminTimeTableScreenState createState() => _AdminTimeTableScreenState();
}

class _AdminTimeTableScreenState extends State<AdminTimeTableScreen> {
  List<TimeTable> timeTableList = <TimeTable>[];
  TimeTableDataSource? timeTableDataSource;
  String? selectedClass;
  String? selectedExam;
  bool isLoading = false;
  Map<String, List<TimeTable>>? classMappingData;

  @override
  void initState() {
    super.initState();
    initTimeTableData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      timeTableList = getTimeTableData();
      timeTableDataSource = TimeTableDataSource(timeTableData: timeTableList);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScreenAppBarWidget(title: 'Time Table'),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonFormField<String>(
                          value: selectedClass,
                          onChanged: (newValue) {
                            setState(() {
                              selectedClass = newValue;
                            });
                          },
                          items: [
                            'Class 1',
                            'Class 2',
                            'Class 3',
                            'Class 4',
                            'Class 5'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration:
                              InputDecoration(hintText: 'Select Class'))),
                  SizedBox(height: 16),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: DropdownButtonFormField<String>(
                          value: selectedExam,
                          onChanged: (newValue) {
                            if (selectedClass != null &&
                                selectedExam != newValue) {
                              selectedExam = newValue;
                              getData();
                            }
                            setState(() {
                              selectedExam = newValue;
                            });
                          },
                          items: [
                            'I Mid Term Test',
                            'II Mid Term Test',
                            'Quarterly Exam',
                            'Half Yearly Exam',
                            'Final Exam'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration:
                              InputDecoration(hintText: 'Select Exam'))),
                ],
              ),
            ),
            SizedBox(height: 16),
            Expanded(
                child: isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : timeTableDataSource == null
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
                        : SfDataGrid(
                            source: timeTableDataSource ??
                                TimeTableDataSource(timeTableData: []),
                            columnWidthMode: ColumnWidthMode.fill,
                            columns: <GridColumn>[
                              GridColumn(
                                  columnName: 'subject',
                                  label: Container(
                                      padding: EdgeInsets.all(16.0),
                                      alignment: Alignment.center,
                                      child: Text('Subject',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'date',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Date',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'time',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Time',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'maxMarks',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Max Marks',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                            ],
                          ))
          ],
        ));
  }

  List<TimeTable> getTimeTableData() {
    if (classMappingData != null &&
        selectedClass != null &&
        selectedExam != null) {
      return classMappingData!["${selectedClass!}_${selectedExam!}"] ?? [];
    }
    return [];
  }

  Future<void> initTimeTableData() async {
    classMappingData = {
      'Class 1_I Mid Term Test': [
        TimeTable(10001, 'English', '26/01/2023', '01:01:01', 10),
        TimeTable(10002, 'Hindi', '26/01/2023', '01:01:01', 10),
        TimeTable(10004, 'Maths', '27/01/2023', '01:01:01', 10),
        TimeTable(10006, 'Grammar', '28/01/2023', '01:01:01', 10),
        TimeTable(10007, 'Computer', '28/01/2023', '01:01:01', 10)
      ],
      'Class 2_I Mid Term Test': [
        TimeTable(10001, 'English', '26/02/2023', '01:01:01', 10),
        TimeTable(10002, 'Hindi', '26/02/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/02/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/02/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/02/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/02/2023', '01:01:01', 10)
      ],
      'Class 3_I Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 4_I Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 5_I Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 1_II Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10)
      ],
      'Class 2_II Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10)
      ],
      'Class 3_II Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 4_II Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 5_II Mid Term Test': [
        TimeTable(1001, 'English', '26/08/2023', '01:01:01', 10),
        TimeTable(1002, 'Hindi', '26/08/2023', '01:01:01', 10),
        TimeTable(1003, 'Science', '27/08/2023', '01:01:01', 10),
        TimeTable(1004, 'Maths', '27/08/2023', '01:01:01', 10),
        TimeTable(1005, 'EVS', '27/08/2023', '01:01:01', 10),
        TimeTable(1006, 'Grammar', '28/08/2023', '01:01:01', 10),
        TimeTable(1007, 'Computer', '28/08/2023', '01:01:01', 10),
        TimeTable(1008, 'SSE', '28/08/2023', '01:01:01', 10)
      ],
      'Class 1_Quarterly Exam': [
        TimeTable(5001, 'English', '26/08/2023', '01:01:01', 50),
        TimeTable(5002, 'Hindi', '26/08/2023', '01:01:01', 50),
        TimeTable(5004, 'Maths', '27/08/2023', '01:01:01', 50),
        TimeTable(5006, 'Grammar', '28/08/2023', '01:01:01', 50),
        TimeTable(5007, 'Computer', '28/08/2023', '01:01:01', 50)
      ],
      'Class 2_Quarterly Exam': [
        TimeTable(5001, 'English', '26/08/2023', '01:01:01', 50),
        TimeTable(5002, 'Hindi', '26/08/2023', '01:01:01', 50),
        TimeTable(5004, 'Maths', '27/08/2023', '01:01:01', 50),
        TimeTable(5005, 'EVS', '27/08/2023', '01:01:01', 50),
        TimeTable(5006, 'Grammar', '28/08/2023', '01:01:01', 50),
        TimeTable(5007, 'Computer', '28/08/2023', '01:01:01', 50)
      ],
      'Class 3_Quarterly Exam': [
        TimeTable(5001, 'English', '26/08/2023', '01:01:01', 50),
        TimeTable(5002, 'Hindi', '26/08/2023', '01:01:01', 50),
        TimeTable(5003, 'Science', '27/08/2023', '01:01:01', 50),
        TimeTable(5004, 'Maths', '27/08/2023', '01:01:01', 50),
        TimeTable(5005, 'EVS', '27/08/2023', '01:01:01', 50),
        TimeTable(5006, 'Grammar', '28/08/2023', '01:01:01', 50),
        TimeTable(5007, 'Computer', '28/08/2023', '01:01:01', 50),
        TimeTable(5008, 'SSE', '28/08/2023', '01:01:01', 50)
      ],
      'Class 4_Quarterly Exam': [
        TimeTable(5001, 'English', '26/08/2023', '01:01:01', 50),
        TimeTable(5002, 'Hindi', '26/08/2023', '01:01:01', 50),
        TimeTable(5003, 'Science', '27/08/2023', '01:01:01', 50),
        TimeTable(5004, 'Maths', '27/08/2023', '01:01:01', 50),
        TimeTable(5005, 'EVS', '27/08/2023', '01:01:01', 50),
        TimeTable(5006, 'Grammar', '28/08/2023', '01:01:01', 50),
        TimeTable(5007, 'Computer', '28/08/2023', '01:01:01', 50),
        TimeTable(5008, 'SSE', '28/08/2023', '01:01:01', 50)
      ],
      'Class 5_Quarterly Exam': [
        TimeTable(5001, 'English', '26/08/2023', '01:01:01', 50),
        TimeTable(5002, 'Hindi', '26/08/2023', '01:01:01', 50),
        TimeTable(5003, 'Science', '27/08/2023', '01:01:01', 50),
        TimeTable(5004, 'Maths', '27/08/2023', '01:01:01', 50),
        TimeTable(5005, 'EVS', '27/08/2023', '01:01:01', 50),
        TimeTable(5006, 'Grammar', '28/08/2023', '01:01:01', 50),
        TimeTable(5007, 'Computer', '28/08/2023', '01:01:01', 50),
        TimeTable(5008, 'SSE', '28/08/2023', '01:01:01', 50)
      ],
      'Class 1_Half Yearly Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100)
      ],
      'Class 2_Half Yearly Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100)
      ],
      'Class 3_Half Yearly Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ],
      'Class 4_Half Yearly Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ],
      'Class 5_Half Yearly Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ],
      'Class 1_Final Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100)
      ],
      'Class 2_Final Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100)
      ],
      'Class 3_Final Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ],
      'Class 4_Final Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ],
      'Class 5_Final Exam': [
        TimeTable(10001, 'English', '26/08/2023', '01:01:01', 100),
        TimeTable(10002, 'Hindi', '26/08/2023', '01:01:01', 100),
        TimeTable(10003, 'Science', '27/08/2023', '01:01:01', 100),
        TimeTable(10004, 'Maths', '27/08/2023', '01:01:01', 100),
        TimeTable(10005, 'EVS', '27/08/2023', '01:01:01', 100),
        TimeTable(10006, 'Grammar', '28/08/2023', '01:01:01', 100),
        TimeTable(10007, 'Computer', '28/08/2023', '01:01:01', 100),
        TimeTable(10008, 'SSE', '28/08/2023', '01:01:01', 100)
      ]
    };
  }
}

class TimeTable {
  TimeTable(this.id, this.subject, this.date, this.time, this.maxMarks);

  final int id;
  final String subject;
  final String date;
  final String time;
  final int maxMarks;
}

class TimeTableDataSource extends DataGridSource {
  TimeTableDataSource({required List<TimeTable> timeTableData}) {
    _timeTableData = timeTableData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'subject', value: e.subject),
              DataGridCell<String>(columnName: 'date', value: e.date),
              DataGridCell<String>(columnName: 'time', value: e.time),
              DataGridCell<int>(columnName: 'maxMarks', value: e.maxMarks),
            ]))
        .toList();
  }

  List<DataGridRow> _timeTableData = [];

  @override
  List<DataGridRow> get rows => _timeTableData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString(),
            style: TextStyle(fontSize: 10, color: Colors.black)),
      );
    }).toList());
  }
}
