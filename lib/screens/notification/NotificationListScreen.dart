import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/localdb/DatabaseHelper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late DatabaseHelper dbHelper;
  Future<List<Map<String, dynamic>>>? notifications;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    notifications = dbHelper.getNotifications();
    dbHelper.updateAllMessageRead();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    cancelAllNotifications();
  }

  void cancelAllNotifications() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          } else {
            return '${difference.inMinutes}m ago';
          }
        } else {
          return '${difference.inHours}h ago';
        }
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(
        title: 'Notifications',
        isBackIconVisible: true,
      ),
      body: FutureBuilder(
        future: notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading notifications...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          } else {
            List<Map<String, dynamic>> notifications = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  this.notifications = dbHelper.getNotifications();
                });
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isUnread = notification['read'] == 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      elevation: isUnread ? 4 : 2,
                      shadowColor:
                          isUnread
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.2),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.notifications,
                                        color: Colors.blue[700],
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Notification Details',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Title',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[600],
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            notification['title'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Message',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          notification['body'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey[800],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 16,
                                          color: Colors.grey[500],
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          _formatDate(notification['date']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border:
                                isUnread
                                    ? Border.all(
                                      color: Colors.blue.withValues(alpha: 0.3),
                                      width: 1,
                                    )
                                    : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          isUnread
                                              ? Colors.blue[50]
                                              : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.notifications,
                                      color:
                                          isUnread
                                              ? Colors.blue[700]
                                              : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification['title'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      isUnread
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                  color: Colors.grey[800],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[600],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          notification['body'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule,
                                                  size: 14,
                                                  color: Colors.grey[500],
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  _formatDate(
                                                    notification['date'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (isUnread)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[600],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  'NEW',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                          ],
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
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
