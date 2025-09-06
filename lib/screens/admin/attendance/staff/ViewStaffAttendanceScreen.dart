import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:flutter/cupertino.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ViewStaffAttendanceScreen extends StatefulWidget {
  const ViewStaffAttendanceScreen({super.key});

  @override
  _ViewStaffAttendanceScreenState createState() =>
      _ViewStaffAttendanceScreenState();
}

class _ViewStaffAttendanceScreenState extends State<ViewStaffAttendanceScreen> {
  List<Staff> staff = <Staff>[];
  late StaffDataSource staffDataSource;
  List<String> daysNames = [];
  String? selectedMonth; // Default selected month
  int? selectedYear;
  bool isLoading = true;
  List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    selectedYear = DateTime.now().year;
    selectedMonth = DateFormat('MMMM').format(DateTime.now());
    getAttendanceData();
  }

  Future<void> getAttendanceData() async {
    setState(() {
      isLoading = true;
    });
    try {
      staff = await getStaffData();
      staffDataSource = StaffDataSource(staffData: staff, daysName: daysNames);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Staff Attendance'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      value: selectedMonth,
                      onChanged: (newValue) {
                        setState(() {
                          selectedMonth = newValue;
                        });
                      },
                      items: monthNames
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )),
                SizedBox(width: 16.0),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (newValue) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      },
                      items: List<int>.generate(
                              10, (index) => DateTime.now().year - index)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(value.toString()),
                        );
                      }).toList(),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          ElevatedButton(
              onPressed: () {
                getAttendanceData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Fetch Staff Attendances')),
          SizedBox(
            height: 16,
          ),
          Expanded(
              child: isLoading
                  ? Center(child: CupertinoActivityIndicator())
                  : SfDataGrid(
                      source: staffDataSource,
                      frozenColumnsCount: 1,
                      columnWidthMode: ColumnWidthMode.auto,
                      columns: <GridColumn>[
                        GridColumn(
                            columnName: 'name',
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'percentage',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'present',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('P',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'absent',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('A',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'late',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('L',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'halfDay',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('F',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        GridColumn(
                            columnName: 'holiday',
                            width: 40,
                            label: Container(
                                padding: EdgeInsets.all(4.0),
                                alignment: Alignment.center,
                                child: Text('H',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)))),
                        ...getDayGridColumn()
                      ],
                    ))
        ],
      ),
    );
  }

  List<String> getDayNames(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final dayNames = <String>[];
    for (var day = firstDay;
        day.isBefore(lastDay.add(Duration(days: 1)));
        day = day.add(Duration(days: 1))) {
      final dayName = '${day.day}\n${_getDayName(day.weekday)}';
      dayNames.add(dayName);
    }

    return dayNames;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  List<GridColumn> getDayGridColumn() {
    final List<GridColumn> dayColumns = [];
    for (int i = 0; i < daysNames.length; i++) {
      dayColumns.add(
        GridColumn(
          width: 60,
          columnName: daysNames[i],
          label: Container(
            padding: EdgeInsets.all(4.0),
            alignment: Alignment.center,
            child: Text(
              daysNames[i],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return dayColumns;
  }

  Future<List<Staff>> getStaffData() async {
    daysNames =
        getDayNames(selectedYear!, monthNames.indexOf(selectedMonth!) + 1);
    print('daysNames = $daysNames');
    print('daysNames length = ${daysNames.length}');
    final List<String> letters = ['P', 'A', 'L', 'F', 'H'];
    final random = Random();
    return List.generate(
      20,
      (index) {
        final list = List.generate(daysNames.length,
            (index) => letters[random.nextInt(letters.length)]);
        print('list = ${list.toString()}');
        final groupedLetters = countLetters(list);
        return Staff(
            'Staff ${index + 1}',
            list,
            groupedLetters['P'] ?? 0,
            groupedLetters['A'] ?? 0,
            groupedLetters['L'] ?? 0,
            groupedLetters['F'] ?? 0,
            groupedLetters['H'] ?? 0);
      },
    );
  }
}

Map<String, int> countLetters(List<String> letterList) {
  final groupedLetters = groupBy(letterList, (letter) => letter);
  return Map.fromEntries(groupedLetters.entries
      .map((entry) => MapEntry(entry.key, entry.value.length)));
}

class Staff {
  final String name;
  final List<String> attendance;
  final int totalPresent;
  final int totalAbsent;
  final int totalLate;
  final int totalHalfDay;
  final int totalHoliday;

  Staff(this.name, this.attendance, this.totalPresent, this.totalAbsent,
      this.totalLate, this.totalHalfDay, this.totalHoliday);
}

class StaffDataSource extends DataGridSource {
  StaffDataSource({List<Staff>? staffData, List<String>? daysName}) {
    _staffData = staffData!.map<DataGridRow>((e) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'name', value: e.name),
        DataGridCell<int>(
            columnName: 'percentage',
            value: (e.totalPresent * 100) ~/ (e.totalPresent + e.totalAbsent)),
        DataGridCell<int>(columnName: 'present', value: e.totalPresent),
        DataGridCell<int>(columnName: 'absent', value: e.totalAbsent),
        DataGridCell<int>(columnName: 'late', value: e.totalLate),
        DataGridCell<int>(columnName: 'halfDay', value: e.totalHalfDay),
        DataGridCell<int>(columnName: 'holiday', value: e.totalHoliday),
        for (int i = 0; i < daysName!.length; i++)
          DataGridCell<String>(
              columnName: daysName[i], value: e.attendance[i]),
      ]);
    }).toList();
  }

  List<DataGridRow> _staffData = [];

  @override
  List<DataGridRow> get rows => _staffData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      TextStyle? getTextStyle() {
        if (dataGridCell.columnName == 'percentage') {
          if (dataGridCell.value > 75) {
            return TextStyle(color: Colors.green);
          } else {
            return TextStyle(color: Colors.red);
          }
        } else if (dataGridCell.columnName == 'name') {
          return TextStyle(color: Colors.blue);
        }
        return null;
      }

      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(4.0),
        child: Text(dataGridCell.value.toString(), style: getTextStyle()),
      );
    }).toList());
  }
}
