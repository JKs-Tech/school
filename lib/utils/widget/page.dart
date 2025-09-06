import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/language/language_selection.dart';
import 'package:infixedu/language/translation.dart';
import 'package:infixedu/utils/widget/cc.dart';
import 'package:infixedu/screens/SplashScreen.dart';

import '../../main.dart';
import '../Utils.dart';
import '../error.dart';
import '../theme.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final LanguageController languageController = Get.put(LanguageController());
  final CustomController controller = Get.put(CustomController());
  bool? isRTL;
  bool _isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase if not already initialized
      if (!_isFirebaseInitialized) {
        await Firebase.initializeApp();
        _isFirebaseInitialized = true;
      }

      // Get locale settings
      await Utils.getIntValue('locale').then((value) {
        if (mounted) {
          setState(() {
            isRTL = value == 0 ? true : false;
          });
        }
      });
    } catch (e) {
      print('Error initializing app: $e');
      // Continue with app even if Firebase fails
      if (mounted) {
        setState(() {
          isRTL = false; // Default to LTR
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, child) {
          return Obx(() {
            if (controller.isLoading.value) {
              return GetMaterialApp(
                builder: EasyLoading.init(),
                debugShowCheckedModeBanner: false,
                home: const Scaffold(
                  body: Center(child: CupertinoActivityIndicator()),
                ),
              );
            } else {
              if (controller.connected.value) {
                return isRTL != null
                    ? GetMaterialApp(
                      title: AppConfig.appName,
                      debugShowCheckedModeBanner: false,
                      theme: basicTheme(),
                      locale:
                          langValue
                              ? Get.deviceLocale
                              : Locale(LanguageSelection.instance.val),
                      translations: LanguageController(),
                      fallbackLocale: const Locale('en_US'),
                      builder: EasyLoading.init(),
                      home:
                          _isFirebaseInitialized
                              ? Scaffold(body: Splash())
                              : FutureBuilder(
                                future: _initializeApp(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Scaffold(
                                      body: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error,
                                              size: 64,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Initialization Error: ${snapshot.error}',
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isFirebaseInitialized =
                                                      false;
                                                });
                                                _initializeApp();
                                              },
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return Scaffold(body: Splash());
                                  }
                                  return const Scaffold(
                                    body: Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  );
                                },
                              ),
                    )
                    : const GetMaterialApp(
                      home: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Center(child: CupertinoActivityIndicator()),
                      ),
                    );
              } else {
                return GetMaterialApp(
                  builder: EasyLoading.init(),
                  locale:
                      langValue
                          ? Get.deviceLocale
                          : Locale(LanguageSelection.instance.val),
                  translations: LanguageController(),
                  fallbackLocale: const Locale('en_US'),
                  debugShowCheckedModeBanner: false,
                  home: ErrorPage(),
                );
              }
            }
          });
        },
      ),
    );
  }
}
