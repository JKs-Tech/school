class Session {
  final String subject;
  final String time;
  final String roomNo;

  Session({required this.subject, required this.time, required this.roomNo});

  factory Session.fromJSON(dynamic session) {
    final subject =
        session['code'].isEmpty
            ? session['subject_name']
            : '${session['subject_name']} (${session['code']})';
    final time =
        session['time_from'].isEmpty
            ? 'Not Scheduled'
            : '${session['time_from']} - ${session['time_to']}';
    final roomNo = session['room_no'];

    return Session(subject: subject, time: time, roomNo: roomNo);
  }
}
