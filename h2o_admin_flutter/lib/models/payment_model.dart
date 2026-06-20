class PaymentModel {
  final String id;
  final String service;
  final String? serviceName;
  final bool requiresPayment;
  final String amount;

  PaymentModel({
    required this.id,
    required this.service,
    this.serviceName,
    required this.requiresPayment,
    required this.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      service: json['service'] ?? '',
      serviceName: json['service_name'],
      requiresPayment: json['requires_payment'] ?? false,
      amount: json['amount'] ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service,
      'service_name': serviceName,
      'requires_payment': requiresPayment,
      'amount': amount,
    };
  }
}
