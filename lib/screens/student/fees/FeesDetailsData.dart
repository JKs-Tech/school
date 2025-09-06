class FeesDetailsData {
  final String? amount;
  final String? date;
  final String? description;
  final String? collectedBy;
  final String? amountDiscount;
  final String? amountFine;
  final String? paymentMode;
  final String? receivedBy;
  final String? invoiceNumber;

  FeesDetailsData({
    this.amount,
    this.date,
    this.description,
    this.collectedBy,
    this.amountDiscount,
    this.amountFine,
    this.paymentMode,
    this.receivedBy,
    this.invoiceNumber,
  });

  factory FeesDetailsData.fromJson(Map<String, dynamic> json) {
    return FeesDetailsData(
      amount: json['amount'].toString(),
      date: json['date'].toString(),
      description: json['description'].toString(),
      collectedBy: json['collected_by'].toString(),
      amountDiscount: json['amount_discount'].toString(),
      amountFine: json['amount_fine'].toString(),
      paymentMode: json['payment_mode'].toString(),
      receivedBy: json['received_by'].toString(),
      invoiceNumber: json['inv_no'].toString(),
    );
  }
}
