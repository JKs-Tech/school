import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/studentChat/ChatScreen.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:localstorage/localstorage.dart';

import 'ChatUserData.dart';

// ignore: must_be_immutable
class ChatTeacherList extends StatefulWidget {
  bool isBackIconVisible;

  ChatTeacherList({super.key, required this.isBackIconVisible});

  @override
  _ChatTeacherListState createState() => _ChatTeacherListState();
}

class _ChatTeacherListState extends State<ChatTeacherList> {
  List<ChatUserData> userList = [];
  bool isLoading = false;
  String? _token, _id;
  int? _studentId;
  final EmojiParser emojiParser = EmojiParser();
  LocalStorage? storage;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    // storage = LocalStorage('studentData.json');
    // if (await storage.ready) {
    cacheData();
    // }
  }

  Future<void> cacheData() async {
    var teacherList = storage?.getItem('teacherList');
    print('=== CACHE DATA ===');
    print('teacherList = $teacherList');
    if (teacherList != null) {
      for (Map<String, dynamic> item
          in teacherList as List<Map<String, dynamic>>) {
        print('teacherList item = $item');
        userList.add(ChatUserData.fromJson(item));
      }
      setState(() {
        isLoading = false;
      });
    }
    if (await Utils.isConnectedToInternet()) {
      fetchData();
    } else {
      Fluttertoast.showToast(msg: 'Please connect to the internet and retry');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> params = {
      'student_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('=== FETCH TEACHER LIST API ===');
    print(
      'URL: ${await InfixApi.getApiUrl() + InfixApi.getStudentTeacherListUrl()}',
    );
    print('Params: $params');

    try {
      final response = await http.post(
        Uri.parse(
          await InfixApi.getApiUrl() + InfixApi.getStudentTeacherListUrl(),
        ),
        headers: Utils.setHeaderNew(_token ?? "", _id ?? ''),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await processListData(jsonData);
        await saveToStorage();
      }
    } catch (e) {
      print('=== ERROR ===');
      print('chat teacher list fetch error = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveToStorage() async {
    List<Map<String, dynamic>> list = [];
    for (ChatUserData chatUserData in userList) {
      list.add(chatUserData.toJson());
    }
    print('=== SAVE TO STORAGE ===');
    print('saveToStorage json = $list');
    storage?.setItem('teacherList', jsonEncode(list));
  }

  Future<void> processListData(var jsonData) async {
    final dataObject = jsonData['result_list'];
    dataObject.forEach((key, value) {
      ChatUserData newChatUserData = ChatUserData.fromJson(value);
      int index = userList.indexWhere(
        (item) => item.staffId == newChatUserData.staffId,
      );
      if (index != -1) {
        newChatUserData.lastMsg = userList[index].lastMsg;
        newChatUserData.lastMsgCreatedAt = userList[index].lastMsgCreatedAt;
        newChatUserData.unreadCount = userList[index].unreadCount;
        newChatUserData.chatConnectionId = userList[index].chatConnectionId;
        userList[index] = newChatUserData;
      } else {
        userList.add(newChatUserData);
      }
    });
    await fetchChatUsersData();
  }

  Future<void> fetchChatUsersData() async {
    Map<String, dynamic> params = {
      'user_id': _studentId.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('=== FETCH CHAT USERS DATA API ===');
    print(
      'URL: ${await InfixApi.getApiUrl() + InfixApi.studentchatusersUrl()}',
    );
    print('Params: $params');

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.studentchatusersUrl()),
        headers: Utils.setHeaderNew(_token ?? "", _id ?? ''),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> object = json.decode(response.body);
        if (object['chat_id'] != null) {
          Utils.saveStringValue('studentChatId', object['chat_id']);
          List<dynamic> chatUserList = object['userList'];
          for (int i = 0; i < chatUserList.length; i++) {
            Map<String, dynamic> userObject = chatUserList[i];
            String staffId = userObject['staff_id'];
            for (int j = 0; j < userList.length; j++) {
              ChatUserData chatUserData = userList[j];
              if (chatUserData.staffId == staffId) {
                chatUserData.chatConnectionId = userObject['connection_id'];
                break;
              }
            }
          }
        }
      }
    } catch (e) {
      print('=== ERROR ===');
      print('fetch user chat data error = ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      appBar: CustomScreenAppBarWidget(
        title: 'Chat',
        isBackIconVisible: widget.isBackIconVisible,
        rightWidget: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              fetchData();
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                CupertinoIcons.refresh,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? _buildLoadingState()
                : userList.isEmpty
                ? _buildEmptyState()
                : _buildTeacherList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoActivityIndicator(radius: 20),
          SizedBox(height: 16),
          Text(
            'Loading teachers...',
            style: TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                CupertinoIcons.chat_bubble_2,
                size: 60,
                color: CupertinoColors.systemBlue,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No Teachers Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No teachers are available for chat at the moment',
              style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: userList.length,
      separatorBuilder: (context, index) => SizedBox(height: 1),
      itemBuilder: (context, index) {
        final userData = userList[index];
        final userName =
            userData.staffSurname?.isNotEmpty ?? false
                ? "${userData.staffName} ${userData.staffSurname}"
                : userData.staffName;

        return _buildTeacherCard(context, userData, userName);
      },
    );
  }

  Widget _buildTeacherCard(
    BuildContext context,
    ChatUserData userData,
    String? userName,
  ) {
    final hasLastMessage = userData.lastMsg?.isNotEmpty ?? false;
    final hasUnreadMessages = (userData.unreadCount ?? 0) > 0;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          _navigateToChatActivity(context, userData);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  hasUnreadMessages
                      ? CupertinoColors.systemBlue.withOpacity(0.3)
                      : CupertinoColors.separator,
              width: hasUnreadMessages ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(userData),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            userName ?? 'Unknown Teacher',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.label,
                            ),
                          ),
                        ),
                        if ((userData.lastMsgCreatedAt ?? 0) > 0)
                          Text(
                            Utils.getTimeFormat(
                              context,
                              userData.lastMsgCreatedAt ?? 0,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hasLastMessage
                                ? emojiParser.unemojify(userData.lastMsg ?? '')
                                : "No messages yet",
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  hasLastMessage
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey2,
                              fontWeight:
                                  hasUnreadMessages
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnreadMessages) ...[
                          SizedBox(width: 8),
                          _buildUnreadBadge(userData.unreadCount!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: CupertinoColors.systemGrey3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatUserData userData) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: CupertinoColors.systemBlue.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          'assets/images/ic_teacher.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              child: Icon(
                CupertinoIcons.person_fill,
                color: CupertinoColors.systemBlue,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnreadBadge(int unreadCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: BoxConstraints(minWidth: 24, minHeight: 24),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Future<void> _navigateToChatActivity(
    BuildContext context,
    ChatUserData userData,
  ) async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatScreen(userData),
        fullscreenDialog: false,
      ),
    );
    userList.sort(
      (a, b) => (b.lastMsgCreatedAt ?? 0).compareTo(a.lastMsgCreatedAt ?? 0),
    );
    saveToStorage();
    print('=== NAVIGATION RESULT ===');
    print('result = $result');
  }
}
