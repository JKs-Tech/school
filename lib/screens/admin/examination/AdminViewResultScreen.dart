import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

class AdminViewResultScreen extends StatefulWidget {
  const AdminViewResultScreen({super.key});

  @override
  _AdminViewResultScreenState createState() => _AdminViewResultScreenState();
}

class _AdminViewResultScreenState extends State<AdminViewResultScreen> {
  List<ResultData> resultList = <ResultData>[];
  ResultDataSource? resultDataSource;
  String? selectedClass;
  String? selectedExam;
  bool isLoading = false;
  Map<String, List<ResultData>> classMappingData = {};
  List<String>? subjects;

  @override
  void initState() {
    super.initState();
    initResultData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      resultList = getResultData();
      print(
          'class resultList = $resultList selectedClass = $selectedClass selectedExam = $selectedExam');
      resultDataSource =
          ResultDataSource(resultData: resultList, subjects: subjects ?? []);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScreenAppBarWidget(title: 'Student Result'),
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
                            'I Mid term',
                            'II Mid term',
                            'HalfYearly',
                            'Final exam'
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
            Divider(
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Expanded(
                child: isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : resultDataSource == null
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
                            source: resultDataSource ??
                                ResultDataSource(
                                    resultData: resultList,
                                    subjects: subjects ?? []),
                            frozenColumnsCount: 1,
                            columnWidthMode: ColumnWidthMode.auto,
                            columns: <GridColumn>[
                              GridColumn(
                                  columnName: 'studentName',
                                  label: Container(
                                      padding: EdgeInsets.all(16.0),
                                      alignment: Alignment.center,
                                      child: Text('Student',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              ...getSubjectGridColumn(),
                              GridColumn(
                                  columnName: 'grandTotal',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Grand\nTotal',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'percentage',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Percent(%)',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'result',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Result',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                            ],
                          ))
          ],
        ));
  }

  List<ResultData> getResultData() {
    return classMappingData["${selectedClass!}_${selectedExam!}"] ?? [];
  }

  Future<void> initResultData() async {
    List<String> classList = [
      'Class 1',
      'Class 2',
      'Class 3',
      'Class 4',
      'Class 5'
    ];
    subjects = ['Hindi', 'English', 'Maths'];
    final List<String> exams = [
      'I Mid term',
      'II Mid term',
      'HalfYearly',
      'Final exam'
    ];
    final Random random = Random();

    for (String className in classList) {
      for (String exam in exams) {
        List<ResultData> classExamResults = [];

        for (int id = 1; id <= 10; id++) {
          Map<String, double> subjectMarks = {};
          double totalMarks = 0;

          for (String subject in subjects ?? []) {
            double subjectTotal = 0;

            double maxMarks = 100;
            if (exam == 'I Mid term' || exam == 'II Mid term') {
              maxMarks = 10;
            } else if (exam == 'HalfYearly') {
              maxMarks = 50;
            }

            double marks = random.nextDouble() * maxMarks;
            subjectTotal += marks;

            subjectMarks[subject] = double.parse(marks.toStringAsFixed(1));

            totalMarks += subjectTotal;
          }

          double percentage =
              (totalMarks / ((subjects?.length ?? 0) * exams.length * 100)) *
                  100;
          String result = percentage >= 40 ? 'Pass' : 'Fail';

          ResultData resultData = ResultData(
            id,
            'Student $id',
            subjectMarks,
            double.parse(totalMarks.toStringAsFixed(1)),
            double.parse(percentage.toStringAsFixed(1)),
            result,
          );
          classExamResults.add(resultData);
        }
        classMappingData['${className}_$exam'] = classExamResults;
      }
    }
  }

  List<GridColumn> getSubjectGridColumn() {
    final List<GridColumn> dayColumns = [];
    for (int i = 0; i < subjects!.length; i++) {
      dayColumns.add(
        GridColumn(
          columnName: subjects?[i] ?? '',
          label: Container(
            padding: EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Text(
              subjects?[i] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return dayColumns;
  }
}

class ResultData {
  ResultData(this.id, this.studentName, this.subjectWiseMarks, this.total,
      this.percentage, this.result);

  final int id;
  final String studentName;
  final Map<String, double> subjectWiseMarks;
  final double total;
  final double percentage;
  final String result;
}

class ResultDataSource extends DataGridSource {
  ResultDataSource(
      {required List<ResultData> resultData, required List<String> subjects}) {
    _resultData = resultData.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'studentName', value: e.studentName),
        for (String subjectName in subjects)
          DataGridCell<double>(
              columnName: subjectName, value: e.subjectWiseMarks[subjectName]),
        DataGridCell<double>(columnName: 'grandTotal', value: e.total),
        DataGridCell<double>(columnName: 'percentage', value: e.percentage),
        DataGridCell<String>(columnName: 'result', value: e.result),
      ]);
    }).toList();
  }

  List<DataGridRow> _resultData = [];

  @override
  List<DataGridRow> get rows => _resultData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        TextStyle getTextStyle() {
          if (dataGridCell.columnName == 'studentName') {
            return TextStyle(
                color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold);
          }
          return TextStyle(color: Colors.black, fontSize: 12);
        }

        Widget cellContent;
        if (dataGridCell.columnName == 'result') {
          String cellValue = dataGridCell.value.toString();
          Color backgroundColor =
              cellValue == 'Pass' ? Colors.green : Colors.red;

          cellContent = Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            color: backgroundColor,
            child: Text(cellValue,
                style: TextStyle(color: Colors.white, fontSize: 12)),
          );
        } else {
          cellContent = Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(dataGridCell.value.toString(), style: getTextStyle()),
          );
        }
        return cellContent;
      }).toList(),
    );
  }
}
