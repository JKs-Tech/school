import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';

class ViewStudentAttendanceScreen extends StatefulWidget {
  const ViewStudentAttendanceScreen({super.key});

  @override
  _ViewStudentAttendanceScreenState createState() =>
      _ViewStudentAttendanceScreenState();
}

class _ViewStudentAttendanceScreenState
    extends State<ViewStudentAttendanceScreen> {
  late Class selectedClass;
  late Section selectedSection;
  DateTime selectedDate = DateTime.now();
  List<StudentAttendance> studentAttendances = [];
  List<Class> availableClasses = []; // Populate this list
  List<Section> availableSections = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    try {
      await fetchAvailableClasses();
      await fetchAvailableSections(selectedClass);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomScreenAppBarWidget(title: 'Class Attendance'),
        body: SafeArea(
            child: isLoading
                ? Center(child: CupertinoActivityIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Class',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButton<Class>(
                            value: selectedClass,
                            onChanged: (newValue) {
                              selectClass(newValue!);
                              fetchAvailableSections(newValue);
                            },
                            items: availableClasses.map((classItem) {
                              return DropdownMenuItem<Class>(
                                value: classItem,
                                child: Text(classItem.name),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Section',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: DropdownButton<Section>(
                            value: selectedSection,
                            onChanged: (newValue) {
                              selectSection(newValue!);
                            },
                            items: availableSections.map((section) {
                              return DropdownMenuItem<Section>(
                                value: section,
                                child: Text(section.name),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Attendance date',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: DatePickerWidget(
                              selectedDate: selectedDate,
                              onDateChanged: (newDate) {
                                selectDate(newDate);
                              },
                            )),
                        ElevatedButton(
                          onPressed: () {
                            print('selectedClass = $selectedClass');
                            print('selectedSection = $selectedSection');
                            fetchStudentAttendances(
                                selectedClass, selectedSection);
                            print('studentAttendances = $studentAttendances');
                                                    },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blue, // Set button background color here
                            foregroundColor:
                                Colors.white, // Set text color here
                          ),
                          child: Text('Fetch Class Attendances'),
                        ),
                        Expanded(child: StudentListView(studentAttendances))
                      ],
                    ))));
  }

  Future<void> fetchAvailableClasses() async {
    List<Class> fetchedClasses =
        await ApiService.fetchClasses(); // Replace with your API call
    availableClasses = fetchedClasses;
    selectedClass = availableClasses.first;
  }

  Future<void> fetchAvailableSections(Class selectedClass) async {
    List<Section> fetchedSections = await ApiService.fetchSectionsForClass(
        selectedClass); // Replace with your API call
    setState(() {
      availableSections = fetchedSections;
      selectedSection = availableSections.first;
    });
  }

  Future<void> fetchStudentAttendances(
      Class selectedClass, Section selectedSection) async {
    List<StudentAttendance> fetchedAttendances =
        await ApiService.fetchStudentAttendanceForClassAndSection(
            selectedClass, selectedSection);
    setState(() {
      studentAttendances = fetchedAttendances;
    });
  }

  void selectClass(Class newClass) {
    setState(() {
      if (selectedClass.name != newClass.name) {
        studentAttendances.clear();
      }
      selectedClass = newClass;
    });
  }

  void selectSection(Section newSection) {
    setState(() {
      if (selectedSection.name != newSection.name) {
        studentAttendances.clear();
      }
      selectedSection = newSection;
    });
  }

  void selectDate(DateTime newDate) {
    setState(() {
      if (selectedDate != newDate) {
        studentAttendances.clear();
      }
      selectedDate = newDate;
    });
  }

  List<StudentAttendance> getStudentAttendances() {
    return studentAttendances;
  }
}

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DatePickerWidget({super.key, required this.selectedDate, required this.onDateChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(DateFormat('MM-dd-yyyy').format(selectedDate)),
      trailing: Icon(
        Icons.calendar_today,
        size: 15.0,
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.blue, // header background color
                  onPrimary: Colors.white, // header text color
                  onSurface: Colors.blue, // body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red, // button text color
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          onDateChanged(pickedDate);
        }
      },
    );
  }
}

class StudentListView extends StatelessWidget {
  final List<StudentAttendance> studentAttendances;
  const StudentListView(this.studentAttendances, {super.key});

  @override
  Widget build(BuildContext context) {
    print('studentAttendances = $studentAttendances');
    return ListView.builder(
      itemCount: studentAttendances.length,
      itemBuilder: (context, index) {
        return StudentAttendanceCard(
          studentAttendance: studentAttendances[index],
        );
      },
    );
  }
}

class StudentAttendanceCard extends StatelessWidget {
  final StudentAttendance studentAttendance;

  const StudentAttendanceCard({super.key, required this.studentAttendance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        title: Text('Name: ${studentAttendance.name}',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text('StudentId : ${studentAttendance.id}',
            style: TextStyle(color: Colors.black54)),
        trailing: Text(
          studentAttendance.status.name,
          style: TextStyle(
              color: getStatusColor(studentAttendance.status), fontSize: 12),
        ),
      ),
    );
  }
}

class Class {
  final String id;
  final String name;

  Class({required this.id, required this.name});
}

class Section {
  final String id;
  final String name;

  Section({required this.id, required this.name});
}

class StudentAttendance {
  final int id;
  final String name;
  final AttendanceStatus status;

  StudentAttendance(
      {required this.id, required this.name, required this.status});
}

enum AttendanceStatus {
  present,
  absent,
  late,
  leave,
}

Color getStatusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Colors.green;
    case AttendanceStatus.absent:
      return Colors.red;
    case AttendanceStatus.late:
      return Colors.orange;
    case AttendanceStatus.leave:
      return Colors.yellow;
    default:
      return Colors.grey; // Default color for unknown status
  }
}

class ApiService {
  static Future<List<Class>> fetchClasses() async {
    return [
      Class(id: 'class1', name: 'Class 6th A'),
      Class(id: 'class2', name: 'Class 6th B'),
      Class(id: 'class3', name: 'Class 7th A'),
      Class(id: 'class4', name: 'Class 7th B'),
      Class(id: 'class5', name: 'Class 8th A'),
      Class(id: 'class6', name: 'Class 8th B'),
      // Add more classes here
    ];
  }

  static Future<List<Section>> fetchSectionsForClass(
      Class selectedClass) async {
    // Simulate fetching sections based on the selected class from an API
    await Future.delayed(Duration(seconds: 1)); // Simulate API delay

    return [
      Section(id: 'section1', name: 'Section A'),
      Section(id: 'section2', name: 'Section B'),
      // Add more sections here based on selectedClass
    ];
  }

  static Future<List<StudentAttendance>>
      fetchStudentAttendanceForClassAndSection(
          Class selectedClass, Section selectedSection) async {
    // Simulate fetching student attendance data based on class and section
    await Future.delayed(Duration(seconds: 1)); // Simulate API delay

    return [
      StudentAttendance(
          id: 1, name: 'Student 1', status: AttendanceStatus.present),
      StudentAttendance(
          id: 2, name: 'Student 2', status: AttendanceStatus.absent),
      StudentAttendance(
          id: 3, name: 'Student 3', status: AttendanceStatus.leave),
      StudentAttendance(
          id: 4, name: 'Student 4', status: AttendanceStatus.late),
      StudentAttendance(
          id: 5, name: 'Student 5', status: AttendanceStatus.present),
      StudentAttendance(
          id: 6, name: 'Student 6', status: AttendanceStatus.present),
      StudentAttendance(
          id: 7, name: 'Student 7', status: AttendanceStatus.present),
      StudentAttendance(
          id: 8, name: 'Student 8', status: AttendanceStatus.absent),
      StudentAttendance(
          id: 9, name: 'Student 9', status: AttendanceStatus.present),
      StudentAttendance(
          id: 10, name: 'Student 10', status: AttendanceStatus.absent)
    ];
  }
}
