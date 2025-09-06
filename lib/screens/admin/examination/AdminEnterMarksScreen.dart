import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

class AdminEnterMarksScreen extends StatefulWidget {
  const AdminEnterMarksScreen({super.key});

  @override
  _AdminEnterMarksScreenState createState() => _AdminEnterMarksScreenState();
}

class _AdminEnterMarksScreenState extends State<AdminEnterMarksScreen> {
  List<StudentData> studentData = <StudentData>[];
  StudentDataSource? studentDataSource;
  String? selectedClass, selectedExam, selectSubject;
  bool isLoading = false;
  Map<String, List<StudentData>> classMappingData = {};
  DataGridController? _dataGridController;
  List<TextEditingController> editingControllers = [];

  @override
  void initState() {
    super.initState();
    initStudentData();
  }

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      studentData = getStudentData();
      print(
          'class resultList = $studentData selectedClass = $selectedClass selectedExam = $selectedExam');
      studentDataSource = StudentDataSource(
          studentData: studentData, editingControllers: editingControllers);
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
                            if (selectedClass != newValue) {
                              selectedExam = null;
                              selectSubject = null;
                              setState(() {
                                selectedClass = newValue;
                              });
                            }
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
                  if (selectedClass != null) SizedBox(height: 16),
                  if (selectedClass != null)
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<String>(
                            value: selectedExam,
                            onChanged: (newValue) {
                              if (selectedExam != newValue) {
                                selectedExam = newValue;
                                selectSubject = null;
                                setState(() {
                                  selectedExam = newValue;
                                });
                              }
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
                  if (selectedExam != null) SizedBox(height: 16),
                  if (selectedExam != null)
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButtonFormField<String>(
                            value: selectSubject,
                            onChanged: (newValue) {
                              if (selectedClass != null &&
                                  selectedExam != null &&
                                  selectSubject != newValue) {
                                selectSubject = newValue;
                                getData();
                              }
                              setState(() {
                                selectSubject = newValue;
                              });
                            },
                            items: ['Hindi', 'English', 'Maths']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            decoration:
                                InputDecoration(hintText: 'Select Subject'))),
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
                    : studentDataSource == null
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
                            source: studentDataSource ??
                                StudentDataSource(
                                    studentData: studentData,
                                    editingControllers: editingControllers),
                            frozenColumnsCount: 1,
                            columnWidthMode: ColumnWidthMode.auto,
                            allowEditing: true,
                            allowSorting: true,
                            allowMultiColumnSorting: true,
                            allowTriStateSorting: true,
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            editingGestureType: EditingGestureType.tap,
                            controller: _dataGridController,
                            columns: <GridColumn>[
                              GridColumn(
                                  columnName: 'rollNumber',
                                  allowEditing: false,
                                  width: 40,
                                  label: Container(
                                      padding: EdgeInsets.all(16.0),
                                      alignment: Alignment.center,
                                      child: Text('R.No',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'studentName',
                                  allowEditing: false,
                                  label: Container(
                                      padding: EdgeInsets.all(16.0),
                                      alignment: Alignment.center,
                                      child: Text('Student',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'attendance',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('Attendance',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'thMarks',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('TH.Marks',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'oMarks',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('O.Marks',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                              GridColumn(
                                  columnName: 'pMarks',
                                  label: Container(
                                      padding: EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      child: Text('P.Marks',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)))),
                            ],
                          ))
          ],
        ));
  }

  List<StudentData> getStudentData() {
    return classMappingData[
            '${selectedClass}_${selectedExam}_$selectSubject'] ??
        [];
  }

  Future<void> initStudentData() async {
    _dataGridController = DataGridController();
    List<String> classList = [
      'Class 1',
      'Class 2',
      'Class 3',
      'Class 4',
      'Class 5'
    ];
    List<String> subjects = ['Hindi', 'English', 'Maths'];
    List<String> exams = [
      'I Mid term',
      'II Mid term',
      'HalfYearly',
      'Final exam'
    ];
    List<String> attendanceOptions = ['Absent', 'Present'];

    final Random random = Random();
    for (String className in classList) {
      for (String exam in exams) {
        for (String subject in subjects) {
          List<StudentData> data = [];
          for (int rollNumber = 1; rollNumber <= 10; rollNumber++) {
            String thMarks = (random.nextDouble() * 100).toStringAsFixed(1);
            String oMarks = (random.nextDouble() * 10).toStringAsFixed(1);
            String pMarks = (random.nextDouble() * 50).toStringAsFixed(1);
            String studentName = 'Student $rollNumber';
            String randomAttendance = attendanceOptions[Random().nextInt(2)];
            editingControllers.add(TextEditingController(text: thMarks));
            editingControllers.add(TextEditingController(text: oMarks));
            editingControllers.add(TextEditingController(text: pMarks));
            editingControllers
                .add(TextEditingController(text: randomAttendance));
            data.add(StudentData(
              rollNumber,
              studentName,
              randomAttendance,
              thMarks,
              oMarks,
              pMarks,
            ));
          }
          classMappingData['${className}_${exam}_$subject'] = data;
        }
      }
    }
  }
}

class StudentData {
  StudentData(this.rollNumber, this.studentName, this.attendance, this.thMarks,
      this.oMarks, this.pMarks);

  final int rollNumber;
  final String studentName;
  String attendance;
  String thMarks;
  String oMarks;
  String pMarks;
}

class StudentDataSource extends DataGridSource {
  StudentDataSource(
      {required List<StudentData> studentData,
      required List<TextEditingController> editingControllers}) {
    _studentData = studentData.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'rollNumber', value: e.rollNumber),
        DataGridCell<String>(columnName: 'studentName', value: e.studentName),
        DataGridCell<String>(columnName: 'attendance', value: e.attendance),
        DataGridCell<String>(columnName: 'thMarks', value: e.thMarks),
        DataGridCell<String>(columnName: 'oMarks', value: e.oMarks),
        DataGridCell<String>(columnName: 'pMarks', value: e.pMarks),
      ]);
    }).toList();

    dynamic newCellValue;

    @override
    void onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex,
        GridColumn column) {
      final dynamic oldValue = dataGridRow
              .getCells()
              .firstWhereOrNull((DataGridCell dataGridCell) =>
                  dataGridCell.columnName == column.columnName)
              ?.value ??
          '';
      final int dataRowIndex = rows.indexOf(dataGridRow);
      if (newCellValue == null || oldValue == newCellValue) {
        return;
      }
      if (column.columnName == 'attendance') {
        rows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'attendance', value: newCellValue);
        studentData[dataRowIndex].attendance = newCellValue.toString();
      } else if (column.columnName == 'thMarks') {
        rows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'thMarks', value: newCellValue);
        studentData[dataRowIndex].thMarks = newCellValue.toString();
      } else if (column.columnName == 'oMarks') {
        rows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'oMarks', value: newCellValue);
        studentData[dataRowIndex].oMarks = newCellValue.toString();
      } else if (column.columnName == 'pMarks') {
        rows[dataRowIndex].getCells()[rowColumnIndex.columnIndex] =
            DataGridCell<String>(columnName: 'pMarks', value: newCellValue);
        studentData[dataRowIndex].pMarks = newCellValue.toString();
      }
    }

    RegExp getRegExp(bool isNumericKeyBoard, String columnName) {
      return isNumericKeyBoard ? RegExp('[0-9]') : RegExp('[a-zA-Z ]');
    }

    @override
    Widget buildEditWidget(
        DataGridRow dataGridRow,
        RowColumnIndex rowColumnIndex,
        GridColumn column,
        CellSubmit submitCell) {
      final int dataRowIndex = rows.indexOf(dataGridRow);
      final TextEditingController controller = editingControllers[dataRowIndex];

      // Text going to display on editable widget
      final String displayText = dataGridRow
              .getCells()
              .firstWhereOrNull((DataGridCell dataGridCell) =>
                  dataGridCell.columnName == column.columnName)
              ?.value
              ?.toString() ??
          '';

      newCellValue = null;

      final bool isNumericType = column.columnName == 'rollNumber';

      // Holds regular expression pattern based on the column type.
      final RegExp regExp = getRegExp(isNumericType, column.columnName);

      return Container(
        padding: const EdgeInsets.all(8.0),
        alignment: isNumericType ? Alignment.centerRight : Alignment.centerLeft,
        child: TextField(
          autofocus: true,
          controller: controller..text = displayText,
          textAlign: isNumericType ? TextAlign.right : TextAlign.left,
          autocorrect: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
          ),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(regExp)
          ],
          keyboardType:
              isNumericType ? TextInputType.number : TextInputType.text,
          onChanged: (String value) {
            if (value.isNotEmpty) {
              if (isNumericType) {
                newCellValue = int.parse(value);
              } else {
                newCellValue = value;
              }
              controller.text = value; // Update controller value
            } else {
              newCellValue = null;
            }
          },
          onSubmitted: (String value) {
            newCellValue = value;
            submitCell();
          },
        ),
      );
    }
  }

  List<DataGridRow> _studentData = [];

  @override
  List<DataGridRow> get rows => _studentData;

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
