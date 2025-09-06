import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/studentChat/ChatUserData.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

import 'ChatItem.dart';

class ChatMsgDetails {
  final ChatItem chatItem;
  final int type; // If you have MessageType enum in Dart, use it here.
  final String header;

  ChatMsgDetails({
    required this.chatItem,
    required this.type, // assuming you've defined the MessageType enum in Dart
    required this.header,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is ChatMsgDetails) {
      return chatItem.chatId == other.chatItem.chatId;
    }
    return false;
  }

  @override
  int get hashCode => chatItem.chatId.hashCode;
}

enum MessageType { CHAT_HEADER, CHAT_MSG, CHAT_MSG_ME }

class ChatScreen extends StatefulWidget {
  final ChatUserData chatUserData;

  const ChatScreen(this.chatUserData, {super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool isLoading = true,
      isLoadMoreEnabled = false,
      isSending = false,
      isCurrentDayExists = false;
  String _token = "", _id = '', studentChatId = '', studentName = '';
  int _studentId = 0, offset = 0, limit = 10, fetchedItemCount = 0;
  List<ChatItem> chatMsgList = [];
  List<ChatMsgDetails> chatList = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _refreshTimer;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    initializeData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted && !isLoading) {
        _refreshMessages();
      }
    });
  }

  Future<void> _refreshMessages() async {
    int currentOffset = offset;
    offset = 0;
    await getChatMessage();
    offset = currentOffset;
  }

  Future<void> initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    _id = await Utils.getStringValue('id');
    studentChatId = await Utils.getStringValue('studentChatId');
    studentName = await Utils.getStringValue('full_name');
    if (widget.chatUserData.chatConnectionId?.isEmpty ?? true) {
      addToChat();
    } else {
      getChatMessage();
    }
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          isLoadMoreEnabled) {
        getChatMessage();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void parseMsgList() {
    chatList.clear();
    String dateString = "";
    List<ChatMsgDetails> tempChatList =
        []; // Temporary list to accumulate chat messages
    for (var item in chatMsgList) {
      String msgDate = Utils.getTimeDataFormat(item.createdAt ?? 0);
      if (dateString != "" && dateString != msgDate) {
        // If dateString changes and it's not the first iteration,
        // append accumulated chat messages and then the header to the main chat list
        chatList.addAll(tempChatList);
        var headerMsgDetails = ChatMsgDetails(
          chatItem: item,
          type: MessageType.CHAT_HEADER.index,
          header: dateString,
        );
        chatList.add(headerMsgDetails);
        if (dateString == 'TODAY') {
          isCurrentDayExists = true;
        }
        // Clear the temp list for the new date's messages
        tempChatList.clear();
      }

      dateString = msgDate;

      item.time = Utils.getTimeFormat(context, item.createdAt ?? 0);
      var msgDetails = ChatMsgDetails(
        type:
            (item.sender == _studentId.toString())
                ? MessageType.CHAT_MSG_ME.index
                : MessageType.CHAT_MSG.index,
        chatItem: item,
        header: dateString,
      );
      tempChatList.add(msgDetails); // Add chat item to the temporary list
    }

    // After the loop, append any remaining items and the last header
    if (tempChatList.isNotEmpty) {
      chatList.addAll(tempChatList);
      var headerMsgDetails = ChatMsgDetails(
        chatItem: tempChatList.last.chatItem,
        type: MessageType.CHAT_HEADER.index,
        header: dateString,
      );
      chatList.add(headerMsgDetails);
      if (dateString == 'TODAY') {
        isCurrentDayExists = true;
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Navigator.pop(context, widget.chatUserData);
    Get.back(result: widget.chatUserData);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      //: _onWillPop,
      onPopInvokedWithResult: (didPop, result) {
        _onWillPop();
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.chatUserData.staffName ?? 'Chat',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              offset = 0;
              getChatMessage();
            },
            child: Icon(
              CupertinoIcons.refresh,
              size: 20,
              color: CupertinoColors.systemBlue,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child:
                    isLoading
                        ? _buildLoadingState()
                        : (chatList.isEmpty)
                        ? _buildEmptyState()
                        : _buildChatList(),
              ),
              _buildInputSection(),
            ],
          ),
        ),
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
            'Loading messages...',
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
              'Start Conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send your first message to ${widget.chatUserData.staffName}',
              style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatList.length,
      itemBuilder: (context, index) {
        print('=== CHAT LIST ITEM ===');
        print('chatList[index] = ${chatList[index]}');
        print('chatList[index].type = ${chatList[index].type}');
        print('chatList[index].header = ${chatList[index].header}');
        print('chatList[index].chatItem = ${chatList[index].chatItem}');
        print('chatList[index].chatItem.msg = ${chatList[index].chatItem.msg}');
        print(
          'chatList[index].chatItem.time = ${chatList[index].chatItem.time}',
        );
        print(
          'chatList[index].chatItem.createdAt = ${chatList[index].chatItem.createdAt}',
        );
        print(
          'chatList[index].chatItem.isSent = ${chatList[index].chatItem.isSent}',
        );
        print(
          'chatList[index].chatItem.image = ${chatList[index].chatItem.image}',
        );

        final item = chatList[index];
        if (item.type == MessageType.CHAT_MSG_ME.index) {
          return _buildMyChatItem(item);
        } else if (item.type == MessageType.CHAT_MSG.index) {
          return _buildOtherChatItem(item);
        } else {
          return _buildDateHeader(item);
        }
      },
    );
  }

  Widget _buildInputSection() {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, isKeyboardVisible ? 8 : 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            border: Border(
              top: BorderSide(color: CupertinoColors.separator, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 0.5,
                      ),
                    ),
                    child: CupertinoTextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: null,
                      minLines: 1,
                      maxLength: 1000,
                      placeholder: 'Message',
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                      style: TextStyle(fontSize: 16),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: null,
                      onSubmitted: (value) {
                        if (!isSending) onSubmitButtonClicked();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed:
                        isSending
                            ? null
                            : () {
                              if (!isSending) onSubmitButtonClicked();
                            },
                    color:
                        isSending
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(20),
                    child:
                        isSending
                            ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CupertinoActivityIndicator(
                                radius: 8,
                                color: CupertinoColors.white,
                              ),
                            )
                            : Icon(
                              CupertinoIcons.arrow_up,
                              size: 18,
                              color: CupertinoColors.white,
                            ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyChatItem(ChatMsgDetails chatMsgDetails) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, left: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatMsgDetails.chatItem.isSent ?? false)
            Container(
              margin: EdgeInsets.only(right: 8, bottom: 4),
              child: Icon(
                CupertinoIcons.check_mark_circled_solid,
                color: CupertinoColors.systemBlue,
                size: 16,
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(right: 8, bottom: 4),
              width: 16,
              height: 16,
              child: CupertinoActivityIndicator(radius: 8),
            ),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Html(
                    data: chatMsgDetails.chatItem.msg ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: CupertinoColors.white,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    chatMsgDetails.chatItem.time ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherChatItem(ChatMsgDetails chatMsgDetails) {
    return Container(
      margin: EdgeInsets.only(bottom: 8, right: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              CupertinoIcons.person_fill,
              color: CupertinoColors.systemBlue,
              size: 18,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: CupertinoColors.separator,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    data: chatMsgDetails.chatItem.msg ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        color: CupertinoColors.label,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    chatMsgDetails.chatItem.time ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(ChatMsgDetails chatMsgDetails) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            chatMsgDetails.header,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addToChat() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> params = {
      'user_id': _studentId.toString(),
      'staff_id': widget.chatUserData.staffId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('=== ADD TO CHAT API ===');
    print(
      'URL: ${await InfixApi.getApiUrl() + InfixApi.addTeacherToChatUrl()}',
    );
    print('Params: $params');

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.addTeacherToChatUrl()),
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> object = json.decode(response.body);
        Map<String, dynamic> data = object['data'];
        widget.chatUserData.chatConnectionId = data['connection_id'];
        await fetchChatUsersData();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load data')),
        // );
      }
    } catch (e) {
      print('=== ERROR ===');
      print('addToChat error = ${e.toString()}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString())),
      // );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> object = json.decode(response.body);
        if (object['chat_id'] != null) {
          Utils.saveStringValue('studentChatId', object['chat_id']);
          studentChatId = object['chat_id'];
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load data')),
        // );
      }
    } catch (e) {
      print('=== ERROR ===');
      print('fetchChatUsersData error = ${e.toString()}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString())),
      // );
    }
  }

  Future<void> getChatMessage() async {
    Map<String, dynamic> params = {
      'chat_connection_id': widget.chatUserData.chatConnectionId,
      'limit': limit.toString(),
      'offset': offset.toString(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('=== GET CHAT MESSAGE API ===');
    print('URL: ${await InfixApi.getApiUrl() + InfixApi.getChatMessageUrl()}');
    print('Params: $params');
    print('studentChatId: $studentChatId');
    print('_studentId: $_studentId');
    print('widget.chatUserData.staffId: ${widget.chatUserData.staffId}');

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getChatMessageUrl()),
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> chatListResponse = json.decode(response.body);
        if (chatListResponse.isNotEmpty) {
          List<ChatItem> msgList = [];
          for (var object in chatListResponse) {
            ChatItem chatItem = ChatItem();
            chatItem.chatId = object["id"].toString();
            chatItem.msg = object["message"];
            chatItem.createdAt = Utils.getTimeMSFormat(object["created_at"]);

            // Debug: Print all fields in the object
            print('=== MESSAGE OBJECT DEBUG ===');
            print('id: ${object["id"]}');
            print('message: ${object["message"]}');
            print('chat_user_id: ${object["chat_user_id"]}');
            print('created_at: ${object["created_at"]}');

            // Check for sender identification
            String chatUserId = object["chat_user_id"].toString();
            print(
              'Processing message - chatUserId: $chatUserId, studentChatId: $studentChatId',
            );

            // BACKEND ISSUE: The API response is missing sender identification
            // All messages have chat_user_id: "3" which doesn't help identify sender
            //
            // REQUIRED BACKEND FIX: Add one of these fields to the API response:
            // Option 1: "sender_id": "40" (ID of who sent the message)
            // Option 2: "is_from_student": false (boolean)
            // Option 3: "sender_type": "teacher" (string)
            //
            // Current workaround: Using chat_user_id comparison (not reliable)
            if (chatUserId == studentChatId) {
              // This message was sent TO the student (FROM the teacher)
              chatItem.sender = widget.chatUserData.staffId;
              chatItem.receiver = _studentId.toString();
              chatItem.type = "other";
              chatItem.name = widget.chatUserData.staffName;
              print('Message FROM TEACHER TO STUDENT: ${chatItem.msg}');
            } else {
              // This message was sent TO the teacher (FROM the student)
              chatItem.sender = _studentId.toString();
              chatItem.receiver = widget.chatUserData.staffId;
              chatItem.type = "me";
              chatItem.name = studentName;
              print('Message FROM STUDENT TO TEACHER: ${chatItem.msg}');
            }
            chatItem.isSent = true;
            msgList.add(chatItem);
          }
          if (offset == 0) {
            chatMsgList.clear();
          } else {
            fetchedItemCount = chatMsgList.length;
          }
          isLoadMoreEnabled = (msgList.length >= limit);
          chatMsgList.addAll(msgList);
          offset = chatMsgList.length;
          parseMsgList();
        } else {
          isLoadMoreEnabled = false;
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load data')),
        // );
      }
    } catch (e) {
      print('=== ERROR ===');
      print("Error in getChatMessage: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString())),
      // );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void onSubmitButtonClicked() {
    String msg = _messageController.text.trim();
    if (msg.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Empty Message'),
            content: Text('Message cannot be empty'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      sendNotification(msg);
    }
  }

  void sendNotification(String msg) {
    String chatId = "${DateTime.now().millisecondsSinceEpoch}_$studentChatId";
    setState(() {
      isSending = true;
    });

    try {
      ChatItem chatItem = ChatItem(
        msg: msg,
        chatId: chatId,
        name: studentName, // Assumes you have a similar method in Flutter
        type: "me",
        sender: _studentId.toString(),
        receiver:
            widget
                .chatUserData
                .staffId, // Assuming `staff_id` is `staffId` in Dart
        time: Utils.getGMTFromLocal(DateTime.now().millisecondsSinceEpoch),
        image: "",
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isSent: false,
        imageMsg: null,
      );

      ChatMsgDetails chatMsgDetails = ChatMsgDetails(
        header: Utils.getTimeDataFormat(chatItem.createdAt ?? 0),
        type: MessageType.CHAT_MSG_ME.index,
        chatItem: chatItem,
      );

      chatItem.time = Utils.getTimeFormat(context, chatItem.createdAt ?? 0);
      if (!isCurrentDayExists) {
        var headerMsgDetails = ChatMsgDetails(
          chatItem: chatItem,
          type: MessageType.CHAT_HEADER.index,
          header: 'TODAY',
        );
        chatList.insert(0, headerMsgDetails);
      }
      isCurrentDayExists = true;
      chatList.insert(0, chatMsgDetails);
      _messageController.text = "";
      _focusNode.unfocus();
      setState(() {});

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      saveChatMessage(chatMsgDetails);
    } catch (e) {
      print('=== ERROR ===');
      print('sendNotification error = ${e.toString()}');
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> saveChatMessage(ChatMsgDetails chatMsgDetails) async {
    Map<String, dynamic> params = {
      'chat_connection_id': widget.chatUserData.chatConnectionId,
      'message': chatMsgDetails.chatItem.msg,
      'chat_to_user': studentChatId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };

    print('=== SAVE CHAT MESSAGE API ===');
    print('URL: ${await InfixApi.getApiUrl() + InfixApi.newMessageUrl()}');
    print('Params: $params');

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.newMessageUrl()),
        headers: Utils.setHeaderNew(_token, _id),
        body: json.encode(params),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final object = json.decode(response.body);
        chatMsgDetails.chatItem.isSent = true;
        chatMsgDetails.chatItem.chatId = object['last_insert_id'].toString();

        // Update the message in the list
        int index = chatList.indexWhere(
          (item) => item.chatItem.chatId == chatMsgDetails.chatItem.chatId,
        );
        if (index != -1) {
          chatList[index] = chatMsgDetails;
        }

        widget.chatUserData.lastMsg = chatMsgDetails.chatItem.msg ?? '';
        widget.chatUserData.lastMsgCreatedAt =
            chatMsgDetails.chatItem.createdAt ?? 0;

        setState(() {});
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to send message')),
        // );
      }
    } catch (e) {
      print('=== ERROR ===');
      print("Error in saveChatMessage: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString())),
      // );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }
}
