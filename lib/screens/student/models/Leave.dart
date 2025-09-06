class Leave {
  final String? fromDate;
  final String? toDate;
  final String? applyDate;

  Leave({this.fromDate, this.toDate, this.applyDate});

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      fromDate: json['from_date'],
      toDate: json['to_date'],
      applyDate: json['apply_date'],
    );
  }
}
