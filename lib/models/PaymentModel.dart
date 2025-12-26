class PaymentModel {
  final int? id;
  final String? transactionId;
  final String? orderNo;
  final String? totalAmount;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? paymentDate;
  final String? currency;

  PaymentModel({
    this.id,
    this.transactionId,
    this.orderNo,
    this.totalAmount,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentDate,
    this.currency,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      transactionId: json['transaction_id'],
      orderNo: json['order_no'],
      totalAmount: json['total_amount'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'],
      currency: json['currency'],
    );
  }
}
