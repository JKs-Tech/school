import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/teachers/Teacher.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

typedef RatingAddedCallback = void Function(String staffId, double newRating);

class StudentTeacherNewAdapter extends StatelessWidget {
  final List<Teacher> teacherList;
  final String token, id, role;
  final RatingAddedCallback onRatingAdded;

  const StudentTeacherNewAdapter({
    super.key,
    required this.teacherList,
    required this.token,
    required this.id,
    required this.role,
    required this.onRatingAdded,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: teacherList.length,
      itemBuilder: (context, index) {
        final teacherData = teacherList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 3,
            shadowColor: Colors.grey.withValues(alpha: 0.2),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row with Avatar and Teacher Info
                  Row(
                    children: [
                      Hero(
                        tag: 'teacher_${teacherData.staffId}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.3),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacherData.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            if (teacherData.isClassTeacher)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[400]!,
                                      Colors.green[600]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.school,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Class Teacher',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Contact Information
                  if (teacherData.contact.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.phone,
                              size: 18,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  teacherData.contact,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Add phone call functionality here if needed
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.call,
                                size: 20,
                                color: Colors.green[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 16),

                  // Rating Section - Responsive Layout
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Colors.blue[700],
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Teacher Rating',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            if (teacherData.rating > 0) ...[
                              Expanded(
                                child: Row(
                                  children: [
                                    ...List.generate(5, (starIndex) {
                                      return Icon(
                                        starIndex < teacherData.rating
                                            ? Icons.star_rounded
                                            : Icons.star_outline_rounded,
                                        size: 24,
                                        color:
                                            starIndex < teacherData.rating
                                                ? Colors.orange[600]
                                                : Colors.grey[400],
                                      );
                                    }),
                                    SizedBox(width: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${teacherData.rating}/5',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: Text(
                                  'No rating yet. Be the first to rate!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(width: 12),
                            // Rating Button - Always visible, responsive
                            teacherData.rating == 0
                                ? ElevatedButton.icon(
                                  onPressed:
                                      () => _showAddRatingDialog(
                                        context,
                                        teacherData.staffId,
                                        teacherData.name,
                                      ),
                                  icon: Icon(Icons.star_rounded, size: 18),
                                  label: Text('Rate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[600],
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                )
                                : Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[700],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Rated',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddRatingDialog(
    BuildContext context,
    String staffId,
    String teacherName,
  ) {
    double newRating = 0.0;
    TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              elevation: 10,
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Rate Teacher",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    teacherName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rating Stars
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[100]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tap to Rate',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          RatingBar(
                            onRatingChanged: (rating) {
                              setState(() {
                                newRating = rating;
                              });
                            },
                            initialRating: newRating,
                            filledIcon: Icons.star_rounded,
                            emptyIcon: Icons.star_outline_rounded,
                            halfFilledIcon: Icons.star_half_rounded,
                            isHalfAllowed: true,
                            maxRating: 5,
                            size: 40,
                            filledColor: Colors.orange[600]!,
                            emptyColor: Colors.grey[400]!,
                            halfFilledColor: Colors.orange[400]!,
                          ),
                          if (newRating > 0) ...[
                            SizedBox(height: 8),
                            Text(
                              '${newRating}/5 Stars',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Comment Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Add a comment (optional)",
                          labelStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText:
                              "Share your experience with this teacher...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting
                          ? null
                          : () {
                            Navigator.pop(context);
                          },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      isSubmitting || newRating == 0
                          ? null
                          : () async {
                            setState(() {
                              isSubmitting = true;
                            });
                            await _addRating(
                              staffId,
                              newRating,
                              commentController,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      isSubmitting
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.send, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Submit Rating',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addRating(
    String staffId,
    double newRating,
    TextEditingController commentController,
  ) async {
    String rating = newRating.toString();
    if (rating.isEmpty) {
      Fluttertoast.showToast(
        msg: "Rating Required!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red[600],
        textColor: Colors.white,
      );
    } else {
      Map<String, dynamic> params = {
        "rate": rating,
        "comment": commentController.text,
        "staff_id": staffId,
        "user_id": id.toString(),
        "role": role,
        'schoolId': await Utils.getStringValue('schoolId'),
      };

      print('addrating $params');
      http
          .post(
            Uri.parse(await InfixApi.getApiUrl() + InfixApi.getStaffUrl()),
            headers: Utils.setHeaderNew(token.toString(), id.toString()),
            body: json.encode(params),
          )
          .then((response) {
            print('resposne = ${response.body}');
            if (response.statusCode == 200) {
              Map<String, dynamic> responseData = jsonDecode(response.body);
              String msg = responseData["msg"];
              onRatingAdded(staffId, double.parse(rating));
              Fluttertoast.showToast(
                msg: msg,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green[600],
                textColor: Colors.white,
              );
            } else {
              Fluttertoast.showToast(
                msg: "Failed to add rating.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.red[600],
                textColor: Colors.white,
              );
            }
          })
          .catchError((error) {
            print("Error: $error");
            Fluttertoast.showToast(
              msg: "An error occurred while adding rating.",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red[600],
              textColor: Colors.white,
            );
          });
    }
  }
}

// Enhanced Rating bar widget
class RatingBar extends StatelessWidget {
  final double initialRating;
  final IconData filledIcon;
  final IconData emptyIcon;
  final IconData halfFilledIcon;
  final bool isHalfAllowed;
  final int maxRating;
  final double size;
  final Color filledColor;
  final Color emptyColor;
  final Color halfFilledColor;
  final ValueChanged<double> onRatingChanged;

  const RatingBar({
    super.key,
    required this.initialRating,
    required this.filledIcon,
    required this.emptyIcon,
    required this.halfFilledIcon,
    required this.isHalfAllowed,
    required this.maxRating,
    required this.size,
    required this.filledColor,
    required this.emptyColor,
    required this.halfFilledColor,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        double rating = index + 1.0;
        return GestureDetector(
          onTap: () => onRatingChanged(rating),
          child: Container(
            padding: EdgeInsets.all(4),
            child: Icon(
              rating <= initialRating
                  ? filledIcon
                  : rating - 0.5 <= initialRating
                  ? halfFilledIcon
                  : emptyIcon,
              size: size,
              color:
                  rating <= initialRating
                      ? filledColor
                      : rating - 0.5 <= initialRating
                      ? halfFilledColor
                      : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}
