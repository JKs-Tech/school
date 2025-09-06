// Flutter imports:
// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infixedu/controller/system_controller.dart';

// Project imports:
import 'package:infixedu/screens/AboutScreen.dart';
import 'package:infixedu/screens/Home.dart';
import 'package:infixedu/screens/SettingsScreen.dart';
import 'package:infixedu/screens/admin/AdminAttendanceScreen.dart';
import 'package:infixedu/screens/admin/dormitoryAndRoom/AdminAddDormitory.dart';
import 'package:infixedu/screens/admin/dormitoryAndRoom/AdminAddRoom.dart';
import 'package:infixedu/screens/admin/dormitoryAndRoom/AdminDormitoryScreen.dart';
import 'package:infixedu/screens/admin/leave/AdminLeaveHomeScreen.dart';
import 'package:infixedu/screens/admin/library/AddLibraryBook.dart';
import 'package:infixedu/screens/admin/library/AdminAddMember.dart';
import 'package:infixedu/screens/admin/library/AdminLibraryScreen.dart';
import 'package:infixedu/screens/admin/notice/StaffNoticeScreen.dart';
import 'package:infixedu/screens/admin/staff/AdminStaffList.dart';
import 'package:infixedu/screens/admin/transport/AddRouteScreen.dart';
import 'package:infixedu/screens/admin/transport/AdminAddVehicle.dart';
import 'package:infixedu/screens/admin/transport/AdminTransportScreen.dart';
import 'package:infixedu/screens/admin/transport/AssignVehicle.dart';
import 'package:infixedu/screens/applyLeave/ApplyLeave.dart';
import 'package:infixedu/screens/fees/fees_admin/AddFeeType.dart';
import 'package:infixedu/screens/fees/fees_admin/AdminFeeList.dart';
import 'package:infixedu/screens/fees/fees_admin/AdminFeesHome.dart';
import 'package:infixedu/screens/fees/fees_admin/fees_admin_new/bank_payment.dart';
import 'package:infixedu/screens/fees/fees_admin/fees_admin_new/fee_group.dart';
import 'package:infixedu/screens/fees/fees_admin/fees_admin_new/fee_invoice.dart';
import 'package:infixedu/screens/fees/fees_admin/fees_admin_new/fee_type.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/fees_balance_report.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/fees_dues_report.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/fees_fine_report.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/fees_payment_report.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/fees_waiver_report.dart';
import 'package:infixedu/screens/fees/fees_admin/reports/report_main.dart';
import 'package:infixedu/screens/lessonPlan/student/views/StudentLessonsView.dart';
import 'package:infixedu/screens/main/DashboardScreen.dart';
import 'package:infixedu/screens/parent/ChildListScreen.dart';
import 'package:infixedu/screens/student/Dormitory.dart';
import 'package:infixedu/screens/student/Profile.dart';
import 'package:infixedu/screens/student/Routine.dart';
import 'package:infixedu/screens/student/SubjectScreen.dart';
import 'package:infixedu/screens/student/TimeLineScreen.dart';
import 'package:infixedu/screens/student/TransportScreen.dart';
import 'package:infixedu/screens/student/aboutSchool/AboutSchool.dart';
import 'package:infixedu/screens/student/achievement/AchievementScreen.dart';
import 'package:infixedu/screens/student/attendance/StudentSubjectListScreen.dart';
import 'package:infixedu/screens/student/attendance/new/StudentAttendanceScreen.dart';
import 'package:infixedu/screens/student/complaint/StudentComplaint.dart';
import 'package:infixedu/screens/student/documents/StudentDocumentsScreen.dart';
import 'package:infixedu/screens/student/downloadDocs/syllabus/SyllabusScreen.dart';
import 'package:infixedu/screens/student/examination/ClassExamResult.dart';
import 'package:infixedu/screens/student/examination/ScheduleScreen.dart';
import 'package:infixedu/screens/student/examination/StudentExaminationList.dart';
import 'package:infixedu/screens/student/fees/StudentFees.dart';
import 'package:infixedu/screens/student/gallery/GalleryActivity.dart';
import 'package:infixedu/screens/student/homework/StudentHomework.dart';
import 'package:infixedu/screens/student/hostel/StudentHostel.dart';
import 'package:infixedu/screens/student/leave/LeaveListStudent.dart';
import 'package:infixedu/screens/student/leave/LeaveStudentApply.dart';
import 'package:infixedu/screens/student/library/BookIssuedScreen.dart';
import 'package:infixedu/screens/student/library/BookListScreen.dart';
import 'package:infixedu/screens/student/library/LibraryScreen.dart';
import 'package:infixedu/screens/student/library/StudentLibraryScreen.dart';
import 'package:infixedu/screens/student/liveClasses/StudentLiveClasses.dart';
import 'package:infixedu/screens/student/notice/NoticeBoardScreen.dart';
import 'package:infixedu/screens/student/notice/NoticeScreen.dart';
import 'package:infixedu/screens/student/notification/NotificationScreen.dart';
import 'package:infixedu/screens/student/onlineExam/ActiveOnlineExamScreen.dart';
import 'package:infixedu/screens/student/onlineExam/OnlineExamResultScreen.dart';
import 'package:infixedu/screens/student/onlineExam/OnlineExamScreen.dart';
import 'package:infixedu/screens/student/onlineExam/StudentOnlineExamList.dart';
import 'package:infixedu/screens/student/onlineExam/module/view/ActiveOnlineExamsModule.dart';
import 'package:infixedu/screens/student/onlineExam/module/view/OnlineExamResultsModule.dart';
import 'package:infixedu/screens/student/profile/StudentProfileDetailsScreen.dart';
import 'package:infixedu/screens/student/settings/TransportSettings.dart';
import 'package:infixedu/screens/student/studentSyllabus/StudentSyllabusStatus.dart';
import 'package:infixedu/screens/student/studyMaterials/StudyMaterialScreen.dart';
import 'package:infixedu/screens/student/studyMaterials/StydyMaterialMain.dart';
import 'package:infixedu/screens/student/teachers/StudentTeachersList.dart';
import 'package:infixedu/screens/student/timetable/StudentClassTimetable.dart';
import 'package:infixedu/screens/student/track/TrackScreen.dart';
import 'package:infixedu/screens/student/transportRoute/StudentTransportRoute.dart';
import 'package:infixedu/screens/student/videoclass/StudentVideoClass.dart';
import 'package:infixedu/screens/teacher/ClassAttendanceHome.dart';
import 'package:infixedu/screens/teacher/ClassSubjectAttendanceHome.dart';
import 'package:infixedu/screens/teacher/TeacherMyAttendance.dart';
import 'package:infixedu/screens/teacher/academic/AcademicsScreen.dart';
import 'package:infixedu/screens/teacher/academic/MySubjectScreen.dart';
import 'package:infixedu/screens/teacher/academic/SearchClassRoutine.dart';
import 'package:infixedu/screens/teacher/academic/TeacherRoutineScreen.dart';
import 'package:infixedu/screens/teacher/attendance/AttendanceScreen.dart';
import 'package:infixedu/screens/teacher/content/AddContentScreen.dart';
import 'package:infixedu/screens/teacher/content/ContentListScreen.dart';
import 'package:infixedu/screens/teacher/content/ContentScreen.dart';
import 'package:infixedu/screens/teacher/homework/AddHomeworkScreen.dart';
import 'package:infixedu/screens/teacher/homework/HomeworkScreen.dart';
import 'package:infixedu/screens/teacher/homework/TeacherHomeworkListScreen.dart';
import 'package:infixedu/screens/teacher/leave/ApplyLeaveScreen.dart';
import 'package:infixedu/screens/teacher/leave/LeaveScreen.dart';
import 'package:infixedu/screens/teacher/students/StudentSearch.dart';
import 'package:infixedu/screens/wallet/student/views/StudentWalletTransactions.dart';
import 'package:infixedu/utils/model/SystemSettings.dart';
import 'package:infixedu/utils/server/LogoutService.dart';
import 'package:infixedu/utils/widget/ScaleRoute.dart';

import '../screens/admin/attendance/AdminAttendanceScreen.dart';
import '../screens/admin/examination/AdminExaminationScreen.dart';
import '../screens/admin/homework/AdminHomeworkListScreen.dart';
import '../screens/teacher/students/SubjectStudentSearch.dart';
import '../screens/virtual_class/virtual_class_main.dart';

class AppFunction {
  static var students = [
    'Fees',
    'Attendance',
    'Teachers',
    'Apply Leave',
    'Complaint',
    'News',
    'Gallery',
    'Achievement',
    'Syllabus Status',
    'Examination',
    'Online Exam',
    'My Documents',
    'Notice Board',
    'Profile',
    'Live Class',
    'Video Class',
    'Homework',
    'Time table',
    'Syllabus',
    'Study Notes',
    'Test Papers',
    'Solved Papers',
    'Library',
    'Track Bus',
    'Transport Route',
    'Transport Settings',
    'Hostels',
    'About School',
    'Logout',
  ];
  static var studentIcons = [
    'assets/images/ic_nav_fees.png',
    'assets/images/ic_nav_attendance.png',
    'assets/images/ic_teacher.png',
    'assets/images/ic_applyleave.png',
    'assets/images/ic_complaint.png',
    'assets/images/ic_event_activity.png',
    'assets/images/ic_galary.png',
    'assets/images/ic_achievemnt.png',
    'assets/images/ic_syllabus.png',
    'assets/images/ic_nav_examination.png',
    'assets/images/ic_online_exams.png',
    'assets/images/ic_documents_certificate.png',
    'assets/images/ic_email_filled.png',
    'assets/images/ic_profile_plus.png',
    'assets/images/ic_profile_live.png',
    'assets/images/ic_sylllabuslist.png',
    'assets/images/ic_dashboard_homework.png',
    'assets/images/ic_calender_cross.png',
    'assets/images/syllabus.png',
    'assets/images/studynotes.png',
    'assets/images/testpaper.png',
    'assets/images/solvedpaper.png',
    'assets/images/ic_nav_library.png',
    'assets/images/ic_track.png',
    'assets/images/ic_nav_transport.png',
    'assets/images/outline_settings_black_48.png',
    'assets/images/ic_nav_hostel.png',
    'assets/images/ic_nav_about.png',
    'assets/images/ic_nav_logout.png',
  ];

  static var teachers = [
    'Students',
    'Academic',
    'Attendance',
    'Leave',
    'Content',
    'Notice',
    'Library',
    'Homework',
    'About',
    'Class',
    'Settings',
  ];

  static var teachersIcons = [
    'assets/images/students.png',
    'assets/images/academics.png',
    'assets/images/attendance.png',
    'assets/images/leave.png',
    'assets/images/contents.png',
    'assets/images/notice.png',
    'assets/images/library.png',
    'assets/images/homework.png',
    'assets/images/about.png',
    'assets/images/myroutine.png',
    'assets/images/addhw.png',
  ];

  static var admins = ['Attendance', 'Homework', 'Examination'];
  static var adminIcons = [
    'assets/images/ic_nav_attendance.png',
    'assets/images/ic_dashboard_homework.png',
    'assets/images/ic_nav_examination.png',
  ];

  static var parent = ['Child', 'About', 'Settings'];
  static var parentIcons = [
    'assets/images/mychild.png',
    'assets/images/about.png',
    'assets/images/addhw.png',
  ];

  static var parent2 = ['Child', 'About', 'Settings'];

  static var parentIcons2 = [
    'assets/images/mychild.png',
    'assets/images/about.png',
    'assets/images/addhw.png',
  ];

  static var adminTransport = [
    'Route',
    'Vehicle',
    'Assign Vehicle',
    'Transport',
  ];
  static var adminTransportIcons = [
    'assets/images/transport.png',
    'assets/images/transport.png',
    'assets/images/addhw.png',
    'assets/images/transport.png',
  ];

  static var adminDormitory = ['Add Dormitory', 'Add Room', 'Room List'];
  static var adminDormitoryIcons = [
    'assets/images/addhw.png',
    'assets/images/addhw.png',
    'assets/images/dormitory.png',
  ];

  static var librarys = ['Book List', 'Books Issued'];
  static var libraryIcons = [
    'assets/images/library.png',
    'assets/images/library.png',
  ];
  static var examinations = ['Schedule', 'Result'];
  static var examinationIcons = [
    'assets/images/examination.png',
    'assets/images/examination.png',
  ];

  static var onlineExaminations = ['Active Exam', 'Exam Result'];
  static var onlineExaminationIcons = [
    'assets/images/onlineexam.png',
    'assets/images/onlineexam.png',
  ];

  static var homework = ['Add HW', 'HW List'];
  static var homeworkIcons = [
    'assets/images/addhw.png',
    'assets/images/hwlist.png',
  ];

  static var contents = ['Add Content', 'Content List'];
  static var contentsIcons = [
    'assets/images/addhw.png',
    'assets/images/hwlist.png',
  ];

  static var leaves = ['Apply Leave', 'Leave List'];
  static var leavesIcons = [
    'assets/images/hwlist.png',
    'assets/images/addhw.png',
  ];

  static var adminLibrary = ['Add Book', 'Book List', 'Add Member'];
  static var adminLibraryIcons = [
    'assets/images/addhw.png',
    'assets/images/hwlist.png',
    'assets/images/addhw.png',
  ];

  static var academics = ['My Routine', 'Class Routine', 'Subjects'];
  static var academicsIcons = [
    'assets/images/myroutine.png',
    'assets/images/classroutine.png',
    'assets/images/subjects.png',
  ];

  static var attendance = [
    'Class Atten',
    'Subject Atten',
    'Search Atten',
    'Search Sub Atten',
  ];
  static var attendanceIcons = [
    'assets/images/classattendance.png',
    'assets/images/classattendance.png',
    'assets/images/searchattendance.png',
    'assets/images/searchattendance.png',
  ];

  static var studentattendance = ['Search Atten', 'Search Sub Atten'];
  static var studentattendanceIcons = [
    'assets/images/searchattendance.png',
    'assets/images/searchattendance.png',
  ];

  static var downloadLists = ['Assignment', 'Syllabus', 'Other Downloads'];
  static var downloadListIcons = [
    'assets/images/downloads.png',
    'assets/images/downloads.png',
    'assets/images/downloads.png',
  ];

  static var studentLeaves = ['Apply Leave', 'Leave List'];

  static var studentLeavesIcons = [
    'assets/images/hwlist.png',
    'assets/images/addhw.png',
  ];

  static var studentLessonPlan = ['Lesson Plan', 'Overview'];

  static var studentLessonPlanIcons = [
    'assets/images/routine.png',
    'assets/images/routine.png',
  ];

  static var adminFees = ['Add Fee', 'Fee List'];
  static var adminFeeIcons = [
    'assets/images/fees_icon.png',
    'assets/images/addhw.png',
  ];
  static var adminFeesNew = [
    'Fee Group',
    'Fee Type',
    'Fee Invoice',
    'Bank Payment',
    'Reports',
  ];
  static var adminFeeIconsNew = [
    'assets/images/fees_icon.png',
    'assets/images/fees_icon.png',
    'assets/images/fees_icon.png',
    'assets/images/fees_icon.png',
    'assets/images/fees_icon.png',
  ];

  static var adminFeesReport = [
    'Due Report',
    'Fine Report',
    'Payment Report',
    'Balance Report',
    'Waiver Report',
  ];

  static var driver = ['Transport', 'About', 'Settings'];
  static var driverIcons = [
    'assets/images/transport.png',
    'assets/images/about.png',
    'assets/images/addhw.png',
  ];

  static void getFunctions(BuildContext context, String rule, bool callApi) {
    Route route;

    switch (rule) {
      case '1':
        route = ScaleRoute(page: Home(admins, rule, adminIcons));
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
      case '2':
        Get.offAll(
          () => DashboardScreen(
            callApi: callApi,
            titles: isStudent() ? students : [],
            images: isStudent() ? studentIcons : [],
            role: rule,
            childUID: 0, // Provide appropriate value
            image: '', // Provide appropriate value
            token: '', // Provide appropriate value
            childName: '', // Provide appropriate value
            childId: 0, // Provide appropriate value
          ),
        );
        // route = ScaleRoute(
        //   page: DashboardScreen(
        //     titles: students,
        //     images: studentIcons,
        //     role: rule,
        //     childUID: 0, // Provide appropriate value
        //     image: '', // Provide appropriate value
        //     token: '', // Provide appropriate value
        //     childName: '', // Provide appropriate value
        //     childId: 0, // Provide appropriate value
        //   ),
        // );
        // Navigator.of(
        //   context,
        //   rootNavigator: true,
        // ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
      case '3':
        route = ScaleRoute(page: Home(parent, rule, parentIcons));
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
      case '4':
        route = ScaleRoute(
          page: DashboardScreen(
            callApi: callApi,
            titles: isStudent() ? teachers : [],
            images: isStudent() ? teachersIcons : [],
            role: rule,
            childUID: 0, // Provide appropriate value
            image: '', // Provide appropriate value
            token: '', // Provide appropriate value
            childName: '', // Provide appropriate value
            childId: 0, // Provide appropriate value
          ),
        );
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
      case '5':
        route = ScaleRoute(page: Home(admins, rule, adminIcons));
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
      case '9':
        route = ScaleRoute(page: Home(driver, rule, driverIcons));
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushAndRemoveUntil(route, (Route<dynamic> route) => false);
        break;
    }
  }

  static void getDashboardPage(
    BuildContext context,
    String title, {
    var id,
    String? image,
    int? zoom,
    String? token,
  }) {
    switch (title) {
      case 'Logout':
        Get.dialog(LogoutService().logoutDialog());
        break;
      case 'Track Bus':
        Navigator.push(context, ScaleRoute(page: TrackScreen()));
        break;
      case 'Transport Settings':
        Navigator.push(context, ScaleRoute(page: TransportSettings()));
        break;
      case 'Transport Route':
        Navigator.push(context, ScaleRoute(page: StudentTransportRoutes()));
        break;
      case 'Syllabus':
        Navigator.push(
          context,
          ScaleRoute(
            page: SyllabusScreen(title: 'Syllabus', tag: 'Assignments'),
          ),
        );
        break;
      case 'Study Notes':
        Navigator.push(
          context,
          ScaleRoute(
            page: SyllabusScreen(title: 'Study Notes', tag: 'Study Material'),
          ),
        );
        break;
      case 'Test Papers':
        Navigator.push(
          context,
          ScaleRoute(
            page: SyllabusScreen(title: 'Test Papers', tag: 'Syllabus'),
          ),
        );
        break;
      case 'Solved Papers':
        Navigator.push(
          context,
          ScaleRoute(
            page: SyllabusScreen(title: 'Solved Papers', tag: 'Other Download'),
          ),
        );
        break;
      case 'Online Exam':
        Navigator.push(context, ScaleRoute(page: StudentOnlineExamList()));
        break;
      case 'Video Class':
        Navigator.push(context, ScaleRoute(page: StudentVideoClass()));
        break;
      case 'Time table':
        Navigator.push(context, ScaleRoute(page: StudentClassTimetable()));
        break;
      case 'Library':
        Navigator.push(context, ScaleRoute(page: StudentLibraryScreen()));
        break;
      case 'Live Class':
        Navigator.push(context, ScaleRoute(page: StudentLiveClasses()));
        break;
      case 'Notice Board':
        Navigator.push(context, ScaleRoute(page: StudentNoticeBoard()));
        break;
      case 'My Documents':
        Navigator.push(context, ScaleRoute(page: StudentDocumentsScreen()));
        break;
      case 'Examination':
        Navigator.push(
          context,
          ScaleRoute(page: StudentExaminationList(isBackIconVisible: true)),
        );
        break;
      case 'Syllabus Status':
        Navigator.push(context, ScaleRoute(page: StudentSyllabusStatus()));
        break;
      case 'Achievement':
        Navigator.push(context, ScaleRoute(page: AchievementScreen()));
        break;
      case 'News':
        Navigator.push(context, ScaleRoute(page: NotificationScreen()));
        break;
      case 'Complaint':
        Navigator.push(context, ScaleRoute(page: StudentComplaint()));
        break;
      case 'Hostels':
        Navigator.push(context, ScaleRoute(page: StudentHostel()));
        break;
      case 'About School':
        Navigator.push(context, ScaleRoute(page: AboutSchool()));
        break;
      case 'Profile':
        Navigator.push(
          context,
          ScaleRoute(page: StudentProfileDetailsScreen()),
        );
        break;
      case 'Gallery':
        Navigator.push(context, ScaleRoute(page: GalleryActivity()));
        break;
      case 'Fees':
        Navigator.push(
          context,
          ScaleRoute(page: StudentFees(isBackIconVisible: true)),
        );
        break;
      case 'Profile':
        Navigator.push(
          context,
          ScaleRoute(page: Profile(id: id, image: image ?? '')),
        );
        break;
      case 'Wallet':
        // pushNewScreen(
        //   context,
        //   screen: const StudentWalletTransactions(),
        //   withNavBar: false,
        // );

        Navigator.push(context, ScaleRoute(page: StudentWalletTransactions()));

        break;
      case 'Routine':
        Navigator.push(context, ScaleRoute(page: Routine(id: id)));
        break;
      case 'Homework':
        Navigator.push(
          context,
          ScaleRoute(page: StudentHomework(id: id, isBackIconVisible: true)),
        );
        break;
      case 'Study Materials':
        Navigator.push(
          context,
          ScaleRoute(
            page: DownloadsHome(downloadLists, downloadListIcons, id: id),
          ),
        );
        break;
      case 'Apply Leave':
        Navigator.push(context, ScaleRoute(page: ApplyLeave()));
        break;
      case 'Dormitory':
        Navigator.push(context, ScaleRoute(page: const DormitoryScreen()));
        break;
      case 'Transport Route':
        Navigator.push(context, ScaleRoute(page: const TransportScreen()));
        break;
      case 'Subjects':
        Navigator.push(context, ScaleRoute(page: SubjectScreen(id: id)));
        break;
      case 'Teachers':
        Navigator.push(context, ScaleRoute(page: StudentTeachersList()));
        break;
      case 'Library':
        Navigator.push(
          context,
          ScaleRoute(page: LibraryHome(librarys, libraryIcons, id: id)),
        );
        break;
      case 'Notice Board':
        Navigator.push(context, ScaleRoute(page: const NoticeScreen()));
        break;
      case 'Time Table':
        Navigator.push(context, ScaleRoute(page: TimelineScreen(id: id)));
        break;
      case 'Online Exam':
        Navigator.push(
          context,
          ScaleRoute(
            page: OnlineExaminationHome(
              onlineExaminations,
              onlineExaminationIcons,
              id: id,
            ),
          ),
        );
        break;
      case 'Attendance':
        Navigator.push(context, ScaleRoute(page: StudentAttendanceScreen()));
        break;
      case 'Transport Settings':
        Navigator.push(context, ScaleRoute(page: const SettingScreen()));
        break;
      case 'Lesson':
        // pushNewScreen(
        //   context,
        //   screen: StudentLessonsView(id),
        //   withNavBar: false,
        // );

        Navigator.push(context, ScaleRoute(page: StudentLessonsView(id)));
        break;
      case 'Live Class':
        // pushNewScreen(context, screen: VirtualClassMain(), withNavBar: false);
        // break;

        Navigator.push(context, ScaleRoute(page: VirtualClassMain()));
        break;
    }
  }

  static void getAdminDashboardPage(
    BuildContext context,
    String title,
    String uid,
    SystemSettings systemSettings,
  ) {
    switch (title) {
      case 'Students':
        Navigator.push(context, ScaleRoute(page: StudentSearch(status: "1")));
        break;
      case 'Fees':
        if (systemSettings.data?.feesStatus == 0) {
          Navigator.push(
            context,
            ScaleRoute(
              page: AdminFeesHome(adminFees, adminFeeIcons, profileImage: ""),
            ),
          );
        } else {
          Navigator.push(
            context,
            ScaleRoute(
              page: AdminFeesHome(
                adminFeesNew,
                adminFeeIconsNew,
                profileImage: "",
              ),
            ),
          );
        }
        break;
      case 'Library':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminLibraryHome(
              adminLibrary,
              adminLibraryIcons,
              profileImage: "",
            ),
          ),
        );
        break;
      case 'Attendance':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminAttendanceHomeScreen(attendance, attendanceIcons),
          ),
        );
        break;
      case 'Transport':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminTransportHome(adminTransport, adminTransportIcons),
          ),
        );
        break;
      case 'Staff':
        Navigator.push(context, ScaleRoute(page: const AdminStaffList()));
        break;
      case 'Content':
        Navigator.push(
          context,
          ScaleRoute(page: ContentHomeScreen(contents, contentsIcons)),
        );
        break;
      case 'Notice':
        Navigator.push(context, ScaleRoute(page: const StaffNoticeScreen()));
        break;
      case 'Dormitory':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminDormitoryHome(adminDormitory, adminDormitoryIcons),
          ),
        );
        break;
      case 'Leave':
        Navigator.push(context, ScaleRoute(page: const LeaveAdminHomeScreen()));
        break;
      case 'Settings':
        Navigator.push(context, ScaleRoute(page: const SettingScreen()));
        break;
      case 'Class':
        // pushNewScreen(context, screen: VirtualClassMain(), withNavBar: false);

        Navigator.push(context, ScaleRoute(page: VirtualClassMain()));
        break;
    }
  }

  static void getSaasAdminDashboardPage(
    BuildContext context,
    String title,
    String uid,
    SystemSettings systemSettings,
  ) {
    switch (title) {
      case 'Attendance':
        Navigator.push(context, ScaleRoute(page: AdminAttendanceScreen()));
        break;
      case 'Homework':
        Navigator.push(context, ScaleRoute(page: AdminHomeworkListScreen()));
        break;
      case 'Examination':
        Navigator.push(context, ScaleRoute(page: AdminExaminationScreen()));
        break;
    }
  }

  static void getAdminFeePage(BuildContext context, String title) {
    switch (title) {
      case 'Add Fee':
        Navigator.push(context, ScaleRoute(page: const AddFeeType()));
        break;
      case 'Fee List':
        Navigator.push(context, ScaleRoute(page: const AdminFeeListView()));
        break;
    }
  }

  static void getAdminFeePageNew(BuildContext context, String title) {
    switch (title) {
      case 'Fee Group':
        Navigator.push(context, ScaleRoute(page: const FeesGroupScreen()));
        break;
      case 'Fee Type':
        Navigator.push(context, ScaleRoute(page: const FeesTypeScreen()));
        break;
      case 'Fee Invoice':
        Navigator.push(context, ScaleRoute(page: const FeesInvoiceScreen()));
        break;
      case 'Bank Payment':
        Navigator.push(context, ScaleRoute(page: const FeeBankPaymentSearch()));
        break;
      case 'Reports':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminFeesReportMain(adminFeesReport, adminFeeIconsNew),
          ),
        );
        break;
    }
  }

  static void getAdminFeesReportPage(BuildContext context, String title) {
    switch (title) {
      case 'Due Report':
        Navigator.push(context, ScaleRoute(page: const AdminFeesDueReport()));
        break;
      case 'Fine Report':
        Navigator.push(context, ScaleRoute(page: const AdminFeesFineReport()));
        break;
      case 'Payment Report':
        Navigator.push(
          context,
          ScaleRoute(page: const AdminFeesPaymentReport()),
        );
        break;
      case 'Balance Report':
        Navigator.push(
          context,
          ScaleRoute(page: const AdminFeesBalanceReport()),
        );
        break;
      case 'Waiver Report':
        Navigator.push(
          context,
          ScaleRoute(page: const AdminFeesWaiverReport()),
        );
        break;
    }
  }

  static void getAdminLibraryPage(BuildContext context, String title) {
    switch (title) {
      case 'Add Book':
        Navigator.push(context, ScaleRoute(page: const AddAdminBook()));
        break;
      case 'Add Member':
        Navigator.push(context, ScaleRoute(page: const AddMember()));
        break;
      case 'Book List':
        Navigator.push(context, ScaleRoute(page: const BookListScreen()));
        break;
    }
  }

  static void getAdminDormitoryPage(BuildContext context, String title) {
    switch (title) {
      case 'Room List':
        Navigator.push(context, ScaleRoute(page: const DormitoryScreen()));
        break;
      case 'Add Room':
        Navigator.push(context, ScaleRoute(page: const AddRoom()));
        break;
      case 'Add Dormitory':
        Navigator.push(context, ScaleRoute(page: const AddDormitory()));
        break;
    }
  }

  static void getAdminTransportPage(BuildContext context, String title) {
    switch (title) {
      case 'Route':
        Navigator.push(context, ScaleRoute(page: const AddRoute()));
        break;
      case 'Vehicle':
        Navigator.push(context, ScaleRoute(page: const AddVehicle()));
        break;
      case 'Assign Vehicle':
        Navigator.push(context, ScaleRoute(page: const AssignVehicle()));
        break;
      case 'Transport':
        Navigator.push(context, ScaleRoute(page: const TransportScreen()));
        break;
    }
  }

  static void getTeacherDashboardPage(
    BuildContext context,
    String title,
    String uid,
  ) {
    switch (title) {
      case 'Students':
        Navigator.push(
          context,
          ScaleRoute(page: StudentSearch(status: 'students')),
        );
        break;
      case 'Academic':
        Navigator.push(
          context,
          ScaleRoute(page: AcademicHomeScreen(academics, academicsIcons)),
        );
        break;
      case 'Attendance':
        Navigator.push(
          context,
          ScaleRoute(page: AttendanceHomeScreen(attendance, attendanceIcons)),
        );
        break;
      case 'Homework':
        Navigator.push(
          context,
          ScaleRoute(page: HomeworkHomeScreen(homework, homeworkIcons)),
        );
        break;
      case 'Content':
        Navigator.push(
          context,
          ScaleRoute(page: ContentHomeScreen(contents, contentsIcons)),
        );
        break;
      case 'Leave':
        Navigator.push(
          context,
          ScaleRoute(page: LeaveHomeScreen(leaves, leavesIcons)),
        );
        break;
      case 'Library':
        Navigator.push(context, ScaleRoute(page: const BookListScreen()));
        break;
      case 'Notice':
        Navigator.push(context, ScaleRoute(page: const StaffNoticeScreen()));
        break;
      case 'About':
        Navigator.push(context, ScaleRoute(page: const AboutScreen()));
        break;
      case 'Settings':
        Navigator.push(context, ScaleRoute(page: const SettingScreen()));
        break;
      case 'Class':
        // pushNewScreen(context, screen: VirtualClassMain(), withNavBar: false);

        Navigator.push(context, ScaleRoute(page: VirtualClassMain()));
        break;
    }
  }

  static void getParentDashboardPage(
    BuildContext context,
    String title,
    String uid,
  ) {
    switch (title) {
      case 'Child':
        Navigator.push(context, ScaleRoute(page: const ChildListScreen()));
        break;
      case 'About':
        Navigator.push(context, ScaleRoute(page: const AboutScreen()));
        break;
      case 'Settings':
        Navigator.push(context, ScaleRoute(page: const SettingScreen()));
        break;
      // case 'Zoom':
      //   Navigator.push(
      //       context,
      //       ScaleRoute(
      //           page: VirtualMeetingScreen(
      //             uid: uid,
      //           )));
      //   break;
    }
  }

  static void getAttendanceDashboardPage(BuildContext context, String title) {
    switch (title) {
      case 'Class Atten':
        Navigator.push(
          context,
          ScaleRoute(page: const StudentAttendanceHome()),
        );
        break;
      case 'Subject Atten':
        Navigator.push(
          context,
          ScaleRoute(page: const StudentSubjectAttendanceHome()),
        );
        break;
      case 'Search Atten':
        Navigator.push(
          context,
          ScaleRoute(page: StudentSearch(status: 'attendance')),
        );
        break;
      case 'Search Sub Atten':
        Navigator.push(
          context,
          ScaleRoute(page: SubjectStudentSearch(status: 'attendance')),
        );
        break;
      case 'My Atten':
        Navigator.push(
          context,
          ScaleRoute(page: const TeacherAttendanceScreen()),
        );
        break;
    }
  }

  static void getAdminAttendanceDashboardPage(
    BuildContext context,
    String title,
  ) {
    switch (title) {
      case 'Class Atten':
        Navigator.push(
          context,
          ScaleRoute(page: const StudentAttendanceHome()),
        );
        break;
      case 'Subject Atten':
        Navigator.push(
          context,
          ScaleRoute(page: const StudentSubjectAttendanceHome()),
        );
        break;
      case 'Search Atten':
        Navigator.push(
          context,
          ScaleRoute(page: StudentSearch(status: 'attendance')),
        );
        break;
      case 'Search Sub Atten':
        Navigator.push(
          context,
          ScaleRoute(page: SubjectStudentSearch(status: 'attendance')),
        );
        break;
    }
  }

  static void getAcademicDashboardPage(BuildContext context, String title) {
    switch (title) {
      case 'Subjects':
        Navigator.push(context, ScaleRoute(page: const MySubjectScreen()));
        break;
      case 'Class Routine':
        Navigator.push(context, ScaleRoute(page: const SearchRoutineScreen()));
        break;
      case 'My Routine':
        Navigator.push(
          context,
          ScaleRoute(page: const TeacherMyRoutineScreen()),
        );
        break;
    }
  }

  static void getLibraryDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Book List':
        Navigator.push(context, ScaleRoute(page: const BookListScreen()));
        break;
      case 'Books Issued':
        Navigator.push(context, ScaleRoute(page: BookIssuedScreen(id: id)));
        break;
    }
  }

  static void getHomeworkDashboardPage(BuildContext context, String title) {
    switch (title) {
      case 'HW List':
        Navigator.push(context, ScaleRoute(page: const TeacherHomework()));
        break;
      case 'Add HW':
        Navigator.push(context, ScaleRoute(page: const AddHomeworkScrren()));
        break;
    }
  }

  static void getContentDashboardPage(BuildContext context, String title) {
    switch (title) {
      case 'Content List':
        Navigator.push(context, ScaleRoute(page: const ContentListScreen()));
        break;
      case 'Add Content':
        Navigator.push(context, ScaleRoute(page: const AddContentScreeen()));
        break;
    }
  }

  static void getLeaveDashboardPage(BuildContext context, String title) {
    switch (title) {
      case 'Leave List':
        Navigator.push(context, ScaleRoute(page: LeaveListStudent(id: '')));
        break;
      case 'Apply Leave':
        Navigator.push(context, ScaleRoute(page: const ApplyLeaveScreen()));
        break;
    }
  }

  static void getExaminationDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Schedule':
        Navigator.push(context, ScaleRoute(page: ScheduleScreen(id: id)));
        break;
      case 'Result':
        Navigator.push(
          context,
          ScaleRoute(page: ClassExamResultScreen(id: id)),
        );
        break;
    }
  }

  static void getDownloadsDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Assignment':
        Navigator.push(
          context,
          ScaleRoute(page: StudentStudyMaterialMain(id: id, type: 'as')),
        );
        break;
      case 'Syllabus':
        Navigator.push(
          context,
          ScaleRoute(page: StudentStudyMaterialMain(id: id, type: 'sy')),
        );
        break;
      case 'Other Downloads':
        Navigator.push(
          context,
          ScaleRoute(page: StudentStudyMaterialMain(id: id, type: 'ot')),
        );
        break;
    }
  }

  static void getStudentAttendanceDashboardPage(
    BuildContext context,
    String title, {
    var id,
    String? image,
    int? zoom,
    String? token,
  }) {
    switch (title) {
      case 'Search Atten':
        Navigator.push(context, ScaleRoute(page: StudentAttendanceScreen()));
        break;
      case 'Search Sub Atten':
        Navigator.push(
          context,
          ScaleRoute(
            page: StudentSubjectListScreen(id: id, token: token, schoolId: id),
          ),
        );
        break;
      // Navigator.push(
      //     context,
      //     ScaleRoute(
      //         page: StudentSubjectAttendanceScreen(
      //       id: id,
      //       token: token,
      //     )));
      // break;
    }
  }

  static void getStudentLeaveDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Apply Leave':
        Navigator.push(context, ScaleRoute(page: LeaveStudentApply(id)));
        break;
      case 'Leave List':
        Navigator.push(context, ScaleRoute(page: LeaveListStudent(id: id)));
        break;
    }
  }

  static void getOnlineExaminationDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Active Exam':
        Navigator.push(
          context,
          ScaleRoute(page: ActiveOnlineExamScreen(id: id)),
        );
        break;
      case 'Exam Result':
        Navigator.push(
          context,
          ScaleRoute(page: OnlineExamResultScreen(id: id)),
        );
        break;
    }
  }

  static void getOnlineExaminationModuleDashboardPage(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Active Exam':
        Navigator.push(context, ScaleRoute(page: ActiveOnlineExams(id: id)));
        break;
      case 'Exam Result':
        Navigator.push(context, ScaleRoute(page: OnlineExamResults(id: id)));
        break;
    }
  }

  static void getDriverDashboard(
    BuildContext context,
    String title,
    String uid,
    SystemSettings systemSettings,
  ) {
    switch (title) {
      case 'Transport':
        Navigator.push(
          context,
          ScaleRoute(
            page: AdminTransportHome(adminTransport, adminTransportIcons),
          ),
        );
        break;
      case 'About':
        Navigator.push(context, ScaleRoute(page: const AboutScreen()));
        break;
      case 'Settings':
        Navigator.push(context, ScaleRoute(page: const SettingScreen()));
        break;
    }
  }

  static String getContentType(String ctype) {
    String type = '';
    switch (ctype) {
      case 'as':
        type = 'assignment';
        break;
      case 'st':
        type = 'study material';
        break;
      case 'sy':
        type = 'syllabus';
        break;
      case 'ot':
        type = 'others download';
        break;
    }
    return type;
  }

  static var weeks = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static void getStudentLessonPlanDashboard(
    BuildContext context,
    String title, {
    var id,
  }) {
    switch (title) {
      case 'Lesson Plan':
        // pushNewScreen(
        //   context,
        //   screen: StudentLessonsView(id),
        //   withNavBar: false,
        // );

        Navigator.push(context, ScaleRoute(page: StudentLessonsView(id)));
        break;
      case 'Overview':
        Navigator.push(context, ScaleRoute(page: StudentLessonsView(id)));
        break;
    }
  }

  //formet time
  static String getAmPm(String time) {
    var parts = time.split(":");
    String part1 = parts[0];
    String part2 = parts[1];

    int hr = int.parse(part1);
    int min = int.parse(part2);

    if (hr <= 12) {
      if (hr == 10 || hr == 11 || hr == 12) {
        return "$hr:$min"
            "am";
      }
      return "0$hr:$min"
          "am";
    } else {
      hr = hr - 12;
      return "0$hr:$min"
          "pm";
    }
  }

  static String getExtention(String url) {
    var parts = url.split("/");
    return parts[parts.length - 1];
  }

  //return day of month
  static String getDay(String date) {
    var parts = date.split("-");
    return parts[parts.length - 1];
  }
}
