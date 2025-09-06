import 'package:infixedu/screens/student/timetable/Session.dart';

class DayData {
  final String name;
  final List<Session> sessions;

  DayData({required this.name, required this.sessions});

  factory DayData.fromJSON(String name, List<dynamic> data) {
    final sessions = data.map((session) => Session.fromJSON(session)).toList();
    return DayData(name: name, sessions: sessions);
  }
}
