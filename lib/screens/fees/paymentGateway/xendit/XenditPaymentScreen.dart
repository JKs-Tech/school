// Dart imports:
import 'dart:core';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:

// Project imports:
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/utils/CustomAppBarWidget.dart';
import 'package:infixedu/screens/fees/model/Fee.dart';
import 'package:infixedu/utils/model/PaymentMethod.dart';

class XenditPaymentScreen extends StatefulWidget {
  final Function onFinish;
  final PaymentMethod payment;
  final FeeElement fee;
  final String amount;
  final String redirectUrl;
  final String authenticationId;

  const XenditPaymentScreen({
    super.key,
    required this.onFinish,
    required this.payment,
    required this.fee,
    required this.amount,
    required this.redirectUrl,
    required this.authenticationId,
  });

  @override
  State<StatefulWidget> createState() {
    return XenditPaymentScreenState();
  }
}

class XenditPaymentScreenState extends State<XenditPaymentScreen> {
  String checkoutUrl = '';
  String executeUrl = '';
  String accessToken = '';

  // you can change default currency according to your need
  Map<dynamic, dynamic> defaultCurrency = {
    "symbol": "$paypalCurrency ",
    "decimalDigits": 2,
    "symbolBeforeTheNumber": true,
    "currency": paypalCurrency,
  };

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL = 'cancel.example.com';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Checkout url ${widget.redirectUrl}');

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBarWidget(title: "Xendit Payment"),
        backgroundColor: Colors.white,
        body: Container(),
        //  WebView(
        //   initialUrl: widget.redirectUrl,
        //   javascriptMode: JavascriptMode.unrestricted,
        //   userAgent: 'Flutter;Webview',
        //   navigationDelegate: (NavigationRequest request) {
        //     print(request.url);
        //     if (request.url ==
        //         "https://redirect.xendit.co/callbacks/authentications/cybs/bundled/${widget.authenticationId}?api_key=$xenditPublicKey") {
        //       print('matched');
        //       Future.delayed(const Duration(seconds: 3), () {
        //         widget.onFinish(widget.authenticationId);
        //         Navigator.of(context).pop();
        //       });
        //     }
        //     return NavigationDecision.navigate;
        //   },
        // ),
      ),
    );
  }
}
