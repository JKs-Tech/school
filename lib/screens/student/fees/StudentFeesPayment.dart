// // Dart imports:
// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
// import 'package:infixedu/utils/Utils.dart';
// import 'package:infixedu/utils/apis/Apis.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// // ignore: must_be_immutable
// class StudentFeesPayment extends StatefulWidget {
//   String amount,
//       merchantId,
//       encryptionKey,
//       subMerchantId,
//       studentFeesMasterId,
//       feeGroupsFeeTypeId;

//   StudentFeesPayment({
//     super.key,
//     required this.amount,
//     required this.merchantId,
//     required this.encryptionKey,
//     required this.subMerchantId,
//     required this.studentFeesMasterId,
//     required this.feeGroupsFeeTypeId,
//   });

//   @override
//   _StudentFeesPaymentPageState createState() => _StudentFeesPaymentPageState();
// }

// class _StudentFeesPaymentPageState extends State<StudentFeesPayment> {
//   WebViewController? _webViewController;
//   String currency = "",
//       _token = '',
//       _id = '',
//       userName = '',
//       className = '',
//       url = '';
//   int _studentId = 0;
//   bool isLoading = false;

//   @override
//   void initState() {
//     _initializeData();
//     super.initState();
//   }

//   Future<void> _initializeData() async {
//     _token = await Utils.getStringValue('token');
//     _studentId = await Utils.getIntValue('studentId');
//     currency = await Utils.getStringValue('currency');
//     _id = await Utils.getStringValue('id');
//     userName = await Utils.getStringValue('full_name');
//     className = await Utils.getStringValue('className');
//     createPayment(widget.amount);
//   }

//   Future<void> createPayment(String amount) async {
//     Map<String, dynamic> params = {
//       "student_id": _studentId.toString(),
//       "student_name": userName,
//       "student_roll": _studentId.toString(),
//       "class_name": className,
//       "merchant_id": widget.merchantId,
//       "encryption_key": widget.encryptionKey,
//       "sub_merchant_id": widget.subMerchantId,
//       "amount": amount,
//       "return_url":
//           "https://school.vilsatechnologies.com/students/eazypay/callback",
//       'schoolId': await Utils.getStringValue('schoolId'),
//       "student_fees_master_id": widget.studentFeesMasterId,
//       "fee_groups_feetype_id": widget.feeGroupsFeeTypeId,
//     };
//     setState(() {
//       isLoading = true;
//     });
//     print("create payment params = $params");
//     try {
//       final response = await http.post(
//         Uri.parse(await InfixApi.getApiUrl() + InfixApi.getCreatePaymentUrl()),
//         headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
//         body: json.encode(params),
//       );

//       print('create payment response = ${response.body}');
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         print('create payment jsonData = $jsonData');
//         if (jsonData["status"] == 200) {
//           url = jsonData["data"];
//           print('create payment url = $url');
//         }
//       } else {}
//     } catch (e) {
//       print('student fees error  = ${e.toString()}');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomScreenAppBarWidget(title: 'Fees', isBackIconVisible: true),
//       body: SafeArea(
//         child:
//             isLoading
//                 ? Center(child: CupertinoActivityIndicator())
//                 : url.isNotEmpty
//                 ? Center(
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         'assets/images/no_data.png',
//                         width: 200,
//                         height: 200,
//                       ),
//                       Text('No payment mode available'),
//                     ],
//                   ),
//                 )
//                 : Container(),
//         // : WebView(
//         //   initialUrl: url,
//         //   javascriptMode: JavascriptMode.unrestricted,
//         //   onWebViewCreated: (WebViewController webViewController) {
//         //     _webViewController = webViewController;
//         //   },
//         //   javascriptChannels: <JavascriptChannel>{
//         //     JavascriptChannel(
//         //       name: 'messageHandler',
//         //       onMessageReceived: (JavascriptMessage message) {
//         //         print(
//         //           "Received message from WebView: ${message.message}",
//         //         );
//         //       },
//         //     ),
//         //   },
//         // ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StudentFeesPayment extends StatefulWidget {
  final String amount;
  final String merchantId;
  final String encryptionKey;
  final String subMerchantId;
  final String studentFeesMasterId;
  final String feeGroupsFeeTypeId;

  const StudentFeesPayment({
    Key? key,
    required this.amount,
    required this.merchantId,
    required this.encryptionKey,
    required this.subMerchantId,
    required this.studentFeesMasterId,
    required this.feeGroupsFeeTypeId,
  }) : super(key: key);

  @override
  State<StudentFeesPayment> createState() => _StudentFeesPaymentPageState();
}

class _StudentFeesPaymentPageState extends State<StudentFeesPayment> {
  WebViewController? _controller;
  String? _token, _id, userName, className;
  int? _studentId;
  bool isLoading = false;
  String? url;
  String? currency;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    currency = await Utils.getStringValue('currency');
    _id = await Utils.getStringValue('id');
    userName = await Utils.getStringValue('full_name');
    className = await Utils.getStringValue('className');
    await createPayment(widget.amount);
    if (url != null) {
      _initializeWebViewController();
    }
  }

  void _initializeWebViewController() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (progress) {
                // You can use this for a progress bar if needed
              },
              onPageStarted: (url) {
                debugPrint('Page started: $url');
              },
              onPageFinished: (url) {
                debugPrint('Page finished: $url');
              },
              onHttpError: (error) {
                debugPrint('HTTP error: $error');
              },
              onWebResourceError: (error) {
                debugPrint('Web resource error: $error');
              },
              onNavigationRequest: (request) {
                debugPrint('Navigation request: ${request.url}');
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(url!));
  }

  Future<void> createPayment(String amount) async {
    setState(() {
      isLoading = true;
    });

    final params = {
      "student_id": _studentId.toString(),
      "student_name": userName,
      "student_roll": _studentId.toString(),
      "class_name": className,
      "merchant_id": widget.merchantId,
      "encryption_key": widget.encryptionKey,
      "sub_merchant_id": widget.subMerchantId,
      "amount": amount,
      "return_url":
          "https://school.vilsatechnologies.com/students/eazypay/callback",
      'schoolId': await Utils.getStringValue('schoolId'),
      "student_fees_master_id": widget.studentFeesMasterId,
      "fee_groups_feetype_id": widget.feeGroupsFeeTypeId,
    };

    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getCreatePaymentUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["status"] == 200) {
          url = jsonData["data"];
        }
      }
    } catch (e) {
      debugPrint('Error during payment creation: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Fees', isBackIconVisible: true),
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : url == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      const Text('No payment mode available'),
                    ],
                  ),
                )
                : _controller != null
                ? WebViewWidget(controller: _controller!)
                : const Center(child: Text("WebView loading failed")),
      ),
    );
  }
}
