import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/config/app_config.dart';
import 'package:infixedu/controller/system_controller.dart';
import 'package:infixedu/utils/FunctinsData.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/server/LoginService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController schoolIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? user, email, schoolId;
  Future<String>? futureEmail;
  String password = '', appLogo = '';
  bool isResponse = false;
  bool obscurePass = true;

  @override
  void initState() {
    super.initState();
    Utils.getStringValue('appLogo').then((value) {
      appLogo = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.titleLarge ?? TextStyle();

    return WillPopScope(
      onWillPop: () async => !(Navigator.of(context).userGestureInProgress),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppConfig.loginBackground),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          height: 250.0,
                          width: 250.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(AppConfig.appLogo),
                              // appLogo.isEmpty
                              //     ? CachedNetworkImageProvider(
                              //       '$appLogo?${Random().nextInt(11)}',
                              //     )
                              //     : AssetImage(AppConfig.appLogo),
                            ),
                          ),
                        ),
                        Text(
                          AppConfig.appName,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // title of the app name
                SizedBox(height: 10.h),
                AppConfig.isDemo
                    ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0.h),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                user = '';
                                futureEmail = getEmail(user ?? '');
                                futureEmail?.then((value) {
                                  setState(() {
                                    email = value;
                                    emailController.text = email ?? "";
                                    passwordController.text = password;
                                  });
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Student",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          // Expanded(
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       setState(() {
                          //         user = 'admin';
                          //         futureEmail = getEmail(user);
                          //         futureEmail.then((value) {
                          //           setState(() {
                          //             email = value;
                          //             emailController.text = email;
                          //             passwordController.text = password;
                          //           });
                          //         });
                          //       });
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.purpleAccent,
                          //         shape: const RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.all(
                          //             Radius.circular(0.0),
                          //           ),
                          //         )),
                          //     child: Text("Admin",
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .headlineMedium
                          //             .copyWith(color: Colors.white)),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: ElevatedButton(
                          //     onPressed: () {
                          //       user = 'parent';
                          //       futureEmail = getEmail(user);
                          //       futureEmail.then((value) {
                          //         setState(() {
                          //           email = value;
                          //           emailController.text = email;
                          //           passwordController.text = password;
                          //         });
                          //       });
                          //     },
                          //     style: ElevatedButton.styleFrom(
                          //         backgroundColor: Colors.purpleAccent,
                          //         shape: const RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.only(
                          //             topRight: Radius.circular(8.0),
                          //             bottomRight: Radius.circular(8.0),
                          //           ),
                          //         )),
                          //     child: Text("Parents",
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .headlineMedium
                          //             .copyWith(color: Colors.white)),
                          //   ),
                          // ),
                        ],
                      ),
                    )
                    : Container(),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.h, 10.h, 10.h, 0),
                  child: TextFormField(
                    style: textStyle,
                    controller: schoolIdController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Please enter a valid code';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Code".tr,
                      labelText: "Code".tr,
                      labelStyle: textStyle,
                      errorStyle: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      suffixIcon: const Icon(
                        Icons.school,
                        size: 24,
                        color: Color.fromRGBO(142, 153, 183, 0.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.h, 10.h, 10.h, 0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    style: textStyle,
                    controller: emailController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Please enter a valid username';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Username".tr,
                      labelText: "Username".tr,
                      labelStyle: textStyle,
                      errorStyle: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      suffixIcon: const Icon(
                        Icons.person,
                        size: 24,
                        color: Color.fromRGBO(142, 153, 183, 0.5),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(10.h, 10.h, 10.h, 0),
                  child: TextFormField(
                    obscureText: obscurePass,
                    keyboardType: TextInputType.visiblePassword,
                    style: textStyle,
                    controller: passwordController,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value?.isEmpty ?? false) {
                        return 'Please enter a valid password';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Password".tr,
                      labelText: "Password".tr,
                      labelStyle: textStyle,
                      errorStyle: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 15.0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      suffixIcon: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                        child: Icon(
                          obscurePass ? Icons.lock_rounded : Icons.lock_open,
                          size: 24,
                          color: const Color.fromRGBO(142, 153, 183, 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(10.0.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  decoration: Utils.gradientBtnDecoration,
                  child: Text(
                    "Login".tr,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                ),
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    String email = emailController.text;
                    String password = passwordController.text;
                    schoolId = schoolIdController.text;

                    if (email.isNotEmpty && password.isNotEmpty) {
                      setState(() {
                        isResponse = true;
                      });
                      Login(
                        email,
                        password,
                        schoolId ?? "",
                      ).getLogin(context).then((result) {
                        if (result != null) {
                          getLoginDetails(response: result);
                        } else {
                          setState(() {
                            isResponse = false;
                          });
                          Utils.showToast('invalid email and password');
                        }
                      });
                    } else {
                      setState(() {
                        isResponse = false;
                      });
                      Utils.showToast('invalid email and password');
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    isResponse == true
                        ? const LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                        )
                        : const Text(''),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    const url =
                        'https://school.eduacademy.in/privacy-policy/'; // Replace with your privacy policy URL
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    "Privacy Policy",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.blue,
                    ), // Change the text color to indicate it's clickable
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getLoginDetails({required http.Response response}) async {
    bool isSuccess = false;
    dynamic user;
    String message = "Error, Try again!";

    try {
      if (response.statusCode == 200) {
        user = jsonDecode(response.body);
        isSuccess = user['status'] == 200;
        message = user['message'];

        if (isSuccess) {
          String role = user['role'];
          if (role == 'parent') {
            var parentChild = user['record']['parent_childs'];
            if (parentChild.length == 1) {
              saveBooleanValue("hasMultipleChild", false);
              setSuccessState(user, parentChild[0]);
            } else {
              saveBooleanValue("hasMultipleChild", true);
              _displayChildList(context, user, parentChild);
            }
          } else if (role == 'student') {
            setSuccessState(user, user['record']);
          }
        }
      }
    } catch (e, t) {
      debugPrint(e.toString());
      debugPrint(t.toString());
    }
    Utils.showToast(message);
    setState(() {
      isResponse = false;
    });
  }

  void setSuccessState(dynamic user, dynamic child) async {
    String studentId = child['student_id'].toString();
    String fullName = child['username'] ?? child['name'] ?? "";
    String phone = child['phone_number'] ?? "";
    String image = child['image'] ?? "";
    String className = child['class'] ?? "";
    String sectionName = child['section'] ?? "";

    saveBooleanValue('isLogged', true);
    saveStringValue('email', email ?? "");
    saveStringValue('phone', phone);
    saveStringValue('full_name', fullName);
    saveStringValue('password', password);
    saveStringValue('id', user['record']['id'].toString());
    saveStringValue('rule', '2'); // Update with correct rule value
    saveStringValue('schoolId', schoolId ?? "");
    saveStringValue('image', image);
    saveStringValue('isAdministrator', 'no'); // Update with correct value
    saveStringValue('lang', 'en');
    saveStringValue('token', user['token'].toString());
    saveStringValue('role', user['role']);
    saveStringValue('className', className);
    saveStringValue('sectionName', sectionName);
    saveStringValue('currency', user['record']['currency_symbol']);
    saveStringValue('schoolName', user['record']['sch_name']);
    saveIntValue('studentId', int.parse(studentId));

    final SystemController systemController = Get.put(SystemController());
    await systemController.getSystemSettings();
    AppFunction.getFunctions(
      context,
      '2',
      false,
    ); // Update with correct rule value
  }

  Future<void> _displayChildList(
    BuildContext context,
    dynamic user,
    List<dynamic> children,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a child'),
          content: SingleChildScrollView(
            child: ListBody(
              children:
                  children.map<Widget>((child) {
                    return ListTile(
                      leading:
                          child['image'] != null
                              ? Image.network(
                                "${AppConfig.domainNameNew}/" + child['image'],
                                height: 40,
                                width: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle the image loading error here
                                  return Icon(Icons.person, size: 40);
                                },
                              )
                              : Icon(Icons.person, size: 40),
                      title: Text(
                        child['name'],
                        style: TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        setSuccessState(user, child);
                        Navigator.of(context).pop();
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<String> getEmail(String user) async {
    return user;
  }

  Future<bool> saveBooleanValue(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setBool(key, value);
  }

  Future<bool> saveStringValue(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString(key, value);
  }

  Future<bool> saveIntValue(String key, int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setInt(key, value);
  }
}
