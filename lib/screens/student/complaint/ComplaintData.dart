class ComplaintData {
  String? id;
  String? complaintType;
  String? source;
  String? date;
  String? description;
  String? actionTaken;
  String? note;
  String? assigned;
  String? image;

  ComplaintData({
    this.id,
    this.complaintType,
    this.source,
    this.date,
    this.description,
    this.actionTaken,
    this.note,
    this.assigned,
    this.image,
  });

  factory ComplaintData.fromJson(Map<String, dynamic> json) {
    // Implement the factory constructor to parse the JSON data
    // and create the ComplaintData object.
    // For example:
    return ComplaintData(
      id: json['id'],
      complaintType: json['complaint_type'],
      source: json['source'],
      date: json['date'],
      description: json['description'],
      actionTaken: json['action_taken'],
      note: json['note'],
      assigned: json['assigned'],
      image: json['image'],
    );
  }
}
