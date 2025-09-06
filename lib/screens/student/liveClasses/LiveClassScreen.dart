import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';

class LiveClassScreen extends StatefulWidget {
  final String joinUrl;

  const LiveClassScreen({super.key, required this.joinUrl});

  @override
  _LiveClassScreenState createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Live Class'),
      body: Container(),

      // WebView(
      //   initialUrl: widget.joinUrl,
      //   javascriptMode: JavascriptMode.unrestricted,
      //   onPageStarted: (url) {
      //     showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (BuildContext context) {
      //         return Center(
      //           child: CupertinoActivityIndicator(),
      //         );
      //       },
      //     );
      //   },
      //   onPageFinished: (url) {
      //     Navigator.of(context, rootNavigator: true).pop();
      //   },
      //   navigationDelegate: (NavigationRequest request) {
      //     if (request.url.startsWith('market:') ||
      //         request.url.startsWith('zoomus:')) {
      //       try {
      //         launchUrl(Uri.parse(request.url));
      //       } catch (e) {
      //         // ScaffoldMessenger.of(context).showSnackBar(
      //         //   SnackBar(content: Text(e.toString())),
      //         // );
      //       }
      //       return NavigationDecision.prevent;
      //     }
      //     return NavigationDecision.navigate;
      //   },
      // ),
    );
  }
}
