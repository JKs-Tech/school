// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/utils/FunctinsData.dart';

class AdminAttendanceHomeScreen extends StatefulWidget {
  final _titles;
  final _images;

  const AdminAttendanceHomeScreen(this._titles, this._images, {super.key});

  @override
  _HomeState createState() => _HomeState(_titles, _images);
}

class _HomeState extends State<AdminAttendanceHomeScreen> {
  late bool isTapped;
  late int currentSelectedIndex;
  final _titles;
  final _images;

  _HomeState(this._titles, this._images) {
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
      appBar: CustomAppBarWidget(
        title: 'Attendance',
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          itemCount: _titles.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return CustomWidget(
              index: index,
              isSelected: currentSelectedIndex == index,
              onSelect: () {
                setState(() {
                  currentSelectedIndex = index;
                  AppFunction.getAdminAttendanceDashboardPage(
                      context, _titles[index]);
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
