// Flutter imports:
import 'package:flutter/material.dart';
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/FunctinsData.dart';

// Project imports:

// ignore: must_be_immutable
class StudentAttenHome extends StatefulWidget {
  final _titles;
  final _images;
  var id;
  var token;

  StudentAttenHome(this._titles, this._images, {super.key, this.id, this.token});

  @override
  _StudentAttenHomeState createState() =>
      _StudentAttenHomeState(_titles, _images, sId: id, token: token);
}

class _StudentAttenHomeState extends State<StudentAttenHome> {
  late bool isTapped;
  late int currentSelectedIndex;
  final _titles;
  final _images;
  var sId;
  var token;

  _StudentAttenHomeState(this._titles, this._images, {this.sId, this.token}) {
    isTapped = false;
    currentSelectedIndex = 0;
  }

  @override
  void initState() {
    super.initState();
    isTapped = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Attendance'),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          itemCount: _titles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (context, index) {
            return CustomWidget(
              index: index,
              isSelected: currentSelectedIndex == index,
              onSelect: () {
                setState(() {
                  currentSelectedIndex = index;
                  AppFunction.getStudentAttendanceDashboardPage(
                    context,
                    _titles[index],
                    id: sId,
                    token: token,
                  );
                });
              },
              headline: _titles[index],
              icon: _images[index],
            );
          },
        ),
      ),
    );
  }
}
