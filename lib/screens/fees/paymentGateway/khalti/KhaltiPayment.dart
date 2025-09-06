// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';

class KhaltiPayment extends StatefulWidget {
  final String checkoutUrl;
  final Function onFinish;

  const KhaltiPayment({
    super.key,
    required this.checkoutUrl,
    required this.onFinish,
  });

  @override
  State<StatefulWidget> createState() {
    return KhaltiPaymentState();
  }
}

class KhaltiPaymentState extends State<KhaltiPayment> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl = '';
  String executeUrl = '';
  String accessToken = '';

  String returnURL = AppConfig.domainName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Checkout url ${widget.checkoutUrl}');

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWidget(title: "Khalti Payment"),
        backgroundColor: Colors.white,
        body: Container(),
        //  WebView(
        //   initialUrl: widget.checkoutUrl,
        //   javascriptMode: JavascriptMode.unrestricted,
        //   navigationDelegate: (NavigationRequest request) {
        //     print(request.url);
        //     if (request.url.contains(returnURL)) {
        //       final uri = Uri.parse(request.url);
        //       final status = uri.queryParameters['status'];
        //       final idx = uri.queryParameters['idx'];
        //       print("Status => $status");
        //       print("txn => $idx");
        //       if (status == "200") {
        //         Map data = {'id': idx, 'status': status};
        //         widget.onFinish(data);
        //       }
        //     }
        //     return NavigationDecision.navigate;
        //   },
        // ),
      ),
    );
  }
}
