class Transaction {
  final String? id;
  final String serviceName;
  final String serviceDescription;
  final String paymentMethod;
  final double amount;
  final String status;
  final String bookingStatus;
  final DateTime transactionDate;
  final String transactionId;
  final String? categoryIcon;
  final bool refund;

  Transaction({
    this.id,
    required this.serviceName,
    required this.serviceDescription,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.bookingStatus,
    required this.transactionDate,
    required this.transactionId,
    this.categoryIcon,
    required this.refund,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      serviceName: json['serviceName'] ?? 'Payment',
      serviceDescription: json['serviceDescription'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      bookingStatus: json['bookingStatus'] ?? '',
      transactionDate: json['transactionDate'] != null 
          ? DateTime.parse(json['transactionDate']) 
          : DateTime.now(),
      transactionId: json['transactionId'] ?? '',
      categoryIcon: json['categoryIcon'],
      refund: json['refund'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'serviceName': serviceName,
      'serviceDescription': serviceDescription,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'status': status,
      'bookingStatus': bookingStatus,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionId': transactionId,
      if (categoryIcon != null) 'categoryIcon': categoryIcon,
      'refund': refund,
    };
  }

  bool get isCompleted => status == 'Success';
  bool get isPending => status == 'Pending';
  bool get isFailed => status == 'Failed';
  bool get isRefunded => status == 'Refunded';
}
