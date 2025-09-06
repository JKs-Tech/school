// Dart imports:
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infixedu/screens/student/fees/DiscountItem.dart';
import 'package:infixedu/screens/student/fees/FeeItemBase.dart';
import 'package:infixedu/screens/student/fees/FeesDetailsData.dart';
import 'package:infixedu/screens/student/fees/FeesItem.dart';
import 'package:infixedu/screens/student/fees/StudentFeesPayment.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:infixedu/utils/Utils.dart';
import 'package:infixedu/utils/apis/Apis.dart';

// ignore: must_be_immutable
class StudentFees extends StatefulWidget {
  bool isBackIconVisible;
  StudentFees({super.key, required this.isBackIconVisible});
  @override
  _StudentFeesPageState createState() => _StudentFeesPageState();
}

class _StudentFeesPageState extends State<StudentFees> {
  int payMethod = 0;
  List<FeesItem> feesList = [];
  List<DiscountItem> discountList = [];
  List<FeeItemBase> combinedList = [];

  String gtAmt = '';
  String gtDiscount = '';
  String gtFine = '';
  String gtPaid = '';
  String gtBalance = '';

  String currency = "", _token = '', _id = '';
  int _studentId = 0;
  bool isLoading = false;

  Map<String, dynamic> eazypay = {};

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    _token = await Utils.getStringValue('token');
    _studentId = await Utils.getIntValue('studentId');
    currency = await Utils.getStringValue('currency');
    _id = await Utils.getStringValue('id');
    loadData();
  }

  Future<void> loadData() async {
    Map<String, dynamic> params = {
      "student_id": _studentId,
      'schoolId': await Utils.getStringValue('schoolId'),
    };
    setState(() {
      isLoading = true;
    });
    combinedList.clear();
    try {
      final response = await http.post(
        Uri.parse(await InfixApi.getApiUrl() + InfixApi.getFeesUrl(_id)),
        headers: Utils.setHeaderNew(_token.toString(), _id.toString()),
        body: json.encode(params),
      );

      print('fees response = ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        payMethod = jsonData['pay_method'];
        eazypay = jsonData['eazypay'];

        print('eazypay = $eazypay');
        final grandTotalDetails = jsonData['grand_fee'];
        gtAmt = grandTotalDetails['amount'];
        gtDiscount = grandTotalDetails['amount_discount'];
        gtFine = grandTotalDetails['amount_fine'];
        gtPaid = grandTotalDetails['amount_paid'];
        gtBalance = grandTotalDetails['amount_remaining'];
        final dataArray = jsonData['student_due_fee'];
        for (final data in dataArray) {
          final feesArray = data['fees'];
          print('feesArray = ${feesArray.toString()}');
          for (final fees in feesArray) {
            final feesItem = FeesItem.fromJson(fees, currency);
            combinedList.add(feesItem);
          }
        }
        final discountArray = jsonData['student_discount_fee'];
        print('feesArray = ${discountArray.toString()}');
        for (final discount in discountArray) {
          final discountItem = DiscountItem.fromJson(discount, currency);
          combinedList.add(discountItem);
        }

        print('combinedList = ${combinedList.toString()}');
        print('combinedList = ${combinedList.length}');
      } else {}
    } catch (e) {
      print('student fees error  = ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(
        title: 'Fees',
        isBackIconVisible: widget.isBackIconVisible,
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CupertinoActivityIndicator())
                : combinedList.isEmpty
                ? Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/no_data.png',
                        width: 200,
                        height: 200,
                      ),
                      Text('No Data Available'),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          color: Colors.deepPurple,
                          elevation: 5.0,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grand Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 16.0),
                                _buildGrandTotalItem('Amount', gtAmt),
                                _buildGrandTotalItem('Discount', gtDiscount),
                                _buildGrandTotalItem('Fine', gtFine),
                                _buildGrandTotalItem('Paid', gtPaid),
                                _buildGrandTotalItem('Balance', gtBalance),
                              ],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true, // Add this line
                          physics:
                              NeverScrollableScrollPhysics(), // Add this line
                          itemCount: combinedList.length,
                          itemBuilder: (context, index) {
                            if (combinedList[index].category == 'fees') {
                              return _buildFeesCard(
                                context,
                                combinedList[index] as FeesItem,
                              );
                            } else {
                              return _buildDiscountCard(
                                context,
                                combinedList[index] as DiscountItem,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildGrandTotalItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16.0, color: Colors.white)),
          Text(
            '$currency$value',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeesCard(BuildContext context, FeesItem feesItem) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feesItem.code ?? '',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.0),
            _buildFeesInfoRow('Due Date: ', feesItem.dueDate ?? ''),
            _buildFeesInfoRow('Amount: ', '$currency${feesItem.amount}'),
            _buildFeesInfoRow(
              'Paid Amount: ',
              '$currency${feesItem.totalAmountPaid}',
            ),
            _buildFeesInfoRow(
              'Balance Amount: ',
              '$currency${feesItem.totalAmountRemaining}',
            ),
            SizedBox(height: 8.0),
            _buildFeesStatusRow(feesItem),
          ],
        ),
      ),
    );
  }

  Widget _buildFeesInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(value, style: TextStyle(fontSize: 14, color: Colors.black)),
      ],
    );
  }

  Widget _buildFeesStatusRow(FeesItem feesItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          feesItem.status ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color:
                feesItem.status?.toLowerCase() == 'paid'
                    ? Colors.green
                    : feesItem.status?.toLowerCase() == 'unpaid'
                    ? Colors.red
                    : Colors.yellow,
          ),
        ),
        Row(
          children: [
            if (feesItem.status?.toLowerCase() != 'unpaid')
              _buildActionButton('View', () {
                _showDataDialog(
                  context,
                  feesItem.amountDetails ?? "",
                  currency,
                );
              }),
            if (feesItem.status?.toLowerCase() != 'paid' && payMethod == 1)
              SizedBox(width: 8.0), // Add some spacing
            if (feesItem.status?.toLowerCase() != 'paid' && payMethod == 1)
              _buildActionButton('Pay', () async {
                // check the eazypay data before proceeding
                if (eazypay.isEmpty ||
                    eazypay["merchant_id"] == null ||
                    eazypay["encryption_key"] == null ||
                    eazypay["sub_merchant_id"] == null ||
                    eazypay["merchant_id"] == "" ||
                    eazypay["encryption_key"] == "" ||
                    eazypay["sub_merchant_id"] == "") {
                  Utils.showToast('Eazypay data not available');
                  return;
                }
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => StudentFeesPayment(
                          amount: feesItem.totalAmountRemaining ?? '0',
                          merchantId: eazypay["merchant_id"] ?? "",
                          encryptionKey: eazypay["encryption_key"],
                          subMerchantId: eazypay["sub_merchant_id"],
                          studentFeesMasterId: feesItem.id ?? '0',
                          feeGroupsFeeTypeId:
                              feesItem.feeGroupsFeeTypeId ?? '0',
                        ),
                  ),
                );
                loadData();
              }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: text == 'View' ? Colors.blue : Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      child: Text(text),
    );
  }

  Widget _buildDiscountCard(BuildContext context, DiscountItem discountItem) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discount-${discountItem.code}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              'Discount of ${discountItem.currency} ${discountItem.amount}',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label:',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        SizedBox(width: 8),
        Flexible(child: Text(value, style: TextStyle(color: Colors.black))),
      ],
    );
  }

  Future<void> _showDataDialog(
    BuildContext context,
    String jsonData,
    String currency,
  ) async {
    Map<String, dynamic> data = json.decode(jsonData);
    List<Widget> dataWidgets = [];
    data.forEach((key, value) {
      FeesDetailsData feesDetailsData = FeesDetailsData.fromJson(value);
      dataWidgets.add(
        Card(
          elevation: 5,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Amount', "$currency${feesDetailsData.amount}"),
                _buildDetailRow('Date', feesDetailsData.date ?? 'N/A'),
                _buildDetailRow(
                  'Description',
                  feesDetailsData.description ?? 'N/A',
                ),
                _buildDetailRow(
                  'Collected By',
                  feesDetailsData.collectedBy ?? 'N/A',
                ),
                _buildDetailRow(
                  'Amount Discount',
                  "$currency${feesDetailsData.amountDiscount}",
                ),
                _buildDetailRow(
                  'Amount Fine',
                  "$currency${feesDetailsData.amountFine.toString()}",
                ),
                _buildDetailRow(
                  'Payment Mode',
                  feesDetailsData.paymentMode ?? 'N/A',
                ),
                _buildDetailRow(
                  'Received By',
                  feesDetailsData.receivedBy ?? 'N/A',
                ),
                _buildDetailRow(
                  'Invoice Number',
                  feesDetailsData.invoiceNumber.toString(),
                ),
                SizedBox(height: 16), // Add some spacing between entries
              ],
            ),
          ),
        ),
      );
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Fees Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: dataWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
