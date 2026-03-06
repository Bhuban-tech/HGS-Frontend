class Transaction {
  final String? id;
  final String userId;
  final String paymentMethod; // 'KHALTI' or 'ESEWA'
  final int amount; // in paisa for Khalti, rupees for eSewa
  final String status; // 'Completed', 'Pending', 'Failed'
  final String? transactionId;
  final String? pidx; // For Khalti
  final String? referenceId; // For eSewa
  final DateTime? paidAt;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.userId,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    this.transactionId,
    this.pidx,
    this.referenceId,
    this.paidAt,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'Pending',
      transactionId: json['transactionId'],
      pidx: json['pidx'],
      referenceId: json['referenceId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'status': status,
      if (transactionId != null) 'transactionId': transactionId,
      if (pidx != null) 'pidx': pidx,
      if (referenceId != null) 'referenceId': referenceId,
      if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'Completed';
  bool get isPending => status == 'Pending';
  bool get isFailed => status == 'Failed';

  // Get amount in rupees
  double get amountInRupees {
    if (paymentMethod == 'KHALTI') {
      return amount / 100; // Convert paisa to rupees
    }
    return amount.toDouble();
  }
}
