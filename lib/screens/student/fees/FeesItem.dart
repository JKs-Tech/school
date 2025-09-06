import 'package:infixedu/screens/student/fees/FeeItemBase.dart';

class FeesItem extends FeeItemBase {
  final String? id;
  final String? dueDate;
  final String? totalAmountPaid;
  final String? totalAmountRemaining;
  @override
  final String? currency;
  @override
  final String? amountDetails;
  final String? feeGroupsFeeTypeId;

  FeesItem({
    this.id,
    this.dueDate,
    this.totalAmountPaid,
    this.totalAmountRemaining,
    this.currency,
    this.amountDetails,
    this.feeGroupsFeeTypeId,
    super.code,
    super.amount,
    super.paymentId,
    super.status,
  }) : super(category: 'fees');

  factory FeesItem.fromJson(Map<String, dynamic> json, String currency) {
    return FeesItem(
      id: json['id'].toString(),
      dueDate: json['due_date'].toString(),
      totalAmountPaid: json['total_amount_paid'].toString(),
      totalAmountRemaining: json['total_amount_remaining'].toString(),
      code: "${json['name']}-${json['type']}",
      amount: json['amount'].toString(),
      paymentId: json['student_fees_deposite_id'].toString(),
      status:
          json['status'].toString().substring(0, 1).toUpperCase() +
          json['status'].substring(1),
      amountDetails: json['amount_detail'].toString(),
      feeGroupsFeeTypeId: json['fee_groups_feetype_id'].toString(),
      currency: currency,
    );
  }
}
