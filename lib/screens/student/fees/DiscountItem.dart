import 'package:infixedu/screens/student/fees/FeeItemBase.dart';
class DiscountItem extends FeeItemBase {
  final String? id;
  @override
  final String? currency;

  DiscountItem({
    this.id,
    this.currency,
    super.code,
    super.amount,
    super.paymentId,
    super.status,
  }) : super(
    category: 'discount',
  );

  factory DiscountItem.fromJson(Map<String, dynamic> json, String currency) {
    return DiscountItem(
      id: json['id'] + "discount",
      code: json['code'],
      amount: json['amount'].toString(),
      paymentId: json['payment_id'].toString(),
      status: "${json['status']} - ${json['payment_id']}",
      currency: currency
    );
  }
}