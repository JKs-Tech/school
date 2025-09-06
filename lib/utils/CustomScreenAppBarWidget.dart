import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infixedu/config/app_config.dart';

class CustomScreenAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  final Function(BuildContext)? onBackPress;
  final List<Widget>? rightWidget;
  final bool? isBackIconVisible;

  const CustomScreenAppBarWidget({
    super.key,
    this.title,
    this.onBackPress,
    this.rightWidget,
    this.isBackIconVisible,
  });

  @override
  _CustomScreenAppBarWidgetState createState() =>
      _CustomScreenAppBarWidgetState();

  @override
  Size get preferredSize => Size.fromHeight(100.h);
}

class _CustomScreenAppBarWidgetState extends State<CustomScreenAppBarWidget> {
  void navigateToPreviousPage(BuildContext context) {
    if (widget.onBackPress != null) {
      // widget.onBackPress!(context);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              padding: EdgeInsets.only(top: 20.h),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppConfig.appToolbarBackground),
                  fit: BoxFit.fill,
                ),
                color: Colors.deepPurple,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (widget.isBackIconVisible != false)
                    Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: 70.h,
                        width: 70.w,
                        child: IconButton(
                          tooltip: 'Back',
                          icon: Icon(
                            Icons.arrow_back,
                            size: ScreenUtil().setSp(20),
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            //Get.back();
                          },
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding:
                          widget.isBackIconVisible != false
                              ? const EdgeInsets.only(left: 0.0)
                              : const EdgeInsets.only(left: 32.0),
                      child: Text(
                        widget.title?.tr ?? '',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 18.sp, color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Row(children: widget.rightWidget ?? []),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          );
        },
      ),
    );
  }
}
