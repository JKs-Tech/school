// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smart_edge_alert/smart_edge_alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
// Project imports:
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/screens/notification/NotificationListScreen.dart';
import 'package:infixedu/screens/student/Profile.dart';
import 'package:infixedu/screens/student/notification/NotificationScreen.dart';
import 'package:infixedu/utils/CardItem.dart';
import 'package:infixedu/utils/FunctinsData.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:infixedu/utils/localdb/DatabaseHelper.dart';
import 'package:infixedu/utils/model/UserNotifications.dart';
import 'package:infixedu/utils/server/LogoutService.dart';
import 'package:infixedu/utils/widget/ScaleRoute.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:infixedu/screens/StudentItem.dart';

import '../main.dart';
import 'ChangePassword.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

// ignore: must_be_immutable
class Home extends StatefulWidget {
  List<String> titles;

  List<String> images;

  String rule;

  Home(this.images, this.rule, this.titles, {super.key});

  @override
  // ignore: no_logic_in_create_state
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isTapped = false, hasMultipleChild = false;
  int currentSelectedIndex = 0,
      menuIndex = 0,
      rtlValue = 0,
      studentId = 0,
      _currentBannerIndex = 0,
      _unreadCount = 0;
  String? email,
      password,
      _rule,
      role,
      _id,
      schoolId,
      isAdministrator,
      profileImageUrl,
      studentClass,
      appLogo,
      schoolName,
      baseImageUrl;

  // ignore: prefer_typing_uninitialized_variables
  var _token;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? _notificationToken;

  Future? notificationCount;
  Future? about;
  Future? slider;
  String _fullName = "";
  final SystemController _systemController = Get.put(SystemController());
  bool _updateAvailable = false, studentLoading = false;
  AppUpdateInfo? _updateInfo;

  List<String> menuTitle = [
    'Header',
    'Banner',
    'Notice',
    'Academic',
    'LMS',
    'Facilities',
  ];
  Map<String, List<Map<String, dynamic>>>? homepageMapping = {};
  List<Map<String, String>> bannerList = [];
  List<Map<String, String>> noticeList = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initValues();
  }

  Future<void> initValues() async {
    _token = await Utils.getStringValue('token');
    email = await Utils.getStringValue('email');
    _fullName = await Utils.getStringValue('full_name');
    password = await Utils.getStringValue('password');
    schoolId = await Utils.getStringValue('schoolId');
    _rule = await Utils.getStringValue('rule');
    _id = await Utils.getStringValue('id');
    studentId = await Utils.getIntValue('studentId');
    role = await Utils.getStringValue('role');
    notificationCount = getNotificationCount(int.parse(_id ?? '0'));
    isAdministrator = await Utils.getStringValue('isAdministrator');
    rtlValue = await Utils.getIntValue('locale');
    profileImageUrl =
        await InfixApi.getImageUrl() + await Utils.getStringValue('image');
    hasMultipleChild = await Utils.getBooleanValue('hasMultipleChild');
    studentClass =
        "${await Utils.getStringValue('className')}-${await Utils.getStringValue('sectionName')}";
    appLogo = await Utils.getStringValue('appLogo');
    schoolName = await Utils.getStringValue('schoolName');
    _unreadCount = await dbHelper.getUnreadMessageCount();
    baseImageUrl = await InfixApi.getImageUrl();
    if ('2' == _rule) {
      await createStudentMenu();
    }
    setState(() {});
    //init settings for android
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // var initializationSettingsIOS = IOSInitializationSettings(
    // onDidReceiveLocalNotification: (
    //   int id,
    //   String title,
    //   String body,
    //   String payload,
    // ) async {
    //   didReceiveLocalNotificationSubject.add(
    //     ReceivedNotification(
    //       id: id,
    //       title: title,
    //       body: body,
    //       payload: payload,
    //     ),
    //   );
    // },
    //);
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      // iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onSelectNotification: (String? payload) async {
      //   debugPrint('notification payload: $payload');
      //   selectNotificationSubject.add(payload ?? '');
      // },
    );

    didReceiveLocalNotificationSubject.stream.listen((
      ReceivedNotification receivedNotification,
    ) async {
      await showDialog(
        context: context,
        builder:
            (BuildContext context) => CupertinoAlertDialog(
              title:
                  receivedNotification.title != null
                      ? Text(receivedNotification.title)
                      : null,
              content:
                  receivedNotification.body != null
                      ? Text(receivedNotification.body)
                      : null,
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Ok'),
                  onPressed: () async {},
                ),
              ],
            ),
      );
    });
    selectNotificationSubject.stream.listen((String payload) async {});
    notificationSubscription();
    isTapped = false;
    getFCMToken();
    checkForUpdate();
    fetchDashboardData();
  }

  Future<void> createStudentMenu() async {
    List<Map<String, dynamic>> academicList = [];
    for (int i = 0; i < 14; i++) {
      academicList.add({'title': widget.titles[i], 'image': widget.images[i]});
    }
    homepageMapping?[menuTitle[3]] = academicList;
    List<Map<String, dynamic>> lmsList = [];
    for (int i = 14; i < 23; i++) {
      lmsList.add({'title': widget.titles[i], 'image': widget.images[i]});
    }
    homepageMapping?[menuTitle[4]] = lmsList;
    List<Map<String, dynamic>> facilitiesList = [];
    for (int i = 23; i < widget.titles.length; i++) {
      facilitiesList.add({
        'title': widget.titles[i],
        'image': widget.images[i],
      });
    }
    homepageMapping?[menuTitle[5]] = facilitiesList;
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate()
        .then((info) {
          _updateInfo = info;
          _updateAvailable =
              info.updateAvailability == UpdateAvailability.updateAvailable;
          if (_updateAvailable) {
            showUpdateDialog(context);
          }
        })
        .catchError((e) {
          print('error = $e');
        });
  }

  void showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // User cannot dismiss the dialog by tapping outside it
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('App Update Required'),
          content: Text('Need to update to use this app.'),
          actions: <Widget>[
            TextButton(
              child: Text('Exit App'),
              onPressed: () {
                exit(0); // This will close the app
              },
            ),
            TextButton(
              child: Text('Update App'),
              onPressed: () {
                if (_updateInfo?.immediateUpdateAllowed ?? false) {
                  InAppUpdate.performImmediateUpdate();
                } else {
                  InAppUpdate.startFlexibleUpdate();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Inside your push notification handler
  Future<void> onPushNotificationReceived(
    String messageId,
    RemoteNotification remoteNotification,
  ) async {
    final title = remoteNotification.title;
    final body = remoteNotification.body;
    final date = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
    await dbHelper.saveNotification(messageId, date, title ?? "", body ?? "");
    _unreadCount = await dbHelper.getUnreadMessageCount();
    setState(() {});
  }

  Future<void> getFCMToken() async {
    var fcmToken = await messaging.getToken();
    await Utils.saveStringValue('fcmToken', fcmToken ?? '');
    print('fcmToken = $fcmToken');
  }

  notificationSubscription() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    // messaging.getToken().then((value) {
    //   setState(() {
    //     _notificationToken = value;
    //     sendTokenToServer(_notificationToken);
    //   });
    // });
    debugPrint('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // print('Got a message whilst in the foreground! ===> HOME.DART');
      // print("Notification Title : ${message.notification.title}");
      // print("Notification Body: ${message.notification.body}");
      // print('DATA: ${message.data.toString()}');

      print("onMessage called $message");
      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        if (mounted) {
          SmartEdgeAlert.show(
            context,
            title: message.notification?.title,
            description: message.notification?.body,
            gravity: SmartEdgeAlert.top,
            backgroundColor: Colors.deepPurple,
            icon: Icons.notifications_active,
            duration: 5,
          );
        }

        RemoteNotification notification =
            message.notification ?? RemoteNotification();

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              //channel.description,
              importance: Importance.high,
              priority: Priority.high,

              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
        onPushNotificationReceived(message.messageId ?? "", notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('Got a message whilst in the onMessageOpenedApp!');
      // print("Notification Title : ${message.notification.title}");
      // print("Notification Body: ${message.notification.body}");
      // print('DATA: ${message.data.toString()}');
      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        if (mounted) {
          SmartEdgeAlert.show(
            context,
            title: message.notification?.title,
            description: message.notification?.body,
            gravity: SmartEdgeAlert.top,
            backgroundColor: Colors.deepPurple,
            icon: Icons.notifications_active,
            duration: 5,
          );
        }
      }
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      final dateFrom = Utils.getDateOfMonth(DateTime.now(), "first");
      final dateTo = Utils.getDateOfMonth(DateTime.now(), "last");

      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getDashBoardUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode({
          "student_id": studentId.toString(),
          "date_from": dateFrom,
          "date_to": dateTo,
          'schoolId': await Utils.getStringValue('schoolId'),
        }),
      );
      print("dashboard response = $response");
      if (response.statusCode == 200) {
        final result = response.body;
        Map<String, dynamic> object = json.decode(result);

        print("dashboard object = $object");

        List<dynamic> banners = object["banner"] ?? [];
        String basePath = await Utils.getStringValue('imageUrl');
        for (var bannerObject in banners) {
          Map<String, String> item = {};
          item["url"] =
              basePath + bannerObject["dir_path"] + bannerObject["img_name"];
          item["thumb"] =
              basePath +
              bannerObject["thumb_path"] +
              bannerObject["thumb_name"];
          bannerList.add(item);
        }

        List<dynamic> notices = object["notice"] ?? [];
        for (var noticeObject in notices) {
          noticeList.add({
            'title': noticeObject['title'],
            'description': noticeObject['description'],
          });
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Something went wrong')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    } finally {
      setState(() {});
    }
  }

  Widget setNotificationList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: 160.0, // Increased height to accommodate new design
              enlargeCenterPage: false,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: noticeList.length > 1,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                // Handle change if required.
              },
            ),
            items:
                noticeList.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(child: notificationListItem(item));
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget notificationListItem(Map<String, dynamic> noticeItem) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    // Remove HTML tags from description for preview
    String cleanDescription = _removeHtmlTags(noticeItem['description'] ?? '');
    bool isLongDescription =
        cleanDescription.length > 50; // Reduced from 80 to 50
    String previewText =
        isLongDescription
            ? cleanDescription.substring(0, 50) +
                '...' // Reduced from 80 to 50
            : cleanDescription;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6.0 : 8.0, // Reduced padding
        vertical: 4.0, // Reduced vertical padding
      ),
      child: Material(
        elevation: 1, // Reduced elevation
        borderRadius: BorderRadius.circular(12), // Reduced border radius
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _showNotificationDetailsDialog(noticeItem);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                isSmallScreen ? 8.0 : 10.0,
              ), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Important: minimize height
                children: [
                  // Header Row with Icon and Date
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: Colors.blue,
                          size: 14, // Reduced icon size
                        ),
                      ),
                      SizedBox(width: 8), // Reduced spacing
                      Expanded(
                        child: Text(
                          noticeItem['title'] ?? 'No Title',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize:
                                isSmallScreen
                                    ? 14
                                    : 15, // Increased for better readability
                            color: Colors.grey[800],
                            height: 1.2, // Slightly increased line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (noticeItem['date'] != null) ...[
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDate(noticeItem['date']),
                            style: TextStyle(
                              fontSize: 10, // Increased for better readability
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 6), // Reduced spacing
                  // Description Preview - More compact
                  if (cleanDescription.isNotEmpty) ...[
                    Text(
                      previewText,
                      style: TextStyle(
                        fontSize:
                            isSmallScreen
                                ? 12
                                : 13, // Increased for better readability
                        color: Colors.grey[600],
                        height: 1.3, // Slightly increased line height
                      ),
                      maxLines: 2, // Reduced to 2 lines
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6), // Reduced spacing
                  ],

                  // Action Buttons Row - More compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tap to view indicator - More compact
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 4, // Reduced padding
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 13, // Slightly increased icon size
                                color: Colors.blue[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Tap for details',
                                style: TextStyle(
                                  fontSize:
                                      10, // Increased for better readability
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(width: 8), // Reduced spacing
                      // Read More Button - More compact
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isSmallScreen ? 8 : 10, // Reduced padding
                            vertical: isSmallScreen ? 4 : 6, // Reduced padding
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 1, // Reduced elevation
                          minimumSize: Size(0, 0), // Allow smaller button
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            ScaleRoute(page: NotificationScreen()),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward,
                              size:
                                  isSmallScreen
                                      ? 13
                                      : 15, // Increased icon size
                            ),
                            SizedBox(width: 3),
                            Text(
                              'News',
                              style: TextStyle(
                                fontSize:
                                    isSmallScreen
                                        ? 11
                                        : 12, // Increased for better readability
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to remove HTML tags
  String _removeHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return htmlString;

    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
  }

  // Helper method to format date
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return dateString;
    }
  }

  // Method to show notification details in a dialog
  void _showNotificationDetailsDialog(Map<String, dynamic> noticeItem) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Notification Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          noticeItem['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 8),

                        // Date
                        if (noticeItem['date'] != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              noticeItem['date'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],

                        // Description
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Html(
                            data:
                                noticeItem['description'] ??
                                'No description available.',
                            style: {
                              "body": Style(
                                fontSize: FontSize(14),
                                color: Colors.grey[700],
                                lineHeight: LineHeight(1.5),
                              ),
                              "p": Style(margin: Margins.only(bottom: 8)),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Close',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              ScaleRoute(page: NotificationScreen()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget bannerListUi() {
    if (isStudent() == false) {
      return Container();
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: 180.0,
              enlargeCenterPage: false,
              autoPlay: bannerList.length > 1,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: bannerList.length > 1,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
            ),
            items:
                bannerList.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: CachedNetworkImage(
                          imageUrl: item['url'] ?? '',
                          fit: BoxFit.fill,
                          errorWidget:
                              (context, url, error) => Icon(Icons.error),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
          SizedBox(height: 10.0), // space between slider and dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                bannerList.asMap().entries.map((entry) {
                  return Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentBannerIndex == entry.key
                              ? Colors.blueAccent
                              : Colors.grey[400],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget setHeaderUi() {
    if (isStudent() == false) {
      return Container();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      color: Color(0xFF002047), // Assuming header_color is a shade of blue
      height: 120.0,
      child: Row(
        children: <Widget>[
          // Profile Image
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircleAvatar(
              radius: isSmallScreen ? 32.0 : 40.0, // Smaller on small screens
              backgroundColor: Colors.transparent,
              child: CachedNetworkImage(
                imageUrl: profileImageUrl ?? "https://via.placeholder.com/150",
                imageBuilder:
                    (context, imageProvider) => CircleAvatar(
                      radius: isSmallScreen ? 32.0 : 40.0,
                      backgroundImage: imageProvider,
                    ),
                errorWidget:
                    (context, url, error) => CircleAvatar(
                      radius: isSmallScreen ? 32.0 : 40.0,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isSmallScreen ? 32 : 40,
                      ),
                    ),
              ),
            ),
          ),

          // Vertical Divider
          Container(
            width: 1.0,
            height: 24.0,
            color: Colors.white,
            margin: const EdgeInsets.only(top: 16.0),
          ),

          // Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Row(
                children: [
                  // Student Info - Flexible to take available space
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 16.0 : 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          studentClass ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 13.0 : 14.0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Switch Button - Fixed width to ensure visibility
                  if (role.toString().toLowerCase() == 'parent' &&
                      hasMultipleChild == true) ...[
                    SizedBox(width: 12.0),
                    Container(
                      width: isSmallScreen ? 70.0 : 80.0, // Fixed width
                      child: ElevatedButton(
                        onPressed: () {
                          getParentStudents();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8.0 : 12.0,
                            vertical: isSmallScreen ? 6.0 : 8.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'Switch',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12.0 : 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            height: 110.h,
            padding: EdgeInsets.only(top: 20.h),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConfig.appToolbarBackground),
                fit: BoxFit.fill,
              ),
              color: Colors.deepPurple,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: 200.h,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(height: 15),
                        Flexible(
                          child:
                              appLogo != null && appLogo != ''
                                  ? Image.network(
                                    '$appLogo?${Random().nextInt(11)}',
                                    height: 30.h,
                                  )
                                  : Image.asset(AppConfig.appLogo, height: 30),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          schoolName ?? "",
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white, fontSize: 12),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          ScaleRoute(page: NotificationListScreen()),
                        );
                        _unreadCount = 0;
                        setState(() {});
                      },
                      icon: Icon(Icons.add_alert, size: 25.sp),
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _unreadCount
                                .toString(), // Replace with your actual count
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Get.dialog(LogoutService().logoutDialog());
                  },
                  icon: Icon(Icons.exit_to_app, size: 25.sp),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      body:
          _rule == '2'
              ? Obx(() {
                if (_systemController.isLoading.value) {
                  return const Center(child: CupertinoActivityIndicator());
                } else {
                  return ListView.builder(
                    itemCount: menuTitle.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          menuTitle[index] == 'Header'
                              ? setHeaderUi()
                              : menuTitle[index] == 'Banner'
                              ? (bannerList.isNotEmpty
                                  ? bannerListUi()
                                  : Container())
                              : menuTitle[index] == 'Notice'
                              ? noticeList.isNotEmpty
                                  ? setNotificationList()
                                  : Container()
                              : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        menuTitle[index],
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    itemCount:
                                        homepageMapping?[menuTitle[index]]
                                            ?.length,
                                    itemBuilder: (context, itemIndex) {
                                      return CustomWidget(
                                        index: index,
                                        isSelected:
                                            currentSelectedIndex == itemIndex &&
                                            menuIndex == index,
                                        onSelect: () {
                                          if (isStudent()) {
                                            setState(() {
                                              currentSelectedIndex = itemIndex;
                                              menuIndex = index;
                                              AppFunction.getDashboardPage(
                                                context,
                                                homepageMapping?[menuTitle[index]]?[itemIndex]['title'] ??
                                                    "",
                                                id: _id,
                                                token: _token,
                                              );
                                            });
                                          }
                                        },
                                        headline:
                                            homepageMapping?[menuTitle[index]]?[itemIndex]['title'] ??
                                            "",
                                        icon:
                                            homepageMapping?[menuTitle[index]]?[itemIndex]['image'] ??
                                            "",
                                      );
                                    },
                                  ),
                                  if (index == menuTitle.length - 1)
                                    SizedBox(height: 50.h),
                                ],
                              ),
                        ],
                      );
                    },
                  );
                }
              })
              : Obx(() {
                if (_systemController.isLoading.value) {
                  return const Center(child: CupertinoActivityIndicator());
                } else {
                  return ListView(
                    shrinkWrap: false,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: widget.titles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                        itemBuilder: (context, index) {
                          return CustomWidget(
                            index: index,
                            isSelected: currentSelectedIndex == index,
                            onSelect: () {
                              setState(() {
                                currentSelectedIndex = index;
                                if (_rule == '2') {
                                  AppFunction.getDashboardPage(
                                    context,
                                    widget.titles[index],
                                    id: _id,
                                    token: _token,
                                  );
                                } else if (_rule == '4') {
                                  AppFunction.getTeacherDashboardPage(
                                    context,
                                    widget.titles[index],
                                    _id ?? '',
                                  );
                                } else if (_rule == '3') {
                                  AppFunction.getParentDashboardPage(
                                    context,
                                    widget.titles[index],
                                    _id ?? '',
                                  );
                                } else if (_rule == '1' || _rule == '5') {
                                  if (isAdministrator == 'yes') {
                                    AppFunction.getSaasAdminDashboardPage(
                                      context,
                                      widget.titles[index],
                                      _id ?? '',
                                      _systemController.systemSettings.value,
                                    );
                                  } else {
                                    AppFunction.getAdminDashboardPage(
                                      context,
                                      widget.titles[index],
                                      _id ?? '',
                                      _systemController.systemSettings.value,
                                    );
                                  }
                                } else if (_rule == '9') {
                                  AppFunction.getDriverDashboard(
                                    context,
                                    widget.titles[index],
                                    _id ?? '',
                                    _systemController.systemSettings.value,
                                  );
                                }
                              });
                            },
                            headline: widget.titles[index],
                            icon: widget.images[index],
                          );
                        },
                      ),
                      SizedBox(height: 50.h),
                    ],
                  );
                }
              }),
    );
  }

  buildNotificationDialog(context, String id) {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3.5,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(color: Colors.deepPurple, blurRadius: 20.0),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        top: 20.0,
                        right: 15.0,
                      ),
                      child: FutureBuilder<UserNotificationList>(
                        future: getNotifications(int.parse(id)),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            if (snapshot.data?.userNotifications?.isEmpty ??
                                true) {
                              return Text(
                                "No new notifications",
                                textAlign: TextAlign.end,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              );
                            } else {
                              return Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: false,
                                      itemCount:
                                          snapshot
                                              .data
                                              ?.userNotifications
                                              ?.length,
                                      itemBuilder: (context, index) {
                                        final item =
                                            snapshot
                                                .data
                                                ?.userNotifications?[index];
                                        return Material(
                                          color: Colors.transparent,
                                          clipBehavior: Clip.antiAlias,
                                          child: Dismissible(
                                            key: Key(item?.id.toString() ?? ''),
                                            background: Container(
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.purpleAccent,
                                                    Colors.deepPurpleAccent,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 6,
                                                    offset: const Offset(
                                                      1,
                                                      1,
                                                    ), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onDismissed: (direction) async {
                                              var response = await http.get(
                                                Uri.parse(
                                                  InfixApi.readMyNotifications(
                                                    int.parse(id),
                                                    snapshot
                                                        .data
                                                        ?.userNotifications?[index]
                                                        .id,
                                                  ),
                                                ),
                                                headers: Utils.setHeader(
                                                  _token.toString(),
                                                ),
                                              );

                                              if (response.statusCode == 200) {
                                                Map<String, dynamic>
                                                notifications =
                                                    jsonDecode(response.body)
                                                        as Map<String, dynamic>;
                                                bool status =
                                                    notifications['data']['status'];
                                                if (status == true) {
                                                  setState(() {
                                                    debugPrint("Index :$index");
                                                    snapshot
                                                        .data
                                                        ?.userNotifications
                                                        ?.removeAt(index);
                                                  });
                                                }
                                              } else {
                                                debugPrint(
                                                  'Error retrieving from api',
                                                );
                                              }
                                              setState(() {
                                                notificationCount =
                                                    getNotificationCount(
                                                      int.parse(_id ?? '0'),
                                                    );
                                              });
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(SnackBar(
                                              //         content: Text(
                                              //             "${item.message} read")));
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.solidBell,
                                                  color: Colors.deepPurple,
                                                  size: ScreenUtil().setSp(15),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item?.message ?? '',
                                                      textAlign: TextAlign.end,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(13),
                                                          ),
                                                    ),
                                                    Text(
                                                      timeago.format(
                                                        item?.createdAt ??
                                                            DateTime.now(),
                                                      ),
                                                      textAlign: TextAlign.end,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineSmall
                                                          ?.copyWith(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(12),
                                                          ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      var response = await http.get(
                                        Uri.parse(
                                          InfixApi.readAllNotification(
                                            int.parse(id),
                                          ),
                                        ),
                                        headers: Utils.setHeader(
                                          _token.toString(),
                                        ),
                                      );
                                      debugPrint('${response.statusCode}');
                                      if (response.statusCode == 200) {
                                        Map<String, dynamic> notifications =
                                            jsonDecode(response.body)
                                                as Map<String, dynamic>;
                                        bool status =
                                            notifications['data']['status'];
                                        if (status == true) {
                                          debugPrint('read-all');
                                        }
                                      } else {
                                        debugPrint('Error retrieving from api');
                                      }
                                      setState(() {
                                        notificationCount =
                                            getNotificationCount(
                                              int.parse(_id ?? "0"),
                                            );
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                    child: Text(
                                      'Mark all as read',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall?.copyWith(
                                        fontSize: ScreenUtil().setSp(12),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          } else {
                            return const Center(
                              child: CupertinoActivityIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showAlertDialog(BuildContext context) {
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
        Utils.clearAllValue();
        Utils.saveIntValue('locale', rtlValue);
        Route route = MaterialPageRoute(builder: (context) => const MyApp());
        Navigator.pushAndRemoveUntil(context, route, ModalRoute.withName('/'));

        var response = await http.post(
          Uri.parse(InfixApi.logout()),
          headers: Utils.setHeader(_token.toString()),
        );
        if (response.statusCode == 200) {
        } else {
          Utils.showToast('Unable to logout');
        }
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Logout", style: Theme.of(context).textTheme.headlineSmall),
      content: const Text("Would you like to logout?"),
      actions: [cancelButton, yesButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showStudentProfileDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: const BoxDecoration(
                    shape:
                        BoxShape
                            .rectangle, // BoxShape.circle or BoxShape.retangle
                    //color: const Color(0xFF66BB6A),
                    boxShadow: [
                      BoxShadow(color: Colors.deepPurple, blurRadius: 20.0),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          top: 20.0,
                          right: 15.0,
                        ),
                        child: ListView(
                          children: <Widget>[
                            InkWell(
                              child: SizedBox(
                                child: Text(
                                  "Profile",
                                  textAlign: TextAlign.end,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  ScaleRoute(
                                    page: Profile(
                                      id: _id ?? "  ",
                                      image: profileImageUrl ?? "",
                                    ),
                                  ),
                                );
                              },
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(
                                  context,
                                ).push(ScaleRoute(page: ChangePassword()));
                              },
                              child: SizedBox(
                                child: Text(
                                  "Change Password",
                                  textAlign: TextAlign.end,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ),
                            InkWell(
                              child: SizedBox(
                                child: Text(
                                  "Logout",
                                  textAlign: TextAlign.end,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              onTap: () {
                                showAlertDialog(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showOthersProfileDialog(BuildContext context) {
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
                  height: MediaQuery.of(context).size.height / 6,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                    shape:
                        BoxShape
                            .rectangle, // BoxShape.circle or BoxShape.retangle
                    //color: const Color(0xFF66BB6A),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.shade300,
                        blurRadius: 20.0,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        top: 20.0,
                        right: 15.0,
                      ),
                      child: ListView(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(
                                context,
                              ).push(ScaleRoute(page: ChangePassword()));
                            },
                            child: Text(
                              "Change Password",
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          GestureDetector(
                            child: Text(
                              "Logout",
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            onTap: () {
                              showAlertDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget getProfileImage(
    BuildContext context,
    String email,
    String password,
    String rule,
  ) {
    return FutureBuilder(
      future: Utils.getStringValue('image'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          Utils.saveStringValue(
            'image',
            snapshot.data ?? 'http://saskolhmg.com/images/studentprofile.png',
          );
          return GestureDetector(
            onTap: () {
              rule == '2'
                  ? showStudentProfileDialog(context)
                  : showOthersProfileDialog(context);
            },
            child: Container(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: ScreenUtil().setSp(22),
                child: CachedNetworkImage(
                  imageUrl: InfixApi.root + (snapshot.data ?? ''),
                  imageBuilder:
                      (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                      ),
                  placeholder:
                      (context, url) => const CupertinoActivityIndicator(),
                  errorWidget:
                      (context, url, error) => CachedNetworkImage(
                        imageUrl:
                            '${InfixApi.root}public/uploads/staff/demo/staff.jpg',
                        imageBuilder:
                            (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(50),
                                ),
                              ),
                            ),
                        placeholder:
                            (context, url) =>
                                const CupertinoActivityIndicator(),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                ),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              rule == '2'
                  ? showStudentProfileDialog(context)
                  : showOthersProfileDialog(context);
            },
            child: CircleAvatar(
              radius: 22,
              child: Container(
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl: "https://i.imgur.com/7PqjiH7.jpeg",
                  imageBuilder:
                      (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(50),
                          ),
                        ),
                      ),
                  placeholder:
                      (context, url) => const CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<String> getImageUrl(String email, String password, String rule) async {
    var image = 'http://saskolhmg.com/images/studentprofile.png';

    var response = await http.get(Uri.parse(InfixApi.login()));

    if (response.statusCode == 200) {
      Map<String, dynamic> user =
          jsonDecode(response.body) as Map<String, dynamic>;
      if (rule == '2') {
        image = InfixApi.root + user['data']['userDetails']['student_photo'];
      } else if (rule == '3') {
        image = InfixApi.root + user['data']['userDetails']['fathers_photo'];
      } else {
        image = InfixApi.root + user['data']['userDetails']['staff_photo'];
      }
    }
    return image == InfixApi.root
        ? 'http://saskolhmg.com/images/studentprofile.png'
        : image;
  }

  Future<int> getNotificationCount(int id) async {
    var count = 0;
    Map params = {
      'student_id': studentId.toString(),
      'type': role.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    var body = jsonEncode(params);
    final response = await http.post(
      Uri.parse(InfixApi.getMyNotifications(id)),
      headers: Utils.setHeaderNew(_token.toString(), id.toString()),
      body: body,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> notifications =
          jsonDecode(response.body) as Map<String, dynamic>;
      // count = notifications['data']['unread_notification'];
      // count = 120;
    } else {
      // Utils.clearAllValue();
      // Get.offNamedUntil("/", ModalRoute.withName('/'));
      // Utils.showToast("Logged out");
      debugPrint('Error retrieving from api');
      count = 0;
    }
    return count;
  }

  Future<UserNotificationList> getNotifications(int id) async {
    Map params = {
      'student_id': studentId.toString(),
      'type': role.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    var body = jsonEncode(params);
    final response = await http.post(
      Uri.parse(InfixApi.getMyNotifications(id)),
      headers: Utils.setHeaderNew(_token.toString(), id.toString()),
      body: body,
    );
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return UserNotificationList.fromJson(jsonData['data']['notifications']);
    } else {
      throw Exception('failed to load');
    }
  }

  void navigateToPreviousPage(BuildContext context) {
    Navigator.pop(context);
  }

  void sendTokenToServer(String token) async {
    final response = await http.get(
      Uri.parse(InfixApi.setToken(_id ?? "", token)),
      headers: Utils.setHeader(_token),
    );

    if (response.statusCode == 200) {
      debugPrint('token updated : ${response.statusCode}');
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<void> onDidReceiveLocalNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    // display a dialog with the notification details, tap ok to go to another page
    await showDialog(
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: body != null ? Text(body) : null,
            actions: const [],
          ),
    );
  }

  // static Future<void> _showNotification(String title, String body) async {
  //   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //       'infixedu', 'infix', 'this channel description',
  //       importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  //   var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  //   var platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //       0, '$title', '$body', platformChannelSpecifics,
  //       payload: 'infixedu');
  // }
  Future<void> getParentStudents() async {
    Map<String, dynamic> params = {
      "parent_id": _id.toString(),
      'schoolId': schoolId.toString(),
    };
    setState(() {
      studentLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getParentStudentUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('parent students response = ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('parent students jsonData = $jsonData');
        List<dynamic> child = jsonData["childs"];
        List<StudentItem> students =
            child.map((data) => StudentItem.fromJson(data)).toList();
        print('parent students students = $students');
        _displayChildList(context, students);
      } else {}
    } catch (e) {
      print('student fees error  = ${e.toString()}');
    } finally {
      setState(() {
        studentLoading = false;
      });
    }
  }

  Future<void> _displayChildList(
    BuildContext context,
    List<StudentItem> students,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a child'),
          content: SingleChildScrollView(
            child: ListBody(
              children:
                  students.map<Widget>((child) {
                    return ListTile(
                      leading:
                          child.image != null
                              ? Image.network(
                                baseImageUrl ?? child.image ?? '',
                                height: 40,
                                width: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle the image loading error here
                                  return Icon(Icons.person, size: 40);
                                },
                              )
                              : Icon(Icons.person, size: 40),
                      title: Text(
                        child.name ?? "",
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        Utils.saveBooleanValue("isLogged", true);
                        Utils.saveStringValue("full_name", child.name ?? '');
                        Utils.saveStringValue(
                          'className',
                          child.className ?? '',
                        );
                        Utils.saveStringValue(
                          'sectionName',
                          child.section ?? '',
                        );
                        Utils.saveIntValue(
                          'studentId',
                          int.parse(child.id ?? ''),
                        );
                        Utils.saveStringValue('image', child.image ?? '');
                        Navigator.of(context).pop();
                        initValues();
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}
