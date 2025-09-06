class StudentItem {
  final String? id;
  final String? name;
  final String? className;
  final String? section;
  final String? image;

  StudentItem({this.id, this.name, this.className, this.section, this.image});

  factory StudentItem.fromJson(Map<String, dynamic> json) {
    return StudentItem(
      id: json['id'],
      name:
          json['firstname'] ??
          ''
                  ' ' +
              json['lastname'] ??
          '', // Combine first and last name if needed
      className: json['class'],
      section: json['section'],
      image: json['image'],
    );
  }
}
