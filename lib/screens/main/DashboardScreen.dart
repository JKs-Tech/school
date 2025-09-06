// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/controller/user_controller.dart';
import 'package:infixedu/screens/student/examination/StudentExaminationList.dart';
import 'package:infixedu/screens/student/fees/StudentFees.dart';
import 'package:infixedu/screens/student/studentChat/ChatTeacherList.dart';
// import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
// import 'package:themify_flutter/themify_flutter.dart';

// Project imports:
import 'package:infixedu/controller/notification_controller.dart';
import 'package:infixedu/screens/parent/ChildDashboardScreen.dart';
import 'package:infixedu/utils/FunctinsData.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../Home.dart';
import 'package:infixedu/screens/student/homework/StudentHomework.dart';

class DashboardScreen extends StatefulWidget {
  final List<String> titles;
  final List<String> images;
  final String role;
  final String image, token, childName;
  final int childUID;
  final int childId;
  final bool callApi;

  const DashboardScreen({
    super.key,

    required this.titles,
    required this.images,
    required this.role,
    required this.childUID,
    required this.image,
    required this.token,
    required this.childName,
    required this.childId,
    required this.callApi,
  });

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UserController userController = Get.put(UserController());
  final NotificationController controller = Get.put(NotificationController());
  final SystemController _systemController = Get.put(SystemController());

  PersistentTabController persistentTabController = PersistentTabController(
    initialIndex: 0,
  );

  String? _id;

  static Future<bool> _popCamera(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: ScreenUtil().setSp(12),
          color: Colors.red,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget yesButton = TextButton(
      child: Text(
        "Yes",
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: ScreenUtil().setSp(12),
          color: Colors.green,
        ),
      ),
      onPressed: () async {
        SystemNavigator.pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Logout", style: Theme.of(context).textTheme.headlineSmall),
      content: const Text("Would you like to logout?"),
      actions: [cancelButton, yesButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
      barrierDismissible: true,
    );
    return Future.value(false);
  }

  int _studentId = 0;
  Future initiate() async {
    try {
      print("ROLE ID ${widget.role} ${widget.role.runtimeType}");

      await Utils.getStringValue('id').then((value) async {
        setState(() {
          _id = value;
        });
        if (widget.role == "3" || widget.role == "2") {
          if (widget.role == "3") {
            userController.studentId.value = widget.childId;
          } else {
            await Utils.getIntValue('studentId').then((studentIdVal) async {
              setState(() {
                _studentId = studentIdVal;
              });
            });
            userController.studentId.value = _studentId;
          }
          //  await userController.getStudentRecord();
        }
      });
      controller.getNotifications();
    } catch (e) {
      print("${e}error while getting id");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.callApi) {
        initiate();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isStudent()
        ? Obx(() {
          return _systemController.isLoading.value
              ? const Center(child: CupertinoActivityIndicator())
              : PersistentTabView(
                context,
                controller: persistentTabController,
                screens: [
                  widget.role == "3"
                      ? ChildHome(
                        AppFunction.students,
                        AppFunction.studentIcons,
                        widget.childUID,
                        widget.image,
                        widget.token,
                        widget.childName,
                      )
                      : Home(widget.images, widget.role, widget.titles),
                  StudentHomework(isBackIconVisible: false, id: ""),
                  StudentFees(isBackIconVisible: false),
                  StudentExaminationList(isBackIconVisible: false),
                  ChatTeacherList(isBackIconVisible: false),
                ],
                items: [
                  PersistentBottomNavBarItem(
                    icon: Image.asset(
                      'assets/images/ic_home_default.png',
                      width: 18,
                      height: 18,
                    ),
                    title: "Home".tr,
                    activeColorPrimary: Colors.deepPurple.withOpacity(0.9),
                    inactiveColorPrimary: Colors.grey.withOpacity(0.9),
                  ),
                  PersistentBottomNavBarItem(
                    icon: Image.asset(
                      'assets/images/ic_dashboard_homework.png',
                      width: 18,
                      height: 18,
                    ),
                    title: "Homework".tr,
                    activeColorPrimary: Colors.deepPurple.withOpacity(0.9),
                    inactiveColorPrimary: Colors.grey.withOpacity(0.9),
                  ),
                  PersistentBottomNavBarItem(
                    inactiveIcon:
                        widget.role == "4"
                            ? Image.asset(
                              "assets/images/classattendance.png",
                              width: 25.w,
                              height: 25.h,
                              color: Colors.white,
                            )
                            : Image.asset(
                              "assets/images/fees_icon.png",
                              width: 25.w,
                              height: 25.h,
                              color: Colors.white,
                            ),
                    icon:
                        widget.role == "4"
                            ? Image.asset(
                              "assets/images/classattendance.png",
                              width: 25.w,
                              height: 25.h,
                              color: Colors.white,
                            )
                            : Image.asset(
                              "assets/images/fees_icon.png",
                              width: 25.w,
                              height: 25.h,
                              color: Colors.white,
                            ),
                    title: widget.role == "4" ? "Attendance".tr : "Fees".tr,
                    activeColorPrimary: Colors.deepPurple.withOpacity(0.9),
                    inactiveColorPrimary: Colors.grey.withOpacity(0.9),
                  ),
                  PersistentBottomNavBarItem(
                    icon: Image.asset(
                      'assets/images/ic_nav_examination.png',
                      width: 18,
                      height: 18,
                    ),
                    title: "Examination".tr,
                    activeColorPrimary: Colors.deepPurple.withOpacity(0.9),
                    inactiveColorPrimary: Colors.grey.withOpacity(0.9),
                  ),
                  PersistentBottomNavBarItem(
                    icon: Image.asset(
                      'assets/images/ic_chat.png',
                      width: 18,
                      height: 18,
                    ),
                    title: "Chat".tr,
                    activeColorPrimary: Colors.deepPurple.withOpacity(0.9),
                    inactiveColorPrimary: Colors.grey.withOpacity(0.9),
                  ),
                ],

                navBarHeight: 70,
                margin: const EdgeInsets.all(0),

                backgroundColor: Colors.white,
                handleAndroidBackButtonPress: true,
                resizeToAvoidBottomInset: true,
                stateManagement: false,

                onItemSelected: (index) async {
                  if (index == 1) {
                    await controller.getNotifications();
                  }
                },
                decoration: NavBarDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  colorBehindNavBar: Colors.white,
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10.0,
                      offset: Offset(2, 3),
                    ),
                  ],
                ),

                navBarStyle: NavBarStyle.style15,
              );
        })
        : Offstage();
  }
}
