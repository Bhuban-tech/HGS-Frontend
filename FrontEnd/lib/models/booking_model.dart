class Booking {
  final String? id;
  final String userId;
  final String providerId;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final String userName;
  final String status; // PENDING, ACCEPTED, REJECTED, COMPLETED, CANCELLED
  final bool chatEnabled; // NEW FIELD from backend
  final DateTime bookingDate;
  final String? description;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.userName,
    required this.status,
    this.chatEnabled = false, // Default to false
    required this.bookingDate,
    this.description,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? json['serviceProviderId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName'] ?? '',
      providerName: json['providerName'] ?? '',
      userName: json['userName'] ?? '',
      status: json['status'] ?? 'PENDING',
      chatEnabled: json['chatEnabled'] ?? false, // NEW FIELD
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      description: json['description'],
      location: json['location'] ?? json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerName': providerName,
      'userName': userName,
      'status': status,
      'chatEnabled': chatEnabled,
      'bookingDate': bookingDate.toIso8601String(),
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? providerId,
    String? serviceId,
    String? serviceName,
    String? providerName,
    String? userName,
    String? status,
    bool? chatEnabled,
    DateTime? bookingDate,
    String? description,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      providerName: providerName ?? this.providerName,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      chatEnabled: chatEnabled ?? this.chatEnabled,
      bookingDate: bookingDate ?? this.bookingDate,
      description: description ?? this.description,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  
  // Use chatEnabled field from backend
  bool get canChat => chatEnabled;
  bool get canCancel => isPending; // Only pending bookings can be cancelled
}
