import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

class StudentAddComplaintScreen extends StatefulWidget {
  const StudentAddComplaintScreen({super.key});

  @override
  _StudentAddComplaintScreenState createState() =>
      _StudentAddComplaintScreenState();
}

class _StudentAddComplaintScreenState extends State<StudentAddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedComplaintType, selectedComplaintSource;
  TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;
  String? _token, _id;
  int _studentId = 0;

  @override
  void initState() {
    Utils.getStringValue('token').then((value) {
      _token = value;
    });
    Utils.getIntValue('studentId').then((value) {
      _studentId = value;
    });
    Utils.getStringValue('id').then((idValue) {
      _id = idValue;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomScreenAppBarWidget(title: 'Add Complaint'),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child:
            isLoading
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(radius: 20),
                      SizedBox(height: 16),
                      Text(
                        'Submitting complaint...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: isSmallScreen ? 16.0 : 24.0,
                    right: isSmallScreen ? 16.0 : 24.0,
                    top: isSmallScreen ? 16.0 : 24.0,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                        (isSmallScreen ? 20.0 : 24.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Section
                        _buildSectionHeader('Complaint Details'),
                        SizedBox(height: 16),

                        // Complaint Type Dropdown
                        _buildComplaintTypeDropdown(),

                        SizedBox(height: 20),

                        // Description Section
                        _buildSectionHeader('Description'),
                        SizedBox(height: 8),
                        _buildDescriptionField(),

                        SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildComplaintTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedComplaintType,
        decoration: InputDecoration(
          labelText: "Complaint Type",
          hintText: "Choose complaint type",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(
            Icons.report_problem_outlined,
            color:
                selectedComplaintType != null ? Colors.blue : Colors.grey[400],
            size: 20,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.grey[600],
          size: 24,
        ),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        items:
            Utils.getComplaintType().map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 100,
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              );
            }).toList(),
        onChanged: (value) {
          setState(() {
            selectedComplaintType = value;
          });
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please select a complaint type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: TextFormField(
        controller: descriptionController,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: 'Please describe your complaint in detail...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: EdgeInsets.only(top: 12, left: 12, right: 8),
            child: Icon(
              Icons.description_outlined,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
        ),
        style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please provide a description for your complaint';
          }
          if (value.trim().length < 10) {
            return 'Description should be at least 10 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed:
            isLoading
                ? null
                : () {
                  if (_formKey.currentState?.validate() ?? false) {
                    addComplaintFromApi();
                  }
                },
        icon:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Icon(Icons.send, size: 20),
        label: Text(
          isLoading ? 'Submitting...' : 'Submit Complaint',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> addComplaintFromApi() async {
    setState(() {
      isLoading = true;
    });
    Map params = {
      'user_id': _studentId.toString(),
      'complaint_type': selectedComplaintType,
      'source': 'PHONE',
      'description': descriptionController.text.trim(),
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getAddComplaintUrl()),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Complaint submitted successfully',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context, true);
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to submit complaint. Please try again!',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error occurred: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
