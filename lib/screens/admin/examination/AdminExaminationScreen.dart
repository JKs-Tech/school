import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'AdminTimeTableScreen.dart';
import 'AdminViewResultScreen.dart';
import 'AdminEnterMarksScreen.dart';

class AdminExaminationScreen extends StatefulWidget {
  const AdminExaminationScreen({super.key});

  @override
  _AdminExaminationScreenState createState() => _AdminExaminationScreenState();
}

class _AdminExaminationScreenState extends State<AdminExaminationScreen> {
  void _handleCardClick(String cardType) {
    if ('time_table' == cardType) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminTimeTableScreen(),
        ),
      );
    } else if ('enter_marks' == cardType) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminEnterMarksScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminViewResultScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Examination'),
      body: Column(
        children: [
          GestureDetector(
              onTap: () => _handleCardClick('time_table'),
              child: CustomCard(
                title: 'TimeTable',
                gradientColors: [Colors.blue, Colors.purple],
                imagePath: 'assets/images/time_table.png',
              )),
          GestureDetector(
              onTap: () => _handleCardClick('enter_marks'),
              child: CustomCard(
                title: 'Enter Marks',
                gradientColors: [Colors.green, Colors.teal],
                imagePath: 'assets/images/enter_marks.jpg',
              )),
          GestureDetector(
              onTap: () => _handleCardClick('view_result'),
              child: CustomCard(
                title: 'View Result',
                gradientColors: [Colors.orange, Colors.deepOrange],
                imagePath: 'assets/images/view_result.png',
              )),
        ],
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final List<Color> gradientColors;
  final String imagePath;

  const CustomCard({super.key, 
    required this.title,
    required this.gradientColors,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath,
                    height: 100.0,
                    width: 100.0,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ))),
    );
  }
}
